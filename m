From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 7/8] rt2x00: Use %pM conversion specifier
Date: Thu, 16 Jul 2009 22:27:30 +0200
Message-ID: <200907162227.30362.IvDoorn@gmail.com>
References: <1247734839-21394-1-git-send-email-klto@zhaw.ch>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com
To: Tobias Klauser <klto@zhaw.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:51648 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932834AbZGPU1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 16:27:35 -0400
In-Reply-To: <1247734839-21394-1-git-send-email-klto@zhaw.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 16 July 2009, Tobias Klauser wrote:
> Use the %pM conversion specifier for printk instead of print_mac.
> 
> Signed-off-by: Tobias Klauser <klto@zhaw.ch>

Acked-by: Ivo van Doorn <IvDoorn@gmail.com>

> ---
>  drivers/net/wireless/rt2x00/rt2800usb.c |    4 +---
>  1 files changed, 1 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless/rt2x00/rt2800usb.c
> index 3756166..da84afb 100644
> --- a/drivers/net/wireless/rt2x00/rt2800usb.c
> +++ b/drivers/net/wireless/rt2x00/rt2800usb.c
> @@ -2224,10 +2224,8 @@ static int rt2800usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
>  	 */
>  	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
>  	if (!is_valid_ether_addr(mac)) {
> -		DECLARE_MAC_BUF(macbuf);
> -
>  		random_ether_addr(mac);
> -		EEPROM(rt2x00dev, "MAC: %s\n", print_mac(macbuf, mac));
> +		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
>  	}
>  
>  	rt2x00_eeprom_read(rt2x00dev, EEPROM_ANTENNA, &word);


