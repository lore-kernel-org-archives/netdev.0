From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: allow bond in mode balance-alb to work
 properly in bridge -try4
Date: Fri, 27 Mar 2009 00:38:19 -0700 (PDT)
Message-ID: <20090327.003819.234492275.davem@davemloft.net>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com>
	<20090326155205.GA28868@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, kaber@trash.net,
	mschmidt@redhat.com, dada1@cosmosbay.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43871
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751857AbZC0Hic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 03:38:32 -0400
In-Reply-To: <20090326155205.GA28868@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu, 26 Mar 2009 16:52:06 +0100

> (resend, updated changelog, hook moved into skb_bond_should_drop,
> skb_bond_should_drop ifdefed)
> 
> Hi all.
> 
> The problem is described in following bugzilla:
> https://bugzilla.redhat.com/show_bug.cgi?id=487763
 ...
> This patch solves the situation in the bonding without touching bridge code,
> as Patrick suggested. For every incoming frame to bonding it searches the
> destination address in slaves list and if any of slave addresses matches, it
> rewrites the address in frame by the adress of bonding master. This ensures that
> all frames comming thru the bonding in alb mode have the same address.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>


I don't like the hook, but if that's how it's best done....

Patrick, please review this.
