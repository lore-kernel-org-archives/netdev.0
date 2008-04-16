From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Discard tcp out-of-order queue if system limit is
 reached
Date: Wed, 16 Apr 2008 00:08:11 -0700 (PDT)
Message-ID: <20080416.000811.99314030.davem@davemloft.net>
References: <200804151854.45021.vgusev@openvz.org>
	<20080415.202740.114756353.davem@davemloft.net>
	<4805A459.5050706@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vgusev@openvz.org, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57056
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750937AbYDPHIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 03:08:11 -0400
In-Reply-To: <4805A459.5050706@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Wed, 16 Apr 2008 09:01:45 +0200

> David Miller wrote:
> > From: Vitaliy Gusev <vgusev@openvz.org>
> > Date: Tue, 15 Apr 2008 18:54:44 +0400
> > 
> >> tcp_prune_queue() doesn't prune an out-of-order queue if socket
> >> is under rcvbuf. However even if socket is under rcvbuf but system-wide limit is
> >> reached then skb cannot be queued. It can lead to deadlock situation as any skb that
> >> fills sequence hole is dropped.
> >> So discard out-of-order queue if system-wide limit is reached.
> >>
> >> Signed-off-by: Vitaliy Gusev <vgusev@openvz.org>
> > 
> > I applied your original patch already, so I added the following
> > relative patch.
> 
> Could you please at least update the original description to the
> one from the new patch? That one was somewhat misleading imho.

It's already a few changesets deep in my tree and it's already
pushed to kernel.org  I really don't want to have to respin my
tree and break it for all of my downstream tree developers just
to make this commit message fixup.

Sorry.
