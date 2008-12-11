From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Subject: Re: [GIT]: Networking
Date: Thu, 11 Dec 2008 13:50:23 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0812111344580.10515@vixen.sonytel.be>
References: <20081208.000655.211323914.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Kernel Development <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vervifontaine.sonytel.be ([80.88.33.193]:40304 "EHLO
	vervifontaine.sonycom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755700AbYLKMuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 07:50:25 -0500
In-Reply-To: <20081208.000655.211323914.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Dec 2008, David Miller wrote:
> Here are the pending net fixes:
>=20
> 6) netlabel OOPS'er fix from Paul Moore.

> Paul Moore (1):
>       netlabel: Fix a potential NULL pointer dereference

This introduced:

| net/netlabel/netlabel_unlabeled.c:567: warning: 'entry' may be used u=
ninitialized in this function
| net/netlabel/netlabel_unlabeled.c:629: warning: 'entry' may be used u=
ninitialized in this function

which may still oops, if the uninitialized entry pointer is dereference=
d (in
case list_entry =3D=3D NULL).

With kind regards,

Geert Uytterhoeven
Software Architect

Sony Techsoft Centre Europe
The Corporate Village =B7 Da Vincilaan 7-D1 =B7 B-1935 Zaventem =B7 Bel=
gium

Phone:    +32 (0)2 700 8453
=46ax:      +32 (0)2 700 8622
E-mail:   Geert.Uytterhoeven@sonycom.com
Internet: http://www.sony-europe.com/

A division of Sony Europe (Belgium) N.V.
VAT BE 0413.825.160 =B7 RPR Brussels
=46ortis =B7 BIC GEBABEBB =B7 IBAN BE41293037680010
