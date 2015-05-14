From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: be_hwmon_show_temp() can be static
Date: Thu, 14 May 2015 17:39:46 -0400 (EDT)
Message-ID: <20150514.173946.1264501038106193211.davem@davemloft.net>
References: <201505150315.NZBccr7Q%fengguang.wu@intel.com>
	<20150514190234.GA103883@snb>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ying.xue@windriver.com, kbuild-all@01.org,
	sathya.perla@avagotech.com, ajit.khaparde@avagotech.com,
	padmanabh.ratnakar@avagotech.com,
	sriharsha.basavapatna@avagotech.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42238 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422721AbbENVjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 17:39:49 -0400
In-Reply-To: <20150514190234.GA103883@snb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Fri, 15 May 2015 03:02:35 +0800

> 
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> ---
>  be_main.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
> index dc7c0fd..76d491f 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -5612,7 +5612,7 @@ static void be_remove(struct pci_dev *pdev)
>  	free_netdev(adapter->netdev);
>  }
>  
> -ssize_t be_hwmon_show_temp(struct device *dev,
> +static ssize_t be_hwmon_show_temp(struct device *dev,
>  			   struct device_attribute *dev_attr,
>  			   char *buf)

If you adjust the column of the openning parenthesis of the
function, you have to reindent the subsequent lines so that they
start precisely at the very next column.

You must use the appropriate number of TAB and SPACE characters
necessary to do so.
