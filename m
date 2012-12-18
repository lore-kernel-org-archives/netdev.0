From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH 1/2] net: asix: init ASIX AX88772B MAC from EEPROM
Date: Tue, 18 Dec 2012 14:11:51 +0100
Message-ID: <5491619.g500gaSnsh@linux-lqwf.site>
References: <1355832626-3034-1-git-send-email-dev@lynxeye.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Lucas Stach <dev@lynxeye.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43430 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752924Ab2LRNLW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2012 08:11:22 -0500
In-Reply-To: <1355832626-3034-1-git-send-email-dev@lynxeye.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 18 December 2012 13:10:25 Lucas Stach wrote:
> diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
> index 9bbeabf..8e9516f 100644
> --- a/include/linux/usb/usbnet.h
> +++ b/include/linux/usb/usbnet.h
> @@ -106,6 +106,7 @@ struct driver_info {
>   */
>  #define FLAG_MULTI_PACKET      0x2000
>  #define FLAG_RX_ASSEMBLE       0x4000  /* rx packets may span >1 frames */
> +#define FLAG_EEPROM_MAC                0x8000  /* initialize device MAC from eeprom */

Hi,

this looks sensible, but
why are you adding a flag unused in usbnet to usbnet.h?

	Regards
		Oliver
