From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v10 07/22] IB/hns: Add event queue support
Date: Wed, 29 Jun 2016 13:41:32 +0300
Message-ID: <20160629104132.GA4750@leon.nu>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-8-git-send-email-oulijun@huawei.com>
 <20160624154643.GG23995@leon.nu>
 <57738C93.8010900@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="d6Gm4EdcadzBjdND"
Cc: Doug Ledford <dledford@redhat.com>, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, jiri@mellanox.com,
	ogerlitz@mellanox.com, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gongyangming@huawei.com, xiaokun@huawei.com,
	tangchaofei@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	charles.chenxin@huawei.com, linuxarm@huawei.com
To: oulijun <oulijun@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57738C93.8010900@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--d6Gm4EdcadzBjdND
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 29, 2016 at 04:53:39PM +0800, oulijun wrote:

> >> +
> >> +	for (i =3D 0; i < npages; ++i)
> >> +		if (eq->buf_list[i].buf)
> >=20
> > Is it possible situation to have eq->buf_list[i].buf =3D=3D NULL at the
> > middle of iteration?
> >=20
> We have analysized it according to your reivews. We think that the eq->bu=
f_list[i].buf
> is not NULL at the middle of iteration because only the eq->buf_list[i].b=
uf allocated
> when the hns_roce_free_eq be called. As result, the if (eq->buf_list[i].b=
uf) condition
> should be deleted, right?

Yes, please.

--d6Gm4EdcadzBjdND
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXc6XcAAoJEORje4g2clin5v4QAIF3qjR9DawFIhqhRfiE5LFj
LyP18yH69N7oUMDhaRSLKz5HhxFpTZlaVyU96d2isp4ec2vgNg+GYBFROiAZHtfK
PZEJhyLNrEK4a7Fvkx5NxXLJFiJ8BfFpRlnh3YpM/vCzblkGxJLwYlMnMpql43ag
QJCCNyorUhRuFkmUYbKUWD9Sv5z7V2x4xGfkR1mE7nw69I3eid30Mr1jFDUkQn2m
gWwwCKuh2qxBh+UziIvUqDwbP6JMJUQ8wf5S3t4D8/R6uRu6+VXnnuyLlAs5GSl3
6BJ+mCTwIKcNyGbCxUXiL24B9yNlgF3+tzAJSWt88Zd6XBZLa99GcEXjGoTmjBV9
vpnIhOvG7mUsgAgJVJHjW1KKjjyrS6oH1Bm8HmqZCEmkTEdXppM6FqtbbU8UTE77
wBhoniPoipniHsrrPiTg7jB0f66IIj9MKEpcXCSlMKqISViFYt9Su1gkOyGIOW7L
LoJaU9lvl1WEEa8Usw67k1VQr7RzXqDRfAhbYLI1Ve9xUEiP9J2eQIuLSRztgpc3
DQHh2FulAXeqoX7mQOyMMJA4CQp0nTCrSQaeuOl08y4No9blRixOmex6sWyRhaNN
4tzFMCBMIsCjwcbFqbjrDXRJbxIQ6HdY27bNmHIdnWQpo9UnEAvjBZ75eyKZOqPr
+2hf30RMNVzOwwzcMlM6
=gEKK
-----END PGP SIGNATURE-----

--d6Gm4EdcadzBjdND--
