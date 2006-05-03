From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Disabling "TCP Treason uncloaked"
Date: Wed, 03 May 2006 22:11:46 +1000
Message-ID: <E1FbGCo-0000OS-00@gondolin.me.apana.org.au>
References: <4458AB57.6060706@corky.net>
Cc: netdev@axxeo.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40465 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965171AbWECMLy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 08:11:54 -0400
To: marc@corky.net (Just Marc)
In-Reply-To: <4458AB57.6060706@corky.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just Marc <marc@corky.net> wrote:
>   
> That's good, but it may (and probably will) suppress many other messages 
> which may be of more interest...

That's the crux of the matter.  There is no way we can satisfy everyone
short of putting a knob on each individual printk.

So the only solution is to do the filtering yourself in userspace through
klogd/syslogd.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
