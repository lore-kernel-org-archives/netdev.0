From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: AlacrityVM numbers updated for 31-rc4
Date: Fri, 14 Aug 2009 15:50:16 -0400
Message-ID: <4A85BFF8.4050001@gmail.com>
References: <4A83296B.3080606@gmail.com> <4A834ABB.4010801@codemonkey.ws> <4A834E75.9060204@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigB8A32634A7D2FE7E2865A6AD"
Cc: alacrityvm-devel@lists.sourceforge.net,
	alacrityvm-users@lists.sourceforge.net,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A834E75.9060204@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigB8A32634A7D2FE7E2865A6AD
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Gregory Haskins wrote:
> Anthony Liguori wrote:
>> Gregory Haskins wrote:
>>> I re-ran the numbers on 10GE against the actual alacrityvm v0.1 relea=
se
>>> available in git on kernel.org.
>>>
>>> I tried to include the newly announced "vhost" driver (Michael Tsirki=
n)
>>> for virtio acceleration, but ran into issues getting the patches to
>>> apply.
>>>
>>> For now, this includes native, virtio-u (virtio-userspace), and venet=

>>> all running on 31-rc4.  If I can resolve the issue with Michaels
>>> patches, I will add "virtio-k" (virtio-kernel) to the mix as well.  F=
or
>>> now, here are the results for 1500mtu:
>>>
>>> native:   7388Mb/s,   29.8us rtt (33505 tps udp-rr)
>>> venet:    3654Mb/s,   56.8us rtt (17600 tps udp-rr)
>>> virtio-u: 1955Mb/s, 4016.0us rtt (  249 tps udp-rr)
>>>  =20

I re-ran the numbers now that I have the HRT issue straighted out.
Native and virtio stayed level, venet recovered from the 3.6Gb/s
quagmire it was in, back up to ~4.5Gb/s.

native (hw):        7388Mb/s,  29.8us rtt (33500 tps udp-rr)
venet (alacrityvm): 4560Mb/s,  56.8us rtt (17600 tps udp-rr)
virtio-u (kvm):	    2670Mb/s, 265.7us rtt ( 3764 tps udp-rr)
virtio-k (kvm):     d-n-f

(still having problems getting vhost to run).  Will try again next week.)=


I have updated the graphs on the wiki:

http://developer.novell.com/wiki/index.php/AlacrityVM

Have a nice weekend, all.

-Greg



--------------enigB8A32634A7D2FE7E2865A6AD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqFv/gACgkQP5K2CMvXmqFcXgCfT52V4e1EbrAABQE+iEQ555Y2
IyIAnjMN86tNj6Eg0A9R3nV/6mptq44o
=s0Cf
-----END PGP SIGNATURE-----

--------------enigB8A32634A7D2FE7E2865A6AD--
