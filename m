From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: AF_VSOCK loopback
Date: Mon, 14 Nov 2016 19:14:46 +0000
Message-ID: <20161114191446.GH1352@stefanha-x1.localdomain>
References: <20161110144329.GA19683@stefanha-x1.localdomain>
 <BY2PR0501MB20561F98987156779668ECB1DABB0@BY2PR0501MB2056.namprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="svZFHVx8/dhPCe52"
Cc: "cavery@redhat.com" <cavery@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Jorgen S. Hansen" <jhansen@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39376 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932343AbcKNTOs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 14:14:48 -0500
Content-Disposition: inline
In-Reply-To: <BY2PR0501MB20561F98987156779668ECB1DABB0@BY2PR0501MB2056.namprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--svZFHVx8/dhPCe52
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 11, 2016 at 02:14:44PM +0000, Jorgen S. Hansen wrote:
> Hi Stefan,
>=20
> All datagram communication in VMCI based AF_VSOCK is going through the ho=
st - also for loopback communication. The only difference wrt loopback is t=
hat the VMCI queue pairs implementing the shared queues for the stream prot=
ocols aren't registered with the hypervisor - they are created specifying t=
he VMCI_QPFLAG_LOCAL flag, and exist only as local guest memory.
>=20
> So in the current form, there isn't much loopback code in the vmci AF_VSO=
CK implementation, so it doesn't seem like there would be much to share eit=
her.

Thanks for clarifying.  I'm playing with a virtio-vsock implementation
of loopback and expect send patches later this week.

Stefan

--svZFHVx8/dhPCe52
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYKg0mAAoJEJykq7OBq3PIeUwH/2++zN9gubpi0F8YT1mhGgVm
gnOz6s1t+eF85+tYFEpKNOdDuEm1haYKtu3qOGIwSpDaqk5hYLqITTMmJnWSm/Ee
NM/YvitdzF8GD8O/OGARNP97vByFhzUq/mg0rG5zgxZmflCYz+DvBg0hrLK2Bhfg
8551vUZXjofl4flabR1sJy+OlAJM24m2zSvS9jfDPpcA8EptpqqKRn6QpQkEiKGF
ENWOWWFGQ4BuaqYy0ZAyw1d3zynzoASk6l7gMFuH0Het6qK15Sl8iMRG0yhcMHC8
wVAheCeKJkXe/zlu85W2ABHfbn4YwArFHk1CXLhXz8Cm/ekKZOmTUQMh1VryQW0=
=9N8J
-----END PGP SIGNATURE-----

--svZFHVx8/dhPCe52--
