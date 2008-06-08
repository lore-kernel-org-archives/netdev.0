From: James Chapman <jchapman@katalix.com>
Subject: Re: pppoe: Unshare skb before anything else
Date: Sun, 08 Jun 2008 11:08:59 +0100
Message-ID: <484BAFBB.6010108@katalix.com>
References: <20080608062913.GA20871@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:45049 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756171AbYFHKJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2008 06:09:07 -0400
In-Reply-To: <20080608062913.GA20871@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Hi Dave:
> 
> I noticed that my last patch to move the unshare in pppoe missed
> the other spot which did the same thing:
> 
> pppoe: Unshare skb before anything else
> 
> We need to unshare the skb first as otherwise pskb_may_pull may
> write to a shared skb which could be bad.

The same problem exists in the pppol2tp driver. Patch to follow. I'm 
also fixing the copy-to-iovec issue.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

