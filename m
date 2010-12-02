From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: bridge netpoll support: mismatch between net core and bridge headers
Date: Thu, 2 Dec 2010 03:29:17 -0500
Message-ID: <AANLkTimO79DLyCb5vXQ04keX6Mjwv32wNQLRZcfyPNF2@mail.gmail.com>
References: <AANLkTimbf+yfJFU29rNWAc-hXBxj92J=dNaShM04GNZ7@mail.gmail.com>
 <20101201.114201.245392768.davem@davemloft.net> <AANLkTi=hq6S_NvPEkTovkceUe9Orcitj_oHN1mVUW7+A@mail.gmail.com>
 <20101201.163319.193705748.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60154 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754800Ab0LBI3j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 03:29:39 -0500
Received: by wyb28 with SMTP id 28so7917413wyb.19
        for <netdev@vger.kernel.org>; Thu, 02 Dec 2010 00:29:37 -0800 (PST)
In-Reply-To: <20101201.163319.193705748.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 1, 2010 at 19:33, David Miller wrote:
> Attached. =C2=A0Also please provide one of the failing ".config" file=
s,
> and please test if simply going "make oldconfig" unbreaks things.
> It may be that randconfig allows configurations that the config
> system normally does not allow.

hrm, so your patch does fix things.  the downside is that it might be
caused by kgdboe (which isnt in mainline yet).  that's the only
randconfig i can find so far to cause the issue.
-mike
