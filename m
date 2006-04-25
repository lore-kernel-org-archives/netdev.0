From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]: suspicious unlikely usage in tcp_transmit_skb()
Date: Tue, 25 Apr 2006 15:34:06 +1000
Message-ID: <E1FYGBa-00085C-00@gondolin.me.apana.org.au>
References: <444D5E73.7020803@gmail.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:11536 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932113AbWDYFeP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Apr 2006 01:34:15 -0400
To: hzhong@gmail.com (Hua Zhong)
In-Reply-To: <444D5E73.7020803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hua Zhong <hzhong@gmail.com> wrote:
> 
> I am developing a profiling tool to check if likely/unlikely usages are wise. I find that the following one is always a miss:
> 
>      # Hit    # miss Function:Filename@Line
> !         0     50505 tcp_transmit_skb():net/ipv4/tcp_output.c@468
> 
> There is a chance that my tool is buggy, but I just want to confirm with you whether this does look suspicious and what your opinion is.

Your tool is correct.  The only way for it to fall through is if
we encounter local congestion.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
