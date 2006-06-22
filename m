From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Export accept queue len of a TCP listening socket	via	/proc/net/tcp{6}
Date: Thu, 22 Jun 2006 10:50:47 +1000
Message-ID: <E1FtDPD-0005mc-00@gondolin.me.apana.org.au>
References: <1150936509.2868.30.camel@w-sridhar2.beaverton.ibm.com>
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37132 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932164AbWFVAu6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 20:50:58 -0400
To: sri@us.ibm.com (Sridhar Samudrala)
In-Reply-To: <1150936509.2868.30.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sridhar Samudrala <sri@us.ibm.com> wrote:
>> 
>> What about using the same fields (rqueue/wqueue) as you did for /proc?
> 
> I meant extending tcp_info structure to add new fields. I think the user
> space also uses this structure.

What about putting it into inet_idiag_msg.idiag_[rw]queue instead?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
