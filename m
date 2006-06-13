From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec and EAGAIN
Date: Tue, 13 Jun 2006 21:44:33 +1000
Message-ID: <E1Fq7Jx-0003TK-00@gondolin.me.apana.org.au>
References: <61418.152.91.8.100.1150177885.squirrel@webmail.jdns.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50695 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751082AbWFMLoo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 07:44:44 -0400
To: sjr@jdns.org (James Ring)
In-Reply-To: <61418.152.91.8.100.1150177885.squirrel@webmail.jdns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Ring <sjr@jdns.org> wrote:
> 
> I have a couple of questions: are there any patches out which solve this
> problem?

This is on our todo list but AFAIK there aren't patches for it yet.

> http://sourceforge.net/mailarchive/message.php?msg_id=8621194

This patch can lock up your machine when this function is entered in an
unsleepable context.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
