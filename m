From: Jeroen Massar <jeroen@unfix.org>
Subject: Re: (usagi-users 03222) Re: support of IPv6 by NFS
Date: Tue, 01 Mar 2005 16:08:32 +0100
Message-ID: <1109689712.17484.6.camel@firenze.zurich.ibm.com>
References: <42243F8D.5030302@bull.net>
	 <200503010744.38339.Info@Quantum-Sci.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-CXIFG70UQeVul0i4ytiq"
Cc: netdev@oss.sgi.com
To: usagi-users@linux-ipv6.org
In-Reply-To: <200503010744.38339.Info@Quantum-Sci.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-CXIFG70UQeVul0i4ytiq
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2005-03-01 at 07:44 -0600, Quantum Scientific wrote:=20
>On Tuesday 01 March 2005 4:10, Gilles Quillard wrote:
>> This works but this needs that the kernel has been compiled with IPv6,=20
>> which is not mandotary. A lot of people in the Linux community do not=20
>> have experience with IPv6 yet and are not ready to use it. So making it=20
>> mandatory for NFS, even in a pure IPv4 network, is not easy.
>
>My experience is that IPV6 is extremely difficult to figure out how to set=
 up=20
>securely, for the time being, due to lack of connection-sharing.

NAT is not a firewall. Get that into your brain.

And indeed there is no Linux firewalling code yet, in the mainstream
that can do connection tracking. There is no non-EFT Cisco PIX code for
this either. The only OS that can do it is the various BSD's.

>And 80% of potential users are behind a cable/DSL 4 NATting router.  There=
 is=20
>no clarity that it is possible overcome this by either setting to DMZ, or=20
>hoping your cablemodem passes protos 41, 50 & 51.  Even some tunnel operat=
ors=20
>do not know this, so I had to figure it out myself.

Freenet6/Hexago have a UDP protocol and SixXS has AYIYA. Works perfectly
fine.

In most cases, I know from quite a bit of experience, proto-41
forwarding works very well in most of these DSL boxes.

> There is no Linux 6to4=20
>UDP tunnelling app, but there should be, because this is such a common=20
>problem.  (As I understand, Teredo is Winduhs-only, and is not supported b=
y=20
>most tunnel operators)

The protocol for Teredo is open and can be implemented at will:

http://www-rp.lip6.fr/teredo/
http://www.simphalempin.com/dev/miredo
http://people.via.ecp.fr/~rem/miredo/?C=3DN;O=3DD

First couple of hits when doing a google on "Teredo BSD", or for you to
click as that might be difficult:
http://www.google.com/search?q=3Dteredo+bsd

>And frankly, most Linux users' only contact with IPV6 has been the DNS AAA=
A=20
>browser delay seemingly inherent in some distros.  Although I realize that=
=20
>all of us who run Linux are ostensibly uber-gurus, fact is this is a negat=
ive=20
>first experience for most, stemming from attempts by distros to encourage =
ppl=20
>to use it with an inoperative function, and without an obvious way to=20
>troubleshoot/repair.

I can clearly assume that you are not part of the 'ostensibly
uber-gurus' you try to mention.=20
>
>These issues contradict assertions that IPV6 is beneficial and easy.

That you don't understand it is your problem ;)

>If I=20
>didn't have a strong motivation and lots of time, I would have chucked=20
>early-on.  Speaking the actual truth, not propaganda or spin, leads to=20
>understanding of the *real* world.

Loads of people seem to have no problem at all with IPv6, getting it up
and running and actually using it for a lot of traffic.
That fact that you are only complaining, without doing any actual
research, typing two words in google, says enough. You are not even
capable of configuring your mailer properly to include your own name,
the field is not called "Realname" for nothing...

Greets,
 Jeroen


--=-CXIFG70UQeVul0i4ytiq
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)
Comment: Jeroen Massar / http://unfix.org/~jeroen/

iD8DBQBCJIVwKaooUjM+fCMRAkLoAJ9m855fpWBV+bmKxXeM6dUWnhlIfgCdF/ei
uKA8xiFscO2H3ZlT2IMQceo=
=HzTF
-----END PGP SIGNATURE-----

--=-CXIFG70UQeVul0i4ytiq--
