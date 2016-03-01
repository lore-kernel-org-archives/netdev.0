From: Yisen Zhuang <Yisen.zhuang@huawei.com>
Subject: Re: [PATCH] asm-generic: remove old nonatomic-io wrapper files
Date: Tue, 1 Mar 2016 08:59:22 +0800
Message-ID: <56D4E96A.20509@huawei.com>
References: <1456496980-1852604-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Hellwig <hch@lst.de>,
	<linux-arm-kernel@lists.infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Vinod Koul <vinod.koul@intel.com>,
	Jakub Kicinski <jakub.kicinski@netronome.com>,
	Rolf Neugebauer <rolf.neugebauer@netronome.com>,
	"David S. Miller" <davem@davemloft.net>,
	yankejian <yankejian@huawei.com>,
	kenneth Lee <liguozhu@hisilicon.com>,
	huangdaode <huangdaode@hisilicon.com>,
	lipeng <lipeng321@huawei.com>, <linux-kernel@vger.kernel.org>,
	<dmaengine@vger.kernel.org>, <netdev@vger.kernel.org>,
	<oss-drivers@netronome.com>, <linux-arch@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1456496980-1852604-1-git-send-email-arnd@arndb.de>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E5=9C=A8 2016/2/26 22:29, Arnd Bergmann =E5=86=99=E9=81=93:
> The two header files got moved to include/linux, and most
> users were already converted, this changes the remaining drivers
> and removes the files.
>=20
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/dma/idma64.h                                | 2 +-
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c | 2 +-

The HNS portion:

Acked-by: Yisen Zhuang <yisen.zhuang@huawei.com>

>  drivers/net/ethernet/netronome/nfp/nfp_net.h        | 2 +-
>  include/asm-generic/io-64-nonatomic-hi-lo.h         | 2 --
>  include/asm-generic/io-64-nonatomic-lo-hi.h         | 2 --
>  5 files changed, 3 insertions(+), 7 deletions(-)
>  delete mode 100644 include/asm-generic/io-64-nonatomic-hi-lo.h
>  delete mode 100644 include/asm-generic/io-64-nonatomic-lo-hi.h
>=20
> diff --git a/drivers/dma/idma64.h b/drivers/dma/idma64.h
> index 8423f13ed0da..a52ad6bcf86a 100644
> --- a/drivers/dma/idma64.h
> +++ b/drivers/dma/idma64.h
> @@ -16,7 +16,7 @@
>  #include <linux/spinlock.h>
>  #include <linux/types.h>
> =20
> -#include <asm-generic/io-64-nonatomic-lo-hi.h>
> +#include <linux/io-64-nonatomic-lo-hi.h>
> =20
>  #include "virt-dma.h"
> =20
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c b/dr=
ivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
> index 802d55457f19..fd90f3737963 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
> @@ -7,7 +7,7 @@
>   * (at your option) any later version.
>   */
> =20
> -#include <asm-generic/io-64-nonatomic-hi-lo.h>
> +#include <linux/io-64-nonatomic-hi-lo.h>
>  #include <linux/of_mdio.h>
>  #include "hns_dsaf_main.h"
>  #include "hns_dsaf_mac.h"
> diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/n=
et/ethernet/netronome/nfp/nfp_net.h
> index ab264e1bccd0..75683fb26734 100644
> --- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
> +++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
> @@ -45,7 +45,7 @@
>  #include <linux/interrupt.h>
>  #include <linux/netdevice.h>
>  #include <linux/pci.h>
> -#include <asm-generic/io-64-nonatomic-hi-lo.h>
> +#include <linux/io-64-nonatomic-hi-lo.h>
> =20
>  #include "nfp_net_ctrl.h"
> =20
> diff --git a/include/asm-generic/io-64-nonatomic-hi-lo.h b/include/as=
m-generic/io-64-nonatomic-hi-lo.h
> deleted file mode 100644
> index 32b73abce1b0..000000000000
> --- a/include/asm-generic/io-64-nonatomic-hi-lo.h
> +++ /dev/null
> @@ -1,2 +0,0 @@
> -/* XXX: delete asm-generic/io-64-nonatomic-hi-lo.h after converting =
new users */
> -#include <linux/io-64-nonatomic-hi-lo.h>
> diff --git a/include/asm-generic/io-64-nonatomic-lo-hi.h b/include/as=
m-generic/io-64-nonatomic-lo-hi.h
> deleted file mode 100644
> index 55a627c37721..000000000000
> --- a/include/asm-generic/io-64-nonatomic-lo-hi.h
> +++ /dev/null
> @@ -1,2 +0,0 @@
> -/* XXX: delete asm-generic/io-64-nonatomic-lo-hi.h after converting =
new users */
> -#include <linux/io-64-nonatomic-lo-hi.h>
>=20
