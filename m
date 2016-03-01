From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH] asm-generic: remove old nonatomic-io wrapper files
Date: Tue, 1 Mar 2016 09:13:42 +0900
Message-ID: <20160301001338.GA14413@vergenet.net>
References: <1456496980-1852604-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>,
	linux-arm-kernel@lists.infradead.org,
	Dan Williams <dan.j.williams@intel.com>,
	Vinod Koul <vinod.koul@intel.com>,
	Jakub Kicinski <jakub.kicinski@netronome.com>,
	Rolf Neugebauer <rolf.neugebauer@netronome.com>,
	"David S. Miller" <davem@davemloft.net>,
	Yisen Zhuang <yisen.zhuang@huawei.com>,
	yankejian <yankejian@huawei.com>,
	kenneth Lee <liguozhu@hisilicon.com>,
	huangdaode <huangdaode@hisilicon.com>,
	lipeng <lipeng321@huawei.com>, linux-kernel@vger.kernel.org,
	dmaengine@vger.kernel.org, netdev@vger.kernel.org,
	oss-drivers@netronome.com, linux-arch@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1456496980-1852604-1-git-send-email-arnd@arndb.de>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 26, 2016 at 03:29:05PM +0100, Arnd Bergmann wrote:
> The two header files got moved to include/linux, and most
> users were already converted, this changes the remaining drivers
> and removes the files.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/dma/idma64.h                                | 2 +-
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c | 2 +-
>  drivers/net/ethernet/netronome/nfp/nfp_net.h        | 2 +-

The NFP portion:

Acked-by: Simon Horman <simon.horman@netronome.com>

>  include/asm-generic/io-64-nonatomic-hi-lo.h         | 2 --
>  include/asm-generic/io-64-nonatomic-lo-hi.h         | 2 --
>  5 files changed, 3 insertions(+), 7 deletions(-)
>  delete mode 100644 include/asm-generic/io-64-nonatomic-hi-lo.h
>  delete mode 100644 include/asm-generic/io-64-nonatomic-lo-hi.h
