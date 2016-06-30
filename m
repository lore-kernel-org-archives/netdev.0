From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 net-next 1/9] MAINTAINERS: add maintainers for hns
 driver
Date: Thu, 30 Jun 2016 03:48:21 -0700
Message-ID: <1467283701.24287.137.camel@perches.com>
References: <1467271509-63162-1-git-send-email-Yisen.Zhuang@huawei.com>
	 <1467271509-63162-2-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, gregkh@linuxfoundation.org,
	kvalo@codeaurora.org, mchehab@osg.samsung.com, linux@roeck-us.net,
	jslaby@suse.cz, yankejian@huawei.com, huangdaode@hisilicon.com,
	lipeng321@huawei.com, xieqianqian@huawei.com, arnd@arndb.de,
	andrew@lunn.ch, xypron.glpk@gmx.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Yisen Zhuang <Yisen.Zhuang@huawei.com>, davem@davemloft.net,
	salil.mehta@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467271509-63162-2-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-06-30 at 15:25 +0800, Yisen Zhuang wrote:
> From: Daode Huang <huangdaode@hisilicon.com>
>=20
> This patch adds maintainers for hisilicon network subsystem driver
[]
> diff --git a/MAINTAINERS b/MAINTAINERS
[]
> @@ -5421,6 +5421,15 @@ F:	include/uapi/linux/if_hippi.h
> =A0F:	net/802/hippi.c
> =A0F:	drivers/net/hippi/
> =A0
> +HISILICON NETWORK SUBSYSTEM DRIVER
> +M:	Yisen Zhuang <yisen.zhuang@huawei.com>
> +M:	Salil Mehta <salil.mehta@huawei.com>
> +L:	netdev@vger.kernel.org
> +W:	http://www.hisilicon.com
> +S:	Maintained
> +F:	drivers/net/ethernet/hisilicon/*

=46rom MAINTAINERS:

	F: Files and directories with wildcard patterns.
	=A0=A0=A0A trailing slash includes all files and subdirectory files.
	=A0=A0=A0F:	drivers/net/	all files in and below drivers/net
	=A0=A0=A0F:	drivers/net/*	all files in drivers/net, but not below
	=A0=A0=A0F:	*/net/*		all files in "any top level directory"/net
	=A0=A0=A0One pattern per line.=A0=A0Multiple F: lines acceptable.

So this pattern with the trailing /* matches only:

drivers/net/ethernet/hisilicon/Kconfig
drivers/net/ethernet/hisilicon/Makefile
drivers/net/ethernet/hisilicon/hip04_eth.c
drivers/net/ethernet/hisilicon/hix5hd2_gmac.c

and not any file in drivers/net/ethernet/hisilicon/hns/

Is that what you want?

using

=46:	drivers/net/ethernet/hisilicon/

matches all files in hisilicon and any directory below it.
