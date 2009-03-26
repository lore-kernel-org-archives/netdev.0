From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: allow bond in mode balance-alb to work
 properly in bridge -try3
Date: Wed, 25 Mar 2009 17:24:27 -0700 (PDT)
Message-ID: <20090325.172427.98374994.davem@davemloft.net>
References: <20090325151937.GI3437@psychotron.englab.brq.redhat.com>
	<28445.1237998713@death.nxdomain.ibm.com>
	<20090325174405.GM3437@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	bonding-devel@lists.sourceforge.net, kaber@trash.net,
	mschmidt@redhat.com, dada1@cosmosbay.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34385
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752705AbZCZAYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 20:24:39 -0400
In-Reply-To: <20090325174405.GM3437@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 25 Mar 2009 18:44:05 +0100

> Wed, Mar 25, 2009 at 05:31:53PM CET, fubar@us.ibm.com wrote:
> >Jiri Pirko <jpirko@redhat.com> wrote:
> >
> >>Basically here's what's going on. In every mode, bonding interface uses the same
> >>mac address for all enslaved devices. Except for mode balance-alb. 
> >
> >	I think you mean "only balance-alb will simultaneously use
> >multiple MAC addresses across different slaves."  Yes?
> Yes I do. I will refolmulate the phrase and repost the patch if you want...

I'll let you guys discuss this some more.

It looks like we could have some more tweaks before this patch is
finalized.
