From: Mariusz Mazur <mmazur@kernel.pl>
Subject: Re: iproute2 and kernel headers
Date: Tue, 3 Aug 2004 19:14:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200408031914.40751.mmazur@kernel.pl>
References: <20040802153805.487f832f@dell_ss3.pdx.osdl.net> <20040803001459.GA8637@irc.pl> <20040803083142.5a4ccaad@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040803083142.5a4ccaad@dell_ss3.pdx.osdl.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On wtorek 03 sierpie=F1 2004 17:31, Stephen Hemminger wrote:
> > > I am willing to put some headers (not all) in with the user level
> > > code, provided they are copies since they I can easily update. I do=
n't
> > > want to get into keeping an edited set of headers in sync.
> >
> >  Aren't linux-libc-headers (*) sufficient?
> >
> > * - http://ep09.pld-linux.org/~mmazur/linux-libc-headers/
>
> The theory of that is good, but in practice it would make the problem
> worse. What iproute2 wants is to have the same kernel data structures a=
s
> the latest kernel. It is awkward enough making sure to get them from th=
e
> correct kernel sources, but doing it from a different package would mak=
e
> updating and keeping everything current worse.

This message was forwarded to me (I'm the llh maintainer). Llh is being=20
updated by generating a diff between incremental kernel releases, fixing =
that=20
diff and applying it to the last version of llh. I do have scripts to che=
ck=20
wether such an update doesn't break any headers. There is a slight=20
possibility that such an update might omit some crucial changes, but (at=20
least when it comes to network headers) co-developers of my distribution=20
(PLD) will most likely detect that allmost instantly and notify me what's=
=20
wrong (in such a case I will release a fixed version of llh asap).

Since removing all those glibc/linux-headers workarounds from=20
iproute2/iptables was quite a pain for me I would really like to see buil=
ding=20
against llh at least as an option available from 'configure'.
(In case you're wondering - yes, we've been building all the linux networ=
k=20
userland stuff against llh for about 8 months now without any problems...=
=20
quite the opposite actually)


--=20
In the year eighty five ten
God is gonna shake his mighty head
He'll either say,
"I'm pleased where man has been"
Or tear it down, and start again
