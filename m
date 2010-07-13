From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Splice status
Date: Tue, 13 Jul 2010 20:32:17 +0800
Message-ID: <AANLkTimRXMivugXHJswrT5FA93PIjSjU-RneFKs1bkLL@mail.gmail.com>
References: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>
	<AANLkTimbVY2xhIiYXFvphajuZyn8_PJ0gOqf8VfW-NsM@mail.gmail.com>
	<EE71107DF0D1F24FA2D95041E64AB9E8ED2541B66E@IL-MB01.marvell.com>
	<1278334254.2877.158.camel@edumazet-laptop> <AANLkTim_eBmT-6HmkqG5d7k0jjrGKAFBjzqVCricTpgK@mail.gmail.com>
	<1278388580.2466.305.camel@edumazet-laptop> <AANLkTinRnDwMOS5NrmzKqYZpczG4nfHSvKA9Gw-_UUzO@mail.gmail.com>
	<EE71107DF0D1F24FA2D95041E64AB9E8ED254E7B66@IL-MB01.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jens Axboe <axboe@kernel.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ofer Heifetz <oferh@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:38045 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754787Ab0GMMci convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 08:32:38 -0400
Received: by vws5 with SMTP id 5so5741210vws.19
        for <netdev@vger.kernel.org>; Tue, 13 Jul 2010 05:32:37 -0700 (PDT)
In-Reply-To: <EE71107DF0D1F24FA2D95041E64AB9E8ED254E7B66@IL-MB01.marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 13, 2010 at 7:41 PM, Ofer Heifetz <oferh@marvell.com> wrote=
:
> Hi,
>
> I wanted to let you know that I have been testing Samba splice on Mar=
vell 6282 SoC on 2.6.35_rc3 and noticed that it gave worst performance =
than not using it and also noticed that on re-writing file the iowait i=
s high.
>
> iometer using 2G file (file is created before test)
>
> Splice =A0write cpu% iow%
> -----------------------
> =A0No =A0 =A0 58 =A0 =A098 =A0 =A00
> Yes =A0 =A0 14 =A0 100 =A0 48
>
> iozone using 2G file (file created during test)
>
> Splice =A0write cpu% iow% =A0re-write cpu% iow%
> -------------------------------------------
> =A0No =A0 =A0 35 =A0 =A085 =A0 =A04 =A0 =A058.2 =A0 =A0 70 =A0 =A00
> Yes =A0 =A0 33 =A0 =A085 =A0 =A04 =A0 =A015.7 =A0 =A0100 =A0 58
>
> Any clue why splice introduces a high iowait?
> I noticed samba uses up to 16K per splice syscall, changing the samba=
 to try more did not help, so I guess it is a kernel limitation.
>
> -Ofer
>

What does the column write means? And what do you mean by saying
re-write? Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
