From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: [PATCH] reduce stack usage for arlan
Date: Wed, 18 May 2005 14:20:43 +0200
Message-ID: <20050518122043.GA28800@wohnheim.fh-wedel.de>
References: <20050308153457.GB8703@wohnheim.fh-wedel.de> <428811FB.1050308@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <428811FB.1050308@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 15 May 2005 23:22:35 -0400, Jeff Garzik wrote:
> J=F6rn Engel wrote:
> >Jean Tourrilhes indicated that this driver is currently unmaintained.
> >Jeff, do you want this patch?
>=20
> > #define SARLSTR(var,nn) {\
> >-	char tmpStr[400];\
> >+	char tmpStr[50];\
> > 	int  tmpLn =3D nn;\
> >-	if (nn > 399 ) tmpLn =3D 399; \
> >+	BUG_ON(tmpLn > 49);\
>=20
> I'm uncomfortable with arbitrarily lowering the string size, even if it=
=20
> does include a BUG_ON()...

Here are all invocations of the macro in question:
        SARLSTR(textRegion, 48);
        SARLSTR(name, 16);

Still uncomfortable?

J=F6rn

--=20
Those who come seeking peace without a treaty are plotting.
-- Sun Tzu
