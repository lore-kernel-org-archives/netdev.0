From: Mark Brown <broonie@kernel.org>
Subject: Re: linux-next: net/sched/cls_flower.c
Date: Tue, 17 Oct 2017 11:27:51 +0100
Message-ID: <20171017102751.wpwiyh72daobyicj@sirena.co.uk>
References: <20171017101509.soy55d4ipx3dusbo@sirena.co.uk>
 <20171017102107.GF2112@nanopsycho>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="zfplr4y6xiwnwtyq"
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Jiri Pirko <jiri@mellanox.com>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171017102107.GF2112@nanopsycho>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--zfplr4y6xiwnwtyq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Oct 17, 2017 at 12:21:07PM +0200, Jiri Pirko wrote:
> Tue, Oct 17, 2017 at 12:15:09PM CEST, broonie@kernel.org wrote:

> >/home/broonie/tmpfs/next/net/sched/cls_flower.c:270:27: error: 'struct cls_fl_filter' has no member named 'hw_dev'
> >  cls_flower.egress_dev = f->hw_dev != tp->q->dev_queue->dev;

> This fix ("net/sched: cls_flower: Set egress_dev mark when calling into the HW driver")
> went to -net tree, should not go to -next. Apparently there is some mixup.
> DaveM?

The issue is that:

> >  7578d7b45ed870b1 ("net: sched: remove unused tcf_exts_get_dev helper and cls_flower->egress_dev")

> >both in the net-next tree.  Falling back to previous net-next trees
> >introduced other issues so I reverted that commit for today.

the removal happened in the net-next tree, breaking the commit that was
previously introduced in the net tree (sorry, didn't notice that the
immediate commit was in there not net-next).

--zfplr4y6xiwnwtyq
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAlnl2yYACgkQJNaLcl1U
h9BCpwf/bQ3tV8Z9pFFXIhXKWnPDGYYS2WmW0dBJOVWexIHWdacBSSZVZFdCPt2l
Zh3K3Ij0qUGrAWTAxgH74+98b/dTi88YAEGsx5KCoayvljrN4ycI27bAinOdamQ/
rxuW4XliRU4XVRTPa5p1b9H8oxtGAYp1t/e+/iRQPHL8BiPnYFtXfLpXBJY5uZeI
KWTGKQYpSVctMWh2nFTuAEbcK4xfNxCzMc+Xccv0jsT2PT/V1u8Zt6kGDdGYFCXI
zn48+SyyMJI93KuxwBw8bI0T1CUEjCZ74R2SjTANkBw5G/doQoEe71kQp70/aiF4
YESMDI/jpjsVUFOFo1/733ThhXbobw==
=asou
-----END PGP SIGNATURE-----

--zfplr4y6xiwnwtyq--
