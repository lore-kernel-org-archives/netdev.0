From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: Fw: throttling kernel messages: KERNEL: assertion (flags &
	MSG_PEEK) failed at net/ipv4/tcp.c (1282)
Date: Wed, 13 Apr 2005 09:50:19 +0200
Message-ID: <1113378620.3811.3.camel@nienna.balabit>
References: <20050412114148.66283c58.rddunlap@osdl.org>
	 <1113337130.3004.14.camel@krak.odu>  <20050412203950.GA9964@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: quoted-printable
Cc: "Randy.Dunlap" <rddunlap@osdl.org>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050412203950.GA9964@suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


  Hi,

2005-04-12, k keltez=E9ssel 22.39-kor Olaf Kirch ezt =EDrta:
> >   I also hit these assertions today. In my case it was probably becau=
se
> > of a slab corruption problem caused by the e100 driver. (I had
> > CONFIG_DEBUG_SLAB enabled, so a lot of slab corruption messages appea=
red
> > right before these assertion errors.)
>=20
> Yes, we've seen these symptoms in various bug reports in various 2.6
> versions, and after some debugging narrowed it down to an e100 driver
> issue. It went away with 2.6.11 final.

  For me it definitely did not go away with 2.6.11. However, as soo as I
applied e100-napi-fixes.patch the problem magically disappeared. So I
suspect this NAPI state machine problem might have been the culprit.

--=20
 Regards,
  Krisztian Kovacs
