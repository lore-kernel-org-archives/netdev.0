From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH|RFC] IPv6: have a proxy discard link-local traffic
Date: Wed, 28 Jan 2004 09:13:48 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0401280913220.29988@rhea.tcs.hut.fi>
References: <Pine.LNX.4.44.0401280725370.14588-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable
Cc: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>,
        davem@redhat.com, usagi-core@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0401280725370.14588-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 28 Jan 2004, Pekka Savola wrote:

> On Wed, 28 Jan 2004, YOSHIFUJI Hideaki / [iso-2022-jp] =B5=C8=C6=A3=B1=D1=
=CC=C0 wrote:
> > In article <Pine.LNX.4.58.0401272259160.28384@rhea.tcs.hut.fi> (at Tu=
e, 27 Jan 2004 23:11:20 +0200 (EET)), Ville Nuorvala <vnuorval@tcs.hut.fi=
> says:
> > > +	/* The proxying router can't forward traffic sent to a link-local
> > > +	   address, so signal the sender and discard the packet. This
> > > +	   behavior is required by the MIPv6 specification. */
> >
> > Would you please clarify the word "can't" and its reasons?
> > won't? don't? or whatever?
>
> I think "can't" in this context means, "it can't be _forwarded_
> because it's link-local".  It could be proxied using some other
> function than ip6_forward, though.

Yes.

--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
