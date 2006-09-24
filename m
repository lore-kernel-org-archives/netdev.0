From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Is TCP over IPsec broken in 2.6.18?
Date: Mon, 25 Sep 2006 09:54:06 +1000
Message-ID: <E1GRdnS-0003kd-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.64.0609241029410.14827@d.namei>
Cc: kaber@trash.net, johnpol@2ka.mipt.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45072 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751477AbWIXXyo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Sep 2006 19:54:44 -0400
To: jmorris@namei.org (James Morris)
In-Reply-To: <Pine.LNX.4.64.0609241029410.14827@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris <jmorris@namei.org> wrote:
>
> Evgeniy: if you update to the latest racoon (and kernel), and still see 
> it, please send complete logs of 'racoon -dddd' from each side, and also 
> 'setkey -x', so we can see if the policy entries are being being modified.

Please also do 'ip -s x s' on both sides to check the various counters.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
