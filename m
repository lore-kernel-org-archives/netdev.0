From: Stephan Mueller <smueller@chronox.de>
Subject: Re: [PATCH 5/7] esp6: Switch to new AEAD interface
Date: Fri, 22 May 2015 09:16:08 +0200
Message-ID: <2066513.Bca9qAkvxD@tauon>
References: <20150521103938.GA23035@gondor.apana.org.au> <2287044.Rx7bts6Hbt@tauon> <20150522064554.GA2522@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.eperm.de ([89.247.134.16]:58177 "EHLO mail.eperm.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756443AbbEVHQL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2015 03:16:11 -0400
In-Reply-To: <20150522064554.GA2522@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 22. Mai 2015, 14:45:54 schrieb Herbert Xu:

Hi Herbert,

>On Fri, May 22, 2015 at 08:40:25AM +0200, Stephan Mueller wrote:
>> If I may ask, where in your initial patch set is now decided that the IV
>> generator is used (i.e. so that the givcrypt API is not needed any more)?
>
>Please see
>
>https://www.mail-archive.com/linux-crypto@vger.kernel.org/msg14270.html

Thanks for the pointer, but there I do not really see the functionality I am 
looking for. I see patch 10/16 which seems to indicate that the geniv logic is 
now to be invoked as a normal AEAD cipher. I yet fail to see where the 
distinction is made in the code that an IV is to be generated versus the given 
IV is to be used.


Ciao
Stephan
