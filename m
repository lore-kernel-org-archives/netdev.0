From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH] [drivers/net/cxgb3] removed several unneeded zero initilization
Date: Fri, 20 Jul 2007 18:22:42 -0700
Message-ID: <46A15FE2.7030108@chelsio.com>
References: <11847434891556-git-send-email-crquan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-bugs@chelsio.com, Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	cr_quan@163.com
To: Denis Cheng <crquan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:19004 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933058AbXGUBW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 21:22:59 -0400
In-Reply-To: <11847434891556-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis Cheng wrote:
> Cc: linux-bugs@chelsio.com
> Signed-off-by: Denis Cheng <crquan@gmail.com>
>   
Acked-by: Divy Le Ray <divy@chelsio.com>

> ---
>  drivers/net/cxgb3/cxgb3_main.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
> index 6fd1e52..45711f9 100644
> --- a/drivers/net/cxgb3/cxgb3_main.c
> +++ b/drivers/net/cxgb3/cxgb3_main.c
> @@ -754,7 +754,7 @@ static int upgrade_fw(struct adapter *adap)
>   */
>  static int cxgb_up(struct adapter *adap)
>  {
> -	int err = 0;
> +	int err;
>  
>  	if (!(adap->flags & FULL_INIT_DONE)) {
>  		err = t3_check_fw_version(adap);
> @@ -861,7 +861,7 @@ static int offload_open(struct net_device *dev)
>  	struct adapter *adapter = dev->priv;
>  	struct t3cdev *tdev = T3CDEV(dev);
>  	int adap_up = adapter->open_device_map & PORT_MASK;
> -	int err = 0;
> +	int err;
>  
>  	if (test_and_set_bit(OFFLOAD_DEVMAP_BIT, &adapter->open_device_map))
>  		return 0;
> @@ -1502,7 +1502,7 @@ static int set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
>  		      u8 * data)
>  {
>  	u8 *buf;
> -	int err = 0;
> +	int err;
>  	u32 aligned_offset, aligned_len, *p;
>  	struct adapter *adapter = dev->priv;
>  
>   

