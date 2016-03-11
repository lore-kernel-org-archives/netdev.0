From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH v3 net-next 0/2] net: hns: get and set RSS indirection
 table by using ethtool
Date: Fri, 11 Mar 2016 11:01:58 +0200
Message-ID: <1457686918.1347.56.camel@linux.intel.com>
References: <1457666747-244953-1-git-send-email-yankejian@huawei.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:14952 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964786AbcCKJBO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 04:01:14 -0500
In-Reply-To: <1457666747-244953-1-git-send-email-yankejian@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-03-11 at 11:25 +0800, Kejian Yan wrote:
> When we use ethtool to retrieves or configure the receive flow hash=C2=
=A0
> indirection table, ethtool needs to call .get_rxnfc to get the ring
> number
> so this patchset implements the .get_rxnfc and fixes the bug that we
> can
> not get the tatal table each time.
>=20

=46WIW:

Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

> ---
> change log:
> PATCH v3:
> =C2=A0- This patchset fixes the building warning and error
>=20
> PATCH v2:
> =C2=A0- This patchset fixes the comments provided by Andy Shevchenko =
<Andy
> Shevchenko>
>=20
> PATCH v1:
> =C2=A0- first submit
>=20
> Kejian Yan (2):
> =C2=A0 net: hns: fix return value of the function about rss
> =C2=A0 net: hns: fixes a bug of RSS
>=20
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c |=C2=A0=C2=A0=
8 ++++---
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c |=C2=A0=C2=A0=
2 +-
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_ethtool.c=C2=A0=C2=A0| 2=
8
> ++++++++++++++++-------
> =C2=A03 files changed, 26 insertions(+), 12 deletions(-)
>=20

--=20
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
