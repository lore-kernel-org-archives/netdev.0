From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: allow bond in mode balance-alb to work
 properly in bridge -try4
Date: Sun, 29 Mar 2009 13:53:55 -0700 (PDT)
Message-ID: <20090329.135355.109115565.davem@davemloft.net>
References: <20090326155205.GA28868@psychotron.englab.brq.redhat.com>
	<20090327.003819.234492275.davem@davemloft.net>
	<49CC85E9.7070903@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	mschmidt@redhat.com, dada1@cosmosbay.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50081
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754912AbZC2UyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 16:54:08 -0400
In-Reply-To: <49CC85E9.7070903@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 27 Mar 2009 08:53:13 +0100

> David Miller wrote:
> > I don't like the hook, but if that's how it's best done....
> > Patrick, please review this.
> 
> Me neither, but I don't think this approach can be done without the
> hook. While I still find it questionable whether this mode really
> needs to be supported for a bridge at all, an alternative approach
> would be to have bonding add FDB entries for all secondary MACs to
> make bridging treat them as local.

Do you guys foresee any possibility of an alternative implementation
any time soon?

Otherwise we're just stalling by not putting something into the tree,
and as far as I can tell this patch here might as well be it.
