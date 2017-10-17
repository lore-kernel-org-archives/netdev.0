From: Mark Brown <broonie@kernel.org>
Subject: linux-next: net/sched/sch_mqprio.c
Date: Tue, 17 Oct 2017 11:43:41 +0100
Message-ID: <20171017104341.kxrjb67k3rf65lf3@sirena.co.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="j42roriwt27myzux"
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--j42roriwt27myzux
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi all,

After merging the net-next tree, today's linux-next build (KCONFIG_NAME)
failed like this:

ERROR: "netdev_txq_to_tc" [net/sched/sch_mqprio.ko] undefined!
/home/broonie/tmpfs/next/scripts/Makefile.modpost:91: recipe for target '__modpo
st' failed

Caused by commit

  32302902ff093 ("mqprio: Reserve last 32 classid values for HW traffic classes and misc IDs")

which adds a user of that function in a module but that function is not
exported.  As noted on the previous report reverting to a previous
net-next caused other errors so I've reverted that specific commit.

--j42roriwt27myzux
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAlnl3twACgkQJNaLcl1U
h9CO6gf/XjPr7rCQrTPzZxrlFGJVEGSpYRAOe/qVKVx7m8bwRuLYfe/UlcNlazcq
WuMfT3reY1XTn8HcEDcS8ehgqwCdxCvdrPjIdnlxKnpsfqqCgyQBcf9pLv3sbUWM
92lc1ZNx77QRB7yEdxyvyGV/5cWDia6FmPfnqCkTJIZj+OsSe97uYOwZEqmRYP1b
j9c7H8r72j4qcwKKeiEFJzbXDANzX8AOqfP7iXi93n5tR3kR11u219ey9xUsBuxH
ftXXh696PUs6+wcHegywGhavoDiuuLDZPfR9e03b6+3oK8xeIQKh78CxV33VcSUI
RioFi8cFNzyp6dFVqGDbPy8Z13JUwg==
=oIh/
-----END PGP SIGNATURE-----

--j42roriwt27myzux--
