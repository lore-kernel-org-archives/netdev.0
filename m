From: Mark Brown <broonie@kernel.org>
Subject: linux-next: build failure after merge of the akpm-current tree
Date: Fri, 13 Oct 2017 03:38:39 +0100
Message-ID: <20171013023839.tz2l22ked5jfgztw@sirena.co.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="fhj5ftztqkrlmtep"
Cc: netdev@vger.kernel.org,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Simon Horman <simon.horman@netronome.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--fhj5ftztqkrlmtep
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Andrew,

After merging the akpm-current tree, today's linux-next build
(x86 allmodconfig) failed like this:

  CC [M]  drivers/net/ethernet/netronome/nfp/nfp_app.o
In file included from /home/broonie/tmpfs/next/drivers/net/ethernet/netronome/nfp/nfp_asm.c:40:0:
/home/broonie/tmpfs/next/drivers/net/ethernet/netronome/nfp/nfp_asm.h: In function '__enc_swreg_lm':
/home/broonie/tmpfs/next/drivers/net/ethernet/netronome/nfp/nfp_asm.h:301:2: error: implicit declaration of function 'WARN_ON' [-Werror=implicit-function-declaration]
  WARN_ON(id > 3 || (off && mode != NN_LM_MOD_NONE));
  ^
cc1: some warnings being treated as errors

Caused by some reliance on an implicit include being exposed by a header
reorganization in your tree.  I'll add a patch for this which I'll post,
probably tomorrow morning.

--fhj5ftztqkrlmtep
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAlngJy4ACgkQJNaLcl1U
h9DZIQf/fhaZXsuRxlUVyjaIxtjuarqIHjhRksBH56e3CW6vCaSXCyWMLA/cJ6kK
vx5LWteEjD9cRnuIFJxHTF35/kiNJehNMm74eCPLqgBfoRHgcRn1FCEq8QAdOEG4
LN+esJFAiwgMQxsYzjGVpHQUFzKEpNt8E7CNZfnPLK/QV/tHuCkHckHsEtCynGm9
v6iYbsr2C53fmgE2D6BqqITRD8/TqxglrxIRYWBQBRN7CisQRXCYoOHhpYn7hajg
MwlNa+VyGkavkYV08vRmphoiULVS59lkqPjHP31NF+Acpxqaz4XW8ET5rejXvrPB
mGx9vuo+zW//uzHL2Xy1whhW9VpNVQ==
=2/eB
-----END PGP SIGNATURE-----

--fhj5ftztqkrlmtep--
