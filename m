From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 33/35] wireless: realtek: rtl8192cu: constify
 usb_device_id
Date: Tue, 8 Aug 2017 23:09:36 -0500
Message-ID: <5dca329f-d98c-82f2-1289-0d9d64c39347@lwfinger.net>
References: <1502208353-12447-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: Arvind Yadav <arvind.yadav.cs@gmail.com>, kvalo@codeaurora.org,
        chaoming_li@realsil.com.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33235 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750866AbdHIEJi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 00:09:38 -0400
In-Reply-To: <1502208353-12447-1-git-send-email-arvind.yadav.cs@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/08/2017 11:05 AM, Arvind Yadav wrote:
> usb_device_id are not supposed to change at runtime. All functions
> working with usb_device_id provided by <linux/usb.h> work with
> const usb_device_id. So mark the non-const structs as const.
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
> ---

Acked-by: Larry Finger <Larry.Finger@lwfinger.net>

Thanks,

Larry

>   drivers/net/wireless/realtek/rtlwifi/rtl8192cu/sw.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/sw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/sw.c
> index 96c923b..e673bc2 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/sw.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/sw.c
> @@ -275,7 +275,7 @@ static struct rtl_hal_cfg rtl92cu_hal_cfg = {
>   #define USB_VENDER_ID_REALTEK		0x0bda
>   
>   /* 2010-10-19 DID_USB_V3.4 */
> -static struct usb_device_id rtl8192c_usb_ids[] = {
> +static const struct usb_device_id rtl8192c_usb_ids[] = {
>   
>   	/*=== Realtek demoboard ===*/
>   	/* Default ID */
> 
