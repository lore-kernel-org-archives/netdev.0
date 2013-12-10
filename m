From: =?UTF-8?B?0JjQstCw0LnQu9C+INCU0LjQvNC40YLRgNC+0LI=?=
	<freemangordon@abv.bg>
Subject: Re: [PATCH v2 01/16] wl1251: fix scan behaviour while not associated
Date: Wed, 11 Dec 2013 00:16:58 +0200 (EET)
Message-ID: <1209321878.38095.1386713818964.JavaMail.apache@mail82.abv.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kvalo@adurom.com, pavel@ucw.cz, luca@coelho.fi,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	aaro.koskinen@iki.fi, sre@ring0.de, joni.lapilainen@gmail.com,
	johannes@sipsolutions.net, felipe.contreras@gmail.com,
	david.gnedt@davizone.at
To: =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  >-------- =D0=9E=D1=80=D0=B8=D0=B3=D0=B8=D0=BD=D0=B0=D0=BB=D0=BD=D0=BE=
 =D0=BF=D0=B8=D1=81=D0=BC=D0=BE --------
 >=D0=9E=D1=82:  Pali Roh=C3=A1r=20
 >=D0=9E=D1=82=D0=BD=D0=BE=D1=81=D0=BD=D0=BE: Re: [PATCH v2 01/16] wl12=
51: fix scan behaviour while not associated
 >=D0=94=D0=BE: Kalle Valo ,
 Pavel Machek=20
 >=D0=98=D0=B7=D0=BF=D1=80=D0=B0=D1=82=D0=B5=D0=BD=D0=BE =D0=BD=D0=B0: =
=D0=92=D1=82=D0=BE=D1=80=D0=BD=D0=B8=D0=BA, 2013, =D0=94=D0=B5=D0=BA=D0=
=B5=D0=BC=D0=B2=D1=80=D0=B8 10 19:08:44 EET
 >
 >
 >On Tuesday 10 December 2013 16:41:04 Kalle Valo wrote:
 >> Pavel Machek  writes:
 >> > ssids can have &#92;0s in them... and what is worse, they may
 >> > not be 0 terminated AFAICT.
 >> >=20
 >> > Potential solution is at
 >> > http://www.spinics.net/lists/linux-wireless/msg98640.html .
 >>=20
 >> I just use print_hex_dump_bytes() to print SSIDs.
 >
 >Ok and has kernel printf modifier for size_t?
 >
 >--=20
 >Pali Roh=C3=A1r
 >pali.rohar@gmail.com
 >

If I read lib/vsprintf.c correctly, you can use 'z'

Regards,
Ivo

PS: Please use my gmail address when cc-ing me, LKML really hates my ab=
v dot bg account :)
