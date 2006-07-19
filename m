From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: michael_mic in crypto api?
Date: Thu, 20 Jul 2006 01:39:05 +1000
Message-ID: <E1G3E8f-0007xk-00@gondolin.me.apana.org.au>
References: <200607152144.44350.flamingice@sourmilk.net>
Cc: herbert@gondor.apana.org.au, jbenc@suse.cz, linville@tuxdriver.com,
	netdev@vger.kernel.org, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42507 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030189AbWGSPjk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 11:39:40 -0400
To: flamingice@sourmilk.net (Michael Wu)
In-Reply-To: <200607152144.44350.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Wu <flamingice@sourmilk.net> wrote:
>
> Simplicity and consistency. Whereas the relatively simple mic part of the TKIP 
> algorithm is in crypto API, the (more important, more complicated) key mixing 
> part is not in crypto api. It is unlikely that either the mic or key mixing 
> part would be used separately or even outside of TKIP/802.11i code, and we 
> don't want to encourage people anyways since they're just bandaids for 
> problems associated with using rc4.

Sure, I don't mind either way.  I think Jouni wrote this originally,
maybe he can share his thoughts with us?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
