From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] OpenBSD Networking-related randomization port
Date: Fri, 28 Jan 2005 10:18:25 -0800
Message-ID: <20050128101825.388990a0@dxpl.pdx.osdl.net>
References: <1106932637.3778.92.camel@localhost.localdomain>
	<20050128174046.GR28047@stusta.de>
	<1106934475.3778.98.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lorenzo =?ISO-8859-1?B?SGVybuFuZGV6IEdhcmPtYS1IaWVycm8=?=
 <lorenzo@gnu.org>
In-Reply-To: <1106934475.3778.98.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 Jan 2005 18:47:55 +0100
Lorenzo Hern=E1ndez Garc=EDa-Hierro <lorenzo@gnu.org> wrote:

> El vie, 28-01-2005 a las 18:40 +0100, Adrian Bunk escribi=F3:
> > On Fri, Jan 28, 2005 at 06:17:17PM +0100, Lorenzo Hern=E1ndez Garc=ED=
a-Hierro wrote:
> > >...
> > > As it's impact is minimal (in performance and development/maintenan=
ce
> > > terms), I recommend to merge it, as it gives a basic prevention for=
 the
> > > so-called system fingerprinting (which is used most by "kids" to kn=
ow
> > > how old and insecure could be a target system, many time used as th=
e
> > > first, even only-one, data to decide if attack or not the target ho=
st)
> > > among other things.
> > >...
> >=20
> > "basic prevention"?
> > I hardly see how this patch makes OS fingerprinting by e.g. Nmap=20
> > impossible.
>=20
> That's an example, as you can find at the grsecurity handbook [1]:
>=20
> "The default Linux TCP/IP-stack has some properties that make it more
> vulnerable to prediction-based hacks. By randomizing several items,
> predicting the behaviour will be a lot more difficult."

No it just changes the fingerprint table.  "Hmm, this looks like a
newer generation system, must be OpenBSD or Linux".

> "Randomized IP IDs hinders OS fingerprinting and will keep your machine
> from being a bounce for an untraceable portscan."
>=20
> References:
>  [1]: http://www.gentoo.org/proj/en/hardened/grsecurity.xml

This is a very transitory effect, it works only because your machine
is then different from the typical Linux machine; therefore the scanner
will go on to the next obvious ones. But if this gets incorporated widely
then the rarity factor goes away and this defense becomes useless.

--=20
Stephen Hemminger	<shemminger@osdl.org>
