From: Jeroen Massar <jeroen@unfix.org>
Subject: Re: (usagi-users 03249) Re: support of IPv6 by NFS
Date: Sun, 06 Mar 2005 16:40:13 +0100
Message-ID: <1110123613.24625.48.camel@firenze.zurich.ibm.com>
References: <42243F8D.5030302@bull.net>
	 <200503010744.38339.Info@Quantum-Sci.com>
	 <1109689712.17484.6.camel@firenze.zurich.ibm.com>
	 <20050306110442.GW30487@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-pC7KyXYB44plltdaJnHI"
Cc: netdev@oss.sgi.com
To: usagi-users@linux-ipv6.org
In-Reply-To: <20050306110442.GW30487@sunbeam.de.gnumonks.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-pC7KyXYB44plltdaJnHI
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2005-03-06 at 12:04 +0100, Harald Welte wrote:
>On Tue, Mar 01, 2005 at 04:08:32PM +0100, Jeroen Massar wrote:
>> >My experience is that IPV6 is extremely difficult to figure out how
>> >to set up securely, for the time being, due to lack of
>> >connection-sharing.
>>=20
>> NAT is not a firewall. Get that into your brain.
>
>oh, that was what he meant.  I wasn't familiar with the term 'connection
>sharing'. =20

That is the Windows term for it ;)

>I've stated numerous time that IPv6<->IPv6 NAT will only end up in
>netfilter/iptables over my dead body.

Hmmm..... then I guess that I'll have to kill you at some point ;)
But I'll leave it to printing out a kernel source and throwing it on
your casket in a year or 100 or so.

>IPv4<->IPv6 NAT-PT is a different issue, obviously.
>
>btw, the IETF BEHAVE group is actually demanding that a NAT device does
>not NAT ipv6 traffic!!

Doing the NAT as in the 'connection sharing', or better said, "rewriting
source/dest addresses and packet contents" is evil. But the other method
for which we are going to use a "translation of addresses", but on both
sides will be very interesting and will cost you your dead body <grin>.

>> And indeed there is no Linux firewalling code yet, in the mainstream
>> that can do connection tracking.=20
>
>still, ip6_conntrack is shipped by commercial distributions like SuSE...

There is nothing wrong with connection tracking as that can be used for
checking if a certain packet is allowed to come back into the firewall
or not, one of the basic principles of stateful firewalling

Greets,
 Jeroen


--=-pC7KyXYB44plltdaJnHI
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)
Comment: Jeroen Massar / http://unfix.org/~jeroen/

iD8DBQBCKyRdKaooUjM+fCMRAqe5AJ9+1cBxSpto5AE7bXgfEquJS6mIjwCfTqO8
6eMpfRgnxJbSqfGc18SQyYk=
=uq9A
-----END PGP SIGNATURE-----

--=-pC7KyXYB44plltdaJnHI--
