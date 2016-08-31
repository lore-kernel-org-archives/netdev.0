From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 0/6] constify ethtool_ops structures
Date: Wed, 31 Aug 2016 08:39:29 -0700
Message-ID: <20160831083929.62832cea@xeon-e3>
References: <1472628648-3603-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1472628648-3603-1-git-send-email-Julia.Lawall@lip6.fr>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Wed, 31 Aug 2016 09:30:42 +0200
Julia Lawall <Julia.Lawall@lip6.fr> wrote:

> Constify ethtool_ops structures.
> 
> ---
> 
>  drivers/net/ethernet/agere/et131x.c              |    2 +-
>  drivers/net/ethernet/broadcom/bcmsysport.c       |    2 +-
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c   |    2 +-
>  drivers/net/ethernet/hisilicon/hip04_eth.c       |    2 +-
>  drivers/net/ethernet/hisilicon/hisi_femac.c      |    2 +-
>  drivers/net/ethernet/hisilicon/hix5hd2_gmac.c    |    2 +-
>  drivers/net/ethernet/hisilicon/hns/hns_ethtool.c |    2 +-
>  drivers/net/ethernet/synopsys/dwc_eth_qos.c      |    2 +-
>  drivers/staging/slicoss/slicoss.c                |    4 ++--
>  9 files changed, 10 insertions(+), 10 deletions(-)
> _______________________________________________
> devel mailing list
> devel@linuxdriverproject.org
> http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

Other drivers with same type of issue


drivers/net/ethernet/mediatek/mtk_eth_soc.c:static struct ethtool_ops mtk_ethtool_ops = {
drivers/net/ethernet/synopsys/dwc_eth_qos.c:static struct ethtool_ops dwceqos_ethtool_ops = {
drivers/net/ethernet/xilinx/xilinx_axienet_main.c:static struct ethtool_ops axienet_ethtool_ops = {
drivers/net/usb/r8152.c:static struct ethtool_ops ops = {
drivers/staging/netlogic/xlr_net.c:static struct ethtool_ops xlr_ethtool_ops = {
