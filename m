From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Network privilege separation.
Date: Mon, 12 Jan 2009 21:55:47 +0100
Message-ID: <20090112205547.GE23848@one.firstfloor.org>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <200901122215.27842.rdenis@simphalempin.com> <20090112203931.GD23848@one.firstfloor.org> <200901122230.25976.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>, Valdis.Kletnieks@vt.edu,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <rdenis@simphalempin.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757324AbZALUlq@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200901122230.25976.rdenis@simphalempin.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 12, 2009 at 10:30:25PM +0200, R=E9mi Denis-Courmont wrote:
> Le lundi 12 janvier 2009 22:39:31 Andi Kleen, vous avez =E9crit=A0:
> > > What's the point of writing a parser (that could also have bugs) =
when the
> >
> > Sorry you lost me. What do you mean with parser here?
> >
> > > kernel can do it?
> >
> > And what does it have to do with the kernel?
>=20
> The parser at the other end of the pipe. The more intricate the over-=
the-pipe=20
> protocol is, the more likely it is to be buggy and the security schem=
e to=20
> break.

That would be very little code that would also not=20
change very often so that it could be probably effectively
audited.

> > Yes it would be somewhat slower, but if it avoids a couple of secur=
ity
> > updates that would be probably worth it.
>=20
> If codecs did not care about performance, they'd be written in some h=
igh-level=20
> language that could easily be sandboxed by its own VM.

I don't think using a full JIT is anywhere comparable in=20
performance impact to adding two cache hot copies to=20
otherwise fully optimized code.

>=20
> As the guy who's been dealing with VLC security issues for the past t=
wo years,=20
> I have to say, I am in no way interested in SECCOMP as it _currently_=
 is.

=46air point, although I'm afraid you didn't do a very good
job explaining your reasons, so it sounds like a=20
quite arbitary decision.

-Andi

--=20
ak@linux.intel.com -- Speaking for myself only.
