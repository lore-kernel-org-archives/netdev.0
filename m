From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Update function names in /proc/net/tcp documentation
Date: Sun, 14 Oct 2007 18:09:12 +0800
Message-ID: <E1Ih0PI-0003TX-00@gondolin.me.apana.org.au>
References: <20071014115934.13530a8a@hyperion.delvare>
Cc: herbert@gondor.apana.org.au, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: khali@linux-fr.org (Jean Delvare)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3719 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755151AbXJNKJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 06:09:26 -0400
In-Reply-To: <20071014115934.13530a8a@hyperion.delvare>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jean Delvare <khali@linux-fr.org> wrote:
>
>> inet_diag is the preferred interface.
> 
> How does it work? Is there some documentation available? I see
> net/ipv4/inet_diag.c but I have no idea how to use it.

Have a look at the iproute package.  It contains the ss command
which provides a command-line interface to it.

Of course it's also a good example of how you can access it from
C.  The Debian pidentd package has also been patched to use this
interface.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
