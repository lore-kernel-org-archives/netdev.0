From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 0/6] constify ethtool_ops structures
Date: Wed, 31 Aug 2016 20:40:28 +0100 (IST)
Message-ID: <alpine.DEB.2.10.1608312039430.2913@hadrien>
References: <1472628648-3603-1-git-send-email-Julia.Lawall@lip6.fr> <20160831083929.62832cea@xeon-e3>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:42048
        "EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753070AbcHaTkj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 15:40:39 -0400
In-Reply-To: <20160831083929.62832cea@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 31 Aug 2016, Stephen Hemminger wrote:

> On Wed, 31 Aug 2016 09:30:42 +0200
> Julia Lawall <Julia.Lawall@lip6.fr> wrote:
>
> > Constify ethtool_ops structures.
> >
> > ---
> >
> >  drivers/net/ethernet/agere/et131x.c              |    2 +-
> >  drivers/net/ethernet/broadcom/bcmsysport.c       |    2 +-
> >  drivers/net/ethernet/broadcom/genet/bcmgenet.c   |    2 +-
> >  drivers/net/ethernet/hisilicon/hip04_eth.c       |    2 +-
> >  drivers/net/ethernet/hisilicon/hisi_femac.c      |    2 +-
> >  drivers/net/ethernet/hisilicon/hix5hd2_gmac.c    |    2 +-
> >  drivers/net/ethernet/hisilicon/hns/hns_ethtool.c |    2 +-
> >  drivers/net/ethernet/synopsys/dwc_eth_qos.c      |    2 +-
> >  drivers/staging/slicoss/slicoss.c                |    4 ++--
> >  9 files changed, 10 insertions(+), 10 deletions(-)
> > _______________________________________________
> > devel mailing list
> > devel@linuxdriverproject.org
> > http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel
>
> Other drivers with same type of issue
>
>
> drivers/net/ethernet/mediatek/mtk_eth_soc.c:static struct ethtool_ops mtk_ethtool_ops = {
> drivers/net/ethernet/synopsys/dwc_eth_qos.c:static struct ethtool_ops dwceqos_ethtool_ops = {
> drivers/net/ethernet/xilinx/xilinx_axienet_main.c:static struct ethtool_ops axienet_ethtool_ops = {
> drivers/net/usb/r8152.c:static struct ethtool_ops ops = {
> drivers/staging/netlogic/xlr_net.c:static struct ethtool_ops xlr_ethtool_ops = {

Thanks.  Probably they don't compile for x86, or at least not with make
allyesconfig.  I can check on them.

julia
