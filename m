From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (regression)] Fragments: fix race between
 inet_frag_find and inet_frag_secret_rebuild
Date: Wed, 25 Jun 2008 00:09:03 -0700 (PDT)
Message-ID: <20080625.000903.262554536.davem@davemloft.net>
References: <20080624180714.GA3125@ami.dom.local>
	<4861E8F0.9080507@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43784
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751832AbYFYHJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 03:09:04 -0400
In-Reply-To: <4861E8F0.9080507@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 25 Jun 2008 10:42:56 +0400

> Jarek Poplawski wrote:
> > Maybe it's a matter of taste: since there is this "#ifdef CONFIG_SMP",
> > and the new comment concerns with "other CPU", why this re-calculation
> > isn't done only for SMP? 
> 
> Because the hash value is required also *outside* this ifdef and adding
> a fancier logic is probably not good for a -rc7 fix.
> 
> However, I will re-consider this for net-next.
> 
> > And, btw., probably __acquires/__releases annotations could be added
> > with this patch.
> 
> This is also a net-next material (I hope Dave agrees with me on both).

I do. :-)
