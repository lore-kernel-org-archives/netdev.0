From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [patch net 1/2] net: hns: fix return value of the function
 about rss
Date: Thu, 10 Mar 2016 10:11:49 +0200
Message-ID: <1457597509.1347.49.camel@linux.intel.com>
References: <1457576189-22924-1-git-send-email-yankejian@huawei.com>
	 <1457576189-22924-2-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
	liguozhu@huawei.com, huangdaode@hisilicon.com, arnd@arndb.de,
	andrew@lunn.ch, chenny.xu@huawei.com, ivecera@redhat.com,
	lisheng011@huawei.com, fengguang.wu@intel.com,
	haifeng.wei@huawei.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxarm@huawei.com
To: Kejian Yan <yankejian@huawei.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457576189-22924-2-git-send-email-yankejian@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-03-10 at 10:16 +0800, Kejian Yan wrote:
> Both .get_rxfh and .get_rxfh are always return 0, it should return
> result
> from hardware when getting or setting rss. And the rss function
> should
> return the correct data type.
>=20

@@ -1213,7 +1213,7 @@ hns_get_rss(struct net_device *netdev, u32
> *indir, u8 *key, u8 *hfunc)
> =C2=A0
>=20

> =C2=A0	ret =3D ops->get_rss(priv->ae_handle, indir, key, hfunc);
> =C2=A0
> -	return 0;
> +	return ret;

All three can be one line.

> @@ -1241,7 +1241,7 @@ hns_set_rss(struct net_device *netdev, const
> u32 *indir, const u8 *key,
> =C2=A0
> =C2=A0	ret =3D ops->set_rss(priv->ae_handle, indir, key, hfunc);
> =C2=A0
> -	return 0;
> +	return ret;

Ditto.

--=20
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
