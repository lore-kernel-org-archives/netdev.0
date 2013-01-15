From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: small iputils build patch
Date: Wed, 16 Jan 2013 03:24:06 +0900
Message-ID: <50F59EC6.9040904@linux-ipv6.org>
References: <CADyApD2CxE=mEWKCF9gW=0vGgFkcZZo=DRi-UKP8wNeXMXUifQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Arjan van de Ven <arjanvandeven@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:41433 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755202Ab3AOSYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 13:24:07 -0500
In-Reply-To: <CADyApD2CxE=mEWKCF9gW=0vGgFkcZZo=DRi-UKP8wNeXMXUifQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arjan van de Ven wrote:
> The ping6 command can use either openssl or gnutls...
> and the Makefile has a bunch of setup for defining which of the two to use.
> 
> Unfortunately, the final -D define on the commandline to enable gnutls
> inside the ping6.c file didn't actually make it onto the gcc
> commandline.
> This patch adds the $(DEF_CRYPTO) Makefile variable to fix this gap.
> 
> Signed-off-by: Arjan van de Ven <arjanvandeven@gmail.com>
> 

Applied, thank you.

--yoshfuji
