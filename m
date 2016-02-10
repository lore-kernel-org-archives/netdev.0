From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/3] lan78xx: replace devid to chipid & chiprev
Date: Thu, 11 Feb 2016 00:36:44 +0300
Message-ID: <56BBAD6C.6070901@cogentembedded.com>
References: <9235D6609DB808459E95D78E17F2E43D404AB9F2@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Woojung.Huh@microchip.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:35862 "EHLO
	mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087AbcBJVgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 16:36:48 -0500
Received: by mail-lf0-f49.google.com with SMTP id 78so20377573lfy.3
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 13:36:47 -0800 (PST)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D404AB9F2@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/2016 12:13 AM, Woojung.Huh@microchip.com wrote:

> Replace devid to chipid & chiprev for easy access.
>
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
> ---
>   drivers/net/usb/lan78xx.c | 20 +++++++++++---------
>   drivers/net/usb/lan78xx.h |  1 +
>   2 files changed, 12 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
> index 1c299b8..b14b22d 100644
> --- a/drivers/net/usb/lan78xx.c
> +++ b/drivers/net/usb/lan78xx.c
[...]
> @@ -471,7 +472,7 @@ static int lan78xx_read_raw_eeprom(struct lan78xx_net *dev, u32 offset,
>   	 */
>   	ret = lan78xx_read_reg(dev, HW_CFG, &val);
>   	saved = val;
> -	if ((dev->devid & ID_REV_CHIP_ID_MASK_) == 0x78000000) {
> +	if ((dev->chipid) == ID_REV_CHIP_ID_7800_) {

    Inner parens not needed.

[...]
> @@ -505,7 +506,7 @@ static int lan78xx_read_raw_eeprom(struct lan78xx_net *dev, u32 offset,
>
>   	retval = 0;
>   exit:
> -	if ((dev->devid & ID_REV_CHIP_ID_MASK_) == 0x78000000)
> +	if ((dev->chipid) == ID_REV_CHIP_ID_7800_)

    Same here.

[...]
> @@ -539,7 +540,7 @@ static int lan78xx_write_raw_eeprom(struct lan78xx_net *dev, u32 offset,
>   	 */
>   	ret = lan78xx_read_reg(dev, HW_CFG, &val);
>   	saved = val;
> -	if ((dev->devid & ID_REV_CHIP_ID_MASK_) == 0x78000000) {
> +	if ((dev->chipid) == ID_REV_CHIP_ID_7800_) {

    And here.

[...]
> @@ -587,7 +588,7 @@ static int lan78xx_write_raw_eeprom(struct lan78xx_net *dev, u32 offset,
>
>   	retval = 0;
>   exit:
> -	if ((dev->devid & ID_REV_CHIP_ID_MASK_) == 0x78000000)
> +	if ((dev->chipid) == ID_REV_CHIP_ID_7800_)

    Here too.

[...]

MBR, Sergei
