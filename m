From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: Remove some pointless conditionals before	kfree_skb()
Date: Tue, 24 Feb 2009 17:54:25 +0800
Message-ID: <49A3C3D1.2040908@cn.fujitsu.com>
References: <20090224094738.GA21939@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org, davem@davemloft.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62072 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751682AbZBXJw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2009 04:52:58 -0500
In-Reply-To: <20090224094738.GA21939@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Yang Hongyang <yanghy@cn.fujitsu.com> wrote:
>> I think kfree_skb() suppose that you have handled NULL pointer 
>> because it uses `unlikely` to check the pointer.
>> So I don't think these conditions are pointless...
>> 437 void kfree_skb(struct sk_buff *skb)
>> 438 {
>> 439         if (unlikely(!skb))
>> 440                 return;
> 
> These checks were specifically added so that callers didn't have
> to check for NULL.

Yes,but if the the callers checked for NULL,it's OK right?

> 
> Cheers,


-- 
Regards
Yang Hongyang
