From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 4/4] r8152: support firmware files
Date: Sun, 24 Aug 2014 23:20:55 +0200
Message-ID: <20140824212055.GA30857@electric-eye.fr.zoreil.com>
References: <1394712342-15778-16-Taiwan-albertk@realtek.com>
 <1394712342-15778-20-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1394712342-15778-20-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index 937d132..63542cc 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
[...]
> +static void rtl_request_firmware(struct r8152 *tp)
> +{
> +	char *fw_name = NULL;
> +
> +	if (tp->rtl_fw.fw)
> +		goto out_request;
> +
> +	switch (tp->version) {
> +	case RTL_VER_01:
> +		fw_name = "rtl_nic/rtl8152-1.fw";
> +		break;
> +	case RTL_VER_02:
> +		fw_name = "rtl_nic/rtl8152-2.fw";
> +		break;
> +	case RTL_VER_03:
> +		fw_name = "rtl_nic/rtl8153-1.fw";
> +		break;
> +	case RTL_VER_04:
> +		fw_name = "rtl_nic/rtl8153-2.fw";
> +		break;
> +	case RTL_VER_05:
> +		fw_name = "rtl_nic/rtl8153-3.fw";
> +		break;

The driver should use MODULE_FIRMWARE() for these files.

-- 
Ueimor
