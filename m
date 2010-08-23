From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] iproute2: add 64bit support to ifstat
Date: Mon, 23 Aug 2010 22:28:31 +0200
Message-ID: <1282595311.2378.288.camel@edumazet-laptop>
References: <20100823083258.0777e83d@nehalam>
	 <1282578203.2267.27.camel@achroite.uk.solarflarecom.com>
	 <20100823091750.2bf87605@nehalam>
	 <1282582464.2486.479.camel@edumazet-laptop>
	 <20100823103333.67c5f795@nehalam>
	 <1282592696.2378.193.camel@edumazet-laptop>
	 <20100823130630.1dcb885b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50938 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754642Ab0HWU2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 16:28:35 -0400
Received: by wyb32 with SMTP id 32so7214568wyb.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 13:28:34 -0700 (PDT)
In-Reply-To: <20100823130630.1dcb885b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 23 ao=C3=BBt 2010 =C3=A0 13:06 -0700, Stephen Hemminger a =C3=A9=
crit :
> > @@ -563,8 +563,6 @@ static void usage(void)
> >  "   -s, --noupdate	don;t update history\n"
> >  "   -t, --interval=3DSECS	report average over the last SECS\n"
> >  "   -V, --version	output version information\n"
> > -"   -z, --zeros		show entries with zero activity\n"
> > -"   -e, --errors	show errors\n"
> >  "   -z, --zeros		show entries with zero activity\n");
> > =20
> >  	exit(-1);
> > @@ -581,8 +579,6 @@ static const struct option longopts[] =3D {
> >  	{ "interval", 1, 0, 't' },
> >  	{ "version", 0, 0, 'V' },
> >  	{ "zeros", 0, 0, 'z' },
> > -	{ "errors", 0, 0, 'e' },
> > -	{ "zeros", 0, 0, 'z' },
> >  	{ 0 }
> >  };
> > =20
> >=20
> >=20
>=20
> Did you mean to break --errors?

I dont think so.

These options are already handled, unless I am wrong.

Do you want a separate patch for this trivial fix ?


