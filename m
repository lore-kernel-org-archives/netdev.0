From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: rtl8192cu: Add new device ID
Date: Wed, 19 Aug 2015 09:42:16 -0500
Message-ID: <55D495C8.6030906@lwfinger.net>
References: <1439992291-24912-1-git-send-email-adrien+dev@schischi.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrien Schildknecht <adrien+dev@schischi.me>,
	chaoming_li@realsil.com.cn, kvalo@codeaurora.org,
	linville@tuxdriver.com, marex@denx.de, fzuuzf@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:33013 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752192AbbHSOmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 10:42:25 -0400
In-Reply-To: <1439992291-24912-1-git-send-email-adrien+dev@schischi.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/2015 08:51 AM, Adrien Schildknecht wrote:
> The v2 of NetGear WNA1000M uses a different idProduct: USB ID 0846:9043
>
> Signed-off-by: Adrien Schildknecht <adrien+dev@schischi.me>

Add a "Cc: Stable <stable@vger.kernel.org>" line here. That way the new ID will 
be available with older kernels.

The new line exceeds 80 characters. You might abbreviate Netgear as NG.

When you resubmit, do so as "[PATCH V2]".

Thanks,

Larry

> ---
>   drivers/net/wireless/rtlwifi/rtl8192cu/sw.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
> index 23806c2..8b4238a 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
> @@ -321,6 +321,7 @@ static struct usb_device_id rtl8192c_usb_ids[] = {
>   	{RTL_USB_DEVICE(0x07b8, 0x8188, rtl92cu_hal_cfg)}, /*Abocom - Abocom*/
>   	{RTL_USB_DEVICE(0x07b8, 0x8189, rtl92cu_hal_cfg)}, /*Funai - Abocom*/
>   	{RTL_USB_DEVICE(0x0846, 0x9041, rtl92cu_hal_cfg)}, /*NetGear WNA1000M*/
> +	{RTL_USB_DEVICE(0x0846, 0x9043, rtl92cu_hal_cfg)}, /*NetGear WNA1000Mv2*/
>   	{RTL_USB_DEVICE(0x0b05, 0x17ba, rtl92cu_hal_cfg)}, /*ASUS-Edimax*/
>   	{RTL_USB_DEVICE(0x0bda, 0x5088, rtl92cu_hal_cfg)}, /*Thinkware-CC&C*/
>   	{RTL_USB_DEVICE(0x0df6, 0x0052, rtl92cu_hal_cfg)}, /*Sitecom - Edimax*/
>
