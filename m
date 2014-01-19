From: David Miller <davem@davemloft.net>
Subject: Re: [ PATCH net-next] qlcnic: fix sparse warnings
Date: Sat, 18 Jan 2014 23:09:24 -0800 (PST)
Message-ID: <20140118.230924.161581406065831782.davem@davemloft.net>
References: <20140118172113.16adb69f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55242 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbaASHJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 02:09:25 -0500
In-Reply-To: <20140118172113.16adb69f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sat, 18 Jan 2014 17:21:13 -0800

> From: Fengguang Wu <fengguang.wu@intel.com>
> 
> Previous patch changed prototypes, but forgot functions.
> 
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> Acked-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> ---
>  qlcnic_83xx_hw.c |   12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c	2014-01-18 13:41:07.000000000 -0800
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c	2014-01-18 17:13:08.640658697 -0800
> @@ -2066,7 +2066,7 @@ void qlcnic_83xx_change_l2_filter(struct
>  	qlcnic_83xx_sre_macaddr_change(adapter, mac, vlan_id, QLCNIC_MAC_ADD);
>  }
>  
> -void qlcnic_83xx_configure_mac(struct qlcnic_adapter *adapter, u8 *mac,
> +static void qlcnic_83xx_configure_mac(struct qlcnic_adapter *adapter, u8 *mac,
>  			       u8 type, struct qlcnic_cmd_args *cmd)

Please adjust argument indentation, this goes for the whole patch.

Thanks.
