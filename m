From: David Miller <davem@davemloft.net>
Subject: Re: pppoe: Unshare skb before anything else
Date: Tue, 10 Jun 2008 15:01:16 -0700 (PDT)
Message-ID: <20080610.150116.49258090.davem@davemloft.net>
References: <484BAFBB.6010108@katalix.com>
	<20080610.140925.199998975.davem@davemloft.net>
	<484EF5A2.4060503@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35981
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753215AbYFJWBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 18:01:16 -0400
In-Reply-To: <484EF5A2.4060503@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Tue, 10 Jun 2008 22:44:02 +0100

> David Miller wrote:
> > From: James Chapman <jchapman@katalix.com>
> > Date: Sun, 08 Jun 2008 11:08:59 +0100
> > 
> >> Herbert Xu wrote:
> >>> Hi Dave:
> >>>
> >>> I noticed that my last patch to move the unshare in pppoe missed
> >>> the other spot which did the same thing:
> >>>
> >>> pppoe: Unshare skb before anything else
> >>>
> >>> We need to unshare the skb first as otherwise pskb_may_pull may
> >>> write to a shared skb which could be bad.
> >> The same problem exists in the pppol2tp driver. Patch to follow. I'm 
> >> also fixing the copy-to-iovec issue.
> > 
> > I have the iovec patch, but I do not see the unshare one.
> > Did you post it?  Please resend if you have since I
> > don't have a copy.
> 
> I didn't send the patch. I realised when I was writing it that in L2TP's 
> case, the unshare isn't needed because L2TP uses UDP encap sockets.
> 
> Sorry I forgot to let Herbert and netdev know.

Great, thanks for the info.
