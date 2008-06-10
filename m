From: David Miller <davem@davemloft.net>
Subject: Re: pppoe: Unshare skb before anything else
Date: Tue, 10 Jun 2008 14:09:25 -0700 (PDT)
Message-ID: <20080610.140925.199998975.davem@davemloft.net>
References: <20080608062913.GA20871@gondor.apana.org.au>
	<484BAFBB.6010108@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56547
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754482AbYFJVJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 17:09:26 -0400
In-Reply-To: <484BAFBB.6010108@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Sun, 08 Jun 2008 11:08:59 +0100

> Herbert Xu wrote:
> > Hi Dave:
> > 
> > I noticed that my last patch to move the unshare in pppoe missed
> > the other spot which did the same thing:
> > 
> > pppoe: Unshare skb before anything else
> > 
> > We need to unshare the skb first as otherwise pskb_may_pull may
> > write to a shared skb which could be bad.
> 
> The same problem exists in the pppol2tp driver. Patch to follow. I'm 
> also fixing the copy-to-iovec issue.

I have the iovec patch, but I do not see the unshare one.
Did you post it?  Please resend if you have since I
don't have a copy.

Thanks.
