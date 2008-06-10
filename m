From: James Chapman <jchapman@katalix.com>
Subject: Re: pppoe: Unshare skb before anything else
Date: Tue, 10 Jun 2008 22:44:02 +0100
Message-ID: <484EF5A2.4060503@katalix.com>
References: <20080608062913.GA20871@gondor.apana.org.au>	<484BAFBB.6010108@katalix.com> <20080610.140925.199998975.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:33478 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758229AbYFJVoI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 17:44:08 -0400
In-Reply-To: <20080610.140925.199998975.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: James Chapman <jchapman@katalix.com>
> Date: Sun, 08 Jun 2008 11:08:59 +0100
> 
>> Herbert Xu wrote:
>>> Hi Dave:
>>>
>>> I noticed that my last patch to move the unshare in pppoe missed
>>> the other spot which did the same thing:
>>>
>>> pppoe: Unshare skb before anything else
>>>
>>> We need to unshare the skb first as otherwise pskb_may_pull may
>>> write to a shared skb which could be bad.
>> The same problem exists in the pppol2tp driver. Patch to follow. I'm 
>> also fixing the copy-to-iovec issue.
> 
> I have the iovec patch, but I do not see the unshare one.
> Did you post it?  Please resend if you have since I
> don't have a copy.

I didn't send the patch. I realised when I was writing it that in L2TP's 
case, the unshare isn't needed because L2TP uses UDP encap sockets.

Sorry I forgot to let Herbert and netdev know.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

