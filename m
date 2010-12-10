From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Link directly to the archive files rather than using
 search paths.
Date: Thu, 9 Dec 2010 17:56:44 -0800
Message-ID: <20101209175644.00feca1d@nehalam>
References: <1291942572-12653-1-git-send-email-flameeyes@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Daniel Kurtz <djkurtz@google.com>,
	Mike Frysinger <vapier@gentoo.org>
To: Diego Elio =?ISO-8859-1?B?UGV0dGVu8g==?= <flameeyes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36565 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752288Ab0LJB4r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 20:56:47 -0500
In-Reply-To: <1291942572-12653-1-git-send-email-flameeyes@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Dec 2010 01:56:12 +0100
Diego Elio Petten=F2 <flameeyes@gmail.com> wrote:

> While the previous code was supposed to work nonetheless, it could be
> messed up if further -L were used in LDFLAGS to list the path where g=
libc's
> libutil was to be found.
>=20
> References: https://bugs.gentoo.org/347489
>=20
> CC: Daniel Kurtz <djkurtz@google.com>
> CC: Mike Frysinger <vapier@gentoo.org>
> Signed-off-by: Diego Elio Petten=F2 <flameeyes@gmail.com>
> ---
>  Makefile |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
>=20
> diff --git a/Makefile b/Makefile
> index c03d74c..d1ace1f 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -33,11 +33,10 @@ CCOPTS =3D -D_GNU_SOURCE -O2 -Wstrict-prototypes =
-Wall
>  CFLAGS =3D $(CCOPTS) -I../include $(DEFINES)
>  YACCFLAGS =3D -d -t -v
> =20
> -LDLIBS +=3D -L../lib -lnetlink -lutil
> -
>  SUBDIRS=3Dlib ip tc misc netem genl
> =20
>  LIBNETLINK=3D../lib/libnetlink.a ../lib/libutil.a
> +LDLIBS +=3D $(LIBNETLINK)
> =20
>  all: Config
>  	@set -e; \

Please be more clear in your subject, yes I can tell this is for
iproute utilities but others may not.

When refering to "previous code" either reply to the original
message thread or provide a link to the changes.

--=20
