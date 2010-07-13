From: Ofer Heifetz <oferh@marvell.com>
Subject: RE: Splice status
Date: Tue, 13 Jul 2010 15:42:25 +0300
Message-ID: <EE71107DF0D1F24FA2D95041E64AB9E8ED254E7BAB@IL-MB01.marvell.com>
References: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>
 	<AANLkTimbVY2xhIiYXFvphajuZyn8_PJ0gOqf8VfW-NsM@mail.gmail.com>
 	<EE71107DF0D1F24FA2D95041E64AB9E8ED2541B66E@IL-MB01.marvell.com>
 	<1278334254.2877.158.camel@edumazet-laptop>
 <AANLkTim_eBmT-6HmkqG5d7k0jjrGKAFBjzqVCricTpgK@mail.gmail.com>
 	<1278388580.2466.305.camel@edumazet-laptop>
 <AANLkTinRnDwMOS5NrmzKqYZpczG4nfHSvKA9Gw-_UUzO@mail.gmail.com>
 	<EE71107DF0D1F24FA2D95041E64AB9E8ED254E7B66@IL-MB01.marvell.com>
 <AANLkTimRXMivugXHJswrT5FA93PIjSjU-RneFKs1bkLL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jens Axboe <axboe@kernel.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from galiil.marvell.com ([199.203.130.254]:51302 "EHLO
	galiil.marvell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755900Ab0GMMnr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 08:43:47 -0400
In-Reply-To: <AANLkTimRXMivugXHJswrT5FA93PIjSjU-RneFKs1bkLL@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Write and re-write numbers are in MBps.
Iozone performs re-write meaning reads a chunk of data and writes it ba=
ck, so basically the performance for this operation should be quiet hig=
h since kernel caches usage.

I forgot to mention that I used EXT4 fs.

-Ofer

-----Original Message-----
=46rom: Changli Gao [mailto:xiaosuo@gmail.com]=20
Sent: Tuesday, July 13, 2010 3:32 PM
To: Ofer Heifetz
Cc: Eric Dumazet; Jens Axboe; netdev@vger.kernel.org
Subject: Re: Splice status

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
