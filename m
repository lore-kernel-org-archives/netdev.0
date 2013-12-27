From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 6/6] r8152: support RTL8153
Date: Fri, 27 Dec 2013 20:08:31 +0100
Message-ID: <20131227190831.GB29006@electric-eye.fr.zoreil.com>
References: <1388111649-1014-1-git-send-email-hayeswang@realtek.com>
 <1388111856-1065-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oliver@neukum.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1388111856-1065-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
[...]
> diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
> index 4b1c0f3..3e09887 100644
> --- a/drivers/net/usb/cdc_ether.c
> +++ b/drivers/net/usb/cdc_ether.c
> @@ -486,6 +486,7 @@ static const struct driver_info wwan_info = {
>  #define ZTE_VENDOR_ID		0x19D2
>  #define DELL_VENDOR_ID		0x413C
>  #define REALTEK_VENDOR_ID	0x0bda
> +#define VENDOR_ID_SAMSUNG	0x04e8

SAMSUNG_VENDOR_ID would be more consistent for this file.

-- 
Ueimor
