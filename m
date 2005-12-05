From: Jeroen Massar <jeroen@unfix.org>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Mon, 05 Dec 2005 23:48:52 +0100
Message-ID: <4394C3D4.9050909@unfix.org>
References: <200512022253.19029.a1426z@gawab.com> <200512031646.45332.a1426z@gawab.com> <4391E4FC.1040200@candelatech.com> <20051205140057.GC24764@tuxdriver.com> <20051205174010.GA14101@buici.com> <43947FEB.7020504@unfix.org> <4394BCD5.1060505@psc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC46EFF0C5809647D67F78F65"
Cc: Marc Singer <elf@buici.com>, Ben Greear <greearb@candelatech.com>,
	Al Boldi <a1426z@gawab.com>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <4394BCD5.1060505@psc.edu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC46EFF0C5809647D67F78F65
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

John Heffner wrote:
> Jeroen Massar wrote:
>> I wonder how many RFC's it violates. An interface must only answer ARP=
's
>> on the interface that it is configured on, not anything else.
>=20
> Not true.  See RFC 1122, section 3.3.4.  The standard leaves this
> decision up to the implementation, for good reason.

RFC1122 is a document about multicast. ARP is broadcast see the very old
 RFC826/STD0037. Multicast didn't even work on much of the hardware from
the times that that document was written.

Probably the best text about this subject can be found in RFC1027:
8<-----------
2.4  Sanity checks

    Care must be taken by the network and gateway administrators to keep
    the network masks the same on all the subnet gateway machines.  The
    most common error is to set the network mask on a host without a
    subnet implementation to include the subnet number.  This causes the
    host to fail to attempt to send packets to hosts not on its local
    subnet.  Adjusting its routing tables will not help, since it will
    not know how to route to subnets.

    If the IP networks of the source and target hosts of an ARP request
    are different, an ARP subnet gateway implementation should not
    reply.  This is to prevent the ARP subnet gateway from being used to
    reach foreign IP networks and thus possibly bypass security checks
    provided by IP gateways.
-------------->8

Which is almost the same as what I noted. Note that the document is
about Proxy ARP, when a host is responding ARP queries for an IP on a
different link, this is exactly what it is doing: proxy arp.

> This topic has been discussed many times on a variety of mailing lists.=

>  I think the best way to do this is to make the behavior configurable,
> which Linux currently does.

As long as the default is off I am fine with it, people turning it on
themselves break their own network :)

Greets,
 Jeroen


--------------enigC46EFF0C5809647D67F78F65
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (MingW32)
Comment: Jeroen Massar / http://unfix.org/~jeroen/

iD8DBQFDlMPUKaooUjM+fCMRAszvAJ0QDxoF8neV1hqZX/pa3i1nsdnGOgCgiFOT
XZXkiNTC0mQ5OHTydnhBRu8=
=FnLj
-----END PGP SIGNATURE-----

--------------enigC46EFF0C5809647D67F78F65--
