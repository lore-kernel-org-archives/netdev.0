From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH] staging: r8188eu: Fix typo in USB_DEVICE list
Date: Sun, 02 Feb 2014 13:04:35 -0800
Message-ID: <52EEB2E3.8090306@infradead.org>
References: <1391371626-13551-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:32961 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752435AbaBBVEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Feb 2014 16:04:39 -0500
In-Reply-To: <1391371626-13551-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/02/2014 12:07 PM, Larry Finger wrote:
> There is a typo in the device list that interchanges the vendor and
> product codes for one of the entries.

You also changed 0x7b8 to 0x7bb.
Did you mean to do that?


> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> ---
>  drivers/staging/rtl8188eu/os_dep/usb_intf.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/rtl8188eu/os_dep/usb_intf.c b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
> index 0a341d6..e9e3c76 100644
> --- a/drivers/staging/rtl8188eu/os_dep/usb_intf.c
> +++ b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
> @@ -53,7 +53,7 @@ static struct usb_device_id rtw_usb_id_tbl[] = {
>  	{USB_DEVICE(USB_VENDER_ID_REALTEK, 0x0179)}, /* 8188ETV */
>  	/*=== Customer ID ===*/
>  	/****** 8188EUS ********/
> -	{USB_DEVICE(0x8179, 0x07B8)}, /* Abocom - Abocom */
> +	{USB_DEVICE(0x07bb, 0x8179)}, /* Abocom - Abocom */
>  	{USB_DEVICE(0x2001, 0x330F)}, /* DLink DWA-125 REV D1 */
>  	{}	/* Terminating entry */
>  };
> 


-- 
~Randy
