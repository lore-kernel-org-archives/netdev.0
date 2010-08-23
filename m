From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: add 64bit support to ifstat
Date: Mon, 23 Aug 2010 13:39:49 -0700
Message-ID: <20100823133949.3e160d07@nehalam>
References: <20100823083258.0777e83d@nehalam>
	<1282578203.2267.27.camel@achroite.uk.solarflarecom.com>
	<20100823091750.2bf87605@nehalam>
	<1282582464.2486.479.camel@edumazet-laptop>
	<20100823103333.67c5f795@nehalam>
	<1282592696.2378.193.camel@edumazet-laptop>
	<20100823130630.1dcb885b@nehalam>
	<1282595311.2378.288.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44825 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753966Ab0HWUjw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 16:39:52 -0400
In-Reply-To: <1282595311.2378.288.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Aug 2010 22:28:31 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le lundi 23 ao=FBt 2010 =E0 13:06 -0700, Stephen Hemminger a =E9crit =
:
> > > @@ -563,8 +563,6 @@ static void usage(void)
> > >  "   -s, --noupdate	don;t update history\n"
> > >  "   -t, --interval=3DSECS	report average over the last SECS\n"
> > >  "   -V, --version	output version information\n"
> > > -"   -z, --zeros		show entries with zero activity\n"
> > > -"   -e, --errors	show errors\n"
> > >  "   -z, --zeros		show entries with zero activity\n");
> > > =20
> > >  	exit(-1);
> > > @@ -581,8 +579,6 @@ static const struct option longopts[] =3D {
> > >  	{ "interval", 1, 0, 't' },
> > >  	{ "version", 0, 0, 'V' },
> > >  	{ "zeros", 0, 0, 'z' },
> > > -	{ "errors", 0, 0, 'e' },
> > > -	{ "zeros", 0, 0, 'z' },
> > >  	{ 0 }
> > >  };
> > > =20
> > >=20
> > >=20
> >=20
> > Did you mean to break --errors?
>=20
> I dont think so.
>=20
> These options are already handled, unless I am wrong.
>=20
> Do you want a separate patch for this trivial fix ?

I'll tweak your previous patch
--=20
