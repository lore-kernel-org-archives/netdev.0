From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][XFRM] Use the simple name when adding SAD with ip xfrm
 state
Date: Tue, 19 Jan 2010 00:30:41 -0800 (PST)
Message-ID: <20100119.003041.193317921.davem@davemloft.net>
References: <20100119022033.GA18155@gondor.apana.org.au>
	<4B556C72.40403@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: lyw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52598
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750955Ab0ASIac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 03:30:32 -0500
In-Reply-To: <4B556C72.40403@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yewang <lyw@cn.fujitsu.com>
Date: Tue, 19 Jan 2010 16:25:22 +0800

> 
> 
> Herbert Xu wrote:
>> Li Yewang <lyw@cn.fujitsu.com> wrote:
>>> The encryption name such as "rfc3686(ctr(aes))" is too complex.
>>> I think simple name is better for user when using "ip xfrm state ..." command.
>>>
>>>
>>> Signed-off-by: Li Yewang <lyw@cn.fujitsu.com>
>> 
>> Nack.  If we want to support simple names such as these, they
>> should be done in the crypto layer.  Otherwise every crypto user
>> that wants this would have to reinvent it.
> 
>   But user sets SAD for ipsec with "ip xfrm state ..." must use the name such as "rfc3686(ctr(aes))".
>   Is that reasonable? Maybe user can not remember this complex name.
> 
>   There are some simple names for other encryptions, 
>   such as "cbc(blowfish)", you can use "ip xfrm state ... enc blowfish ...".

You're not reading what Herbert is saying.

He's fine with the shorter name, he just wants you to implement
is in the crypto layer core instead of the XFRM specific code.

That way all crypto users will benefit from the shorter naming.
