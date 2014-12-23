From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v3 1/3] igb: Add igb_disable_sriov in error handling
Date: Tue, 23 Dec 2014 06:03:13 -0800
Message-ID: <1419343393.2470.14.camel@jtkirshe-mobl>
References: <1419319024-30455-1-git-send-email-baijiaju1990@163.com>
	 <54995097.8090105@cogentembedded.com> <54996CAB.7080007@163.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-WdlZqi/ly0AAXSQZgnAp"
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	davem@davemloft.net, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, linux.nics@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:6487 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754872AbaLWODQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Dec 2014 09:03:16 -0500
In-Reply-To: <54996CAB.7080007@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-WdlZqi/ly0AAXSQZgnAp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-12-23 at 21:22 +0800, Jia-Ju Bai wrote:
> On 12/23/2014 07:23 PM, Sergei Shtylyov wrote:
> > Hello.
> >
> > On 12/23/2014 10:17 AM, Jia-Ju Bai wrote:
> >
> >> For linux-3.18.0
> >
> >    For the future: such words should be placed under --- tear line...
> >
> >> The driver lacks igb_disable_sriov in error handling,
> >> which should match igb_enable_sriov in igb_probe.
> >> This patch fixes this problem, and it has been tested in runtime.
> >
> >> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
> >> ---
> >
> >    .... here.
> >
> >>   drivers/net/ethernet/intel/igb/igb_main.c |    4 ++++
> >>   1 file changed, 4 insertions(+)
> >
> > WBR, Sergei
> >
>=20
> Thanks. ^_^
> I see that most patches in netdev mailing list do not mention the linux
> kernel version, so is it necessary to write the version in the patch?
>=20

No it is not.  If you were sending a patch (which has already been
accepted upstream) to the stable trees, then you would specify what
stable kernels the patch applies to.  In your case, I would not consider
your patches critical for the stable trees.

So when sending patches, you inform the maintainer (i.e. me) what tree
you want your patch applied by stating either "net" or "net-next" in the
title.  For example, this patch would be titled:

[net v3 1/3] igb: Add igb_disable_sriov in error handling

Which lets me know you want your patch applied to the "net" tree.  If it
were not a fix, then it would go into the "net-next" tree by using the
title:

[net-next v3 1/3] igb: Add igb_disable_sriov in error handling

--=-WdlZqi/ly0AAXSQZgnAp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUmXYhAAoJEOVv75VaS+3O478P/Rs924pEvTcb8OTL4LUBfQ1r
Q55GqP//iIYDdJulPl5gajJh2wcEP+iggB6vJPgN2CnbfN5gHQRuoEYMBrjEQtJV
i34GxGwrUpClMRZWJsq6GAkv3yP2crgBwsyu3Q57Niu2Wy13ZmptrOdY4yRN7LPD
Uu/WYAhDtPotXaYk49DNMaR/gmt7hVmlk/fReUsryqrRfFCljQGrqLgmBSgb8d/m
4ZrspEqnatdeKXj8LXlyBKiWcB1mD7Qf87wX47Pf9clYUJNBdtZrA22CExuKP3qn
ytyD3XidqrReixi7Ty6nN2AKkGrCdBfi+I2hsWJZot/NRI+F35JcIYbgjY4dwWzl
k3biTPp1tfScPUTfhaMpk5aRH55Aq+q/3uhLksSiZea6EE/hoHPD9xKX4CKy3vUw
UQyS7+9wHnprM3mffuD6LegyixDxzMgrdo1IZBY1/7/Ip4362M3rLdluWEync93m
RBkRIfCBMchGlgJH64MNcCGpRPUZkH/8H+Pad9V2NTitqSIt79jC4KHN7ENLzPQ4
AAmkb7SxHh9BnOXptMPs46NNyqUN776VPirgKWv5YyKMfdnL8um821ghZ2yU9MK/
m3Ls2iCQm1McC3cCAlLsePtyJPHuHdPwa3F384O5vHO+BX6ukYyOf/BloTbgmzcM
1bNZ8VivsBlrbQ8ZOF9X
=9lVI
-----END PGP SIGNATURE-----

--=-WdlZqi/ly0AAXSQZgnAp--
