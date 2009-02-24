From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ipv6: Remove some pointless conditionals before
	kfree_skb()
Date: Tue, 24 Feb 2009 17:47:38 +0800
Message-ID: <20090224094738.GA21939@gondor.apana.org.au>
References: <49A3BEF1.4030802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org, davem@davemloft.net
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55501 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754450AbZBXJrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 04:47:42 -0500
Content-Disposition: inline
In-Reply-To: <49A3BEF1.4030802@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yang Hongyang <yanghy@cn.fujitsu.com> wrote:
>
> I think kfree_skb() suppose that you have handled NULL pointer 
> because it uses `unlikely` to check the pointer.
> So I don't think these conditions are pointless...
> 437 void kfree_skb(struct sk_buff *skb)
> 438 {
> 439         if (unlikely(!skb))
> 440                 return;

These checks were specifically added so that callers didn't have
to check for NULL.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
