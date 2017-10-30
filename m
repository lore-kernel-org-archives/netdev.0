From: Mark Brown <broonie@kernel.org>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Mon, 30 Oct 2017 17:08:42 +0000
Message-ID: <20171030170842.p3duxkziyrp7atxy@sirena.co.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="nnqabvrp2gct7gj3"
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from heliosphere.sirena.org.uk ([172.104.155.198]:49072 "EHLO
        heliosphere.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932352AbdJ3RIs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 13:08:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nnqabvrp2gct7gj3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  kernel/bpf/sockmap.c

between commit:

  bfa640757e9378c ("bpf: rename sk_actions to align with bpf infrastructure=
")

=66rom Linus' tree and commit:

  6aaae2b6c4330a4 ("bpf: rename bpf_compute_data_end into bpf_compute_data_=
pointers")

=66rom the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

diff --cc kernel/bpf/sockmap.c
index 66f00a2b27f4,eef843c3b419..000000000000
--- a/kernel/bpf/sockmap.c
+++ b/kernel/bpf/sockmap.c

--nnqabvrp2gct7gj3
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAln3XJoACgkQJNaLcl1U
h9Cf7gf/SOW9M8fDdkDUoA1S8/5wjdhv7NC0Kl4b5EaubY6vjJ4bb7d6CLMyzhvT
USpDA6DC5zIMXJPXA/WfEXRMfgLswax9yvlCdoFI/rQe4HTJCFhowLIVG5gWRoim
IAvberqrTiaWuLE9flRpNHekPAwiWOjOosRSBne9bhPtlz0Ex33i4l8n0kCHLK09
tFJkz2bb619CDVqla+Ekxm6VXjy3pDCjuSB+yFFs5njqH6/qIMrtmIAr6aAeGEq/
j7ygxpfhtYEgxi8DQAaGY+773GpWQuvQ11kl0h+nrcGGBpjcs2GGgEmgPWFVIO/Z
PBykEcdEAb3K0BMXgT1lVqOJt7eeeA==
=ST2t
-----END PGP SIGNATURE-----

--nnqabvrp2gct7gj3--
