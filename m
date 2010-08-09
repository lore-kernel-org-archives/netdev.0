From: Franchoze Eric <franchoze@yandex.ru>
Subject: Re: Re: [PATCH] sfq: add dummy bind/unbind handles
Date: Mon, 09 Aug 2010 19:01:17 +0400
Message-ID: <151621281366078@web89.yandex.ru>
References: <20100806145818.66d389eb@nehalam> <20100806152313.43abc30b@nehalam> <4C5C97F3.3010604@gmail.com> <20100807.224514.137860816.davem@davemloft.net> <4C5E570E.6020908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward6.mail.yandex.net ([77.88.60.125]:59355 "EHLO
	forward6.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756636Ab0HIPNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 11:13:08 -0400
In-Reply-To: <4C5E570E.6020908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



08.08.10, 11:04, "Jarek Poplawski" <jarkao2@gmail.com>:

> David Miller wrote, On 08.08.2010 07:45:
>  
>  > From: Jarek Poplawski 
>  > Date: Sat, 07 Aug 2010 01:17:07 +0200
>  > 
>  >> Stephen Hemminger wrote, On 07.08.2010 00:23:
>  >>
>  >>> Applying a filter to an SFQ qdisc would cause null dereference
>  >>> in tcf_bind_filter because although SFQ is classful it didn't
>  >>> have all the necessary equipment.
>  >>>
>  >>> Better alternative to changing tcf_bind API is to just fix
>  >>> SFQ.  This should go to net-2.6 and stable.
>  >>>
>  >>
>  >> Hmm... FYI, actually I've sent already a similar patch to the
>  >> original bug report thread (except .unbind_tcf method which
>  >> doesn't matter for fixing this bug, so should be rather
>  >> implemented in a separate patch, if needed at all in this
>  >> case).
>  > 
>  > Agreed, I can't see a way that unbind can ever be invoked
>  > if the bind call always returns zero.
>  
>  To tell the truth, I think unbind should be implemented anyway,
>  just for consistency, safety, and easier verification. But, looking
>  at a similar case of .get and .put in the same driver, Patrick
>  seemed to do it purposely, so I expected some discussion about the
>  rules yet, and made it minimal to ease merging to older kernels.
>   
>  Thanks,
>  Jarek P.
>  
>  

As for me it's better to add unbind now that get unexpected null derefance in future with API changing...
