From: Jean Delvare <khali@linux-fr.org>
Subject: Re: [lm-sensors] [PATCH 4/5] igb: Start temperature sensor
 attribute  index with 1
Date: Sat, 23 Nov 2013 13:58:30 +0100
Message-ID: <20131123135830.66889fb7@endymion.delvare>
References: <1385186881-7931-1-git-send-email-linux@roeck-us.net>
	<1385186881-7931-5-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nithin Nayak Sujir <nsujir@broadcom.com>,
	e1000-devel@lists.sourceforge.net,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	lm-sensors@lm-sensors.org, Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zoneX.GCU-Squad.org ([194.213.125.0]:38089 "EHLO
	services.gcu-squad.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332Ab3KWM7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 07:59:48 -0500
In-Reply-To: <1385186881-7931-5-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Nov 2013 22:08:00 -0800, Guenter Roeck wrote:
> Per hwmon ABI, temperature sensor attribute index starts with 1, not 0.
> 
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
>  drivers/net/ethernet/intel/igb/igb_hwmon.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/igb/igb_hwmon.c b/drivers/net/ethernet/intel/igb/igb_hwmon.c
> index 2e7ef2d..e0af5bc 100644
> --- a/drivers/net/ethernet/intel/igb/igb_hwmon.c
> +++ b/drivers/net/ethernet/intel/igb/igb_hwmon.c
> @@ -124,22 +124,22 @@ static int igb_add_hwmon_attr(struct igb_adapter *adapter,
>  	case IGB_HWMON_TYPE_LOC:
>  		igb_attr->dev_attr.show = igb_hwmon_show_location;
>  		snprintf(igb_attr->name, sizeof(igb_attr->name),
> -			 "temp%u_label", offset);
> +			 "temp%u_label", offset + 1);
>  		break;
>  	case IGB_HWMON_TYPE_TEMP:
>  		igb_attr->dev_attr.show = igb_hwmon_show_temp;
>  		snprintf(igb_attr->name, sizeof(igb_attr->name),
> -			 "temp%u_input", offset);
> +			 "temp%u_input", offset + 1);
>  		break;
>  	case IGB_HWMON_TYPE_CAUTION:
>  		igb_attr->dev_attr.show = igb_hwmon_show_cautionthresh;
>  		snprintf(igb_attr->name, sizeof(igb_attr->name),
> -			 "temp%u_max", offset);
> +			 "temp%u_max", offset + 1);
>  		break;
>  	case IGB_HWMON_TYPE_MAX:
>  		igb_attr->dev_attr.show = igb_hwmon_show_maxopthresh;
>  		snprintf(igb_attr->name, sizeof(igb_attr->name),
> -			 "temp%u_crit", offset);
> +			 "temp%u_crit", offset + 1);
>  		break;
>  	default:
>  		rc = -EPERM;

Reviewed-by: Jean Delvare <khali@linux-fr.org>

-- 
Jean Delvare
