From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] USB 10/100 RJ45 Ethernet Network Adapter
Date: Tue, 22 Feb 2011 15:21:00 +0100
Message-ID: <87lj18qhf7.fsf@macbook.be.48ers.dk>
References: <20110222140705.GA6055@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org
To: Shahar Havivi <shaharh@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61671 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276Ab1BVOVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 09:21:10 -0500
In-Reply-To: <20110222140705.GA6055@redhat.com> (Shahar Havivi's message of
	"Tue, 22 Feb 2011 16:07:10 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Shahar" == Shahar Havivi <shaharh@redhat.com> writes:

 Shahar> The device is very similar to (0x0fe6, 0x8101),
 Shahar> And works well with dm9601 driver.
 Shahar> ---
 Shahar>  drivers/net/usb/dm9601.c |    5 +++++
 Shahar>  1 files changed, 5 insertions(+), 0 deletions(-)

 Shahar> diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
 Shahar> index 02b622e..2d1c8ae 100644
 Shahar> --- a/drivers/net/usb/dm9601.c
 Shahar> +++ b/drivers/net/usb/dm9601.c
 Shahar> @@ -654,6 +654,11 @@ static const struct usb_device_id products[] = {
 Shahar>  	 USB_DEVICE(0x0a46, 0x9000),	/* DM9000E */
 Shahar>  	 .driver_info = (unsigned long)&dm9601_info,
 Shahar>  	 },
 Shahar> +	{
 Shahar> +	 USB_DEVICE(0x0fe6, 0x9700),	/* DM9601 USB to Fast Ethernet Adapter */
 Shahar> +
 Shahar> +	 .driver_info = (unsigned long)&dm9601_info,
 Shahar> +	 },
 Shahar>  	{},			// END

Please put it after the 0x8100 device and get rid of the empty line
before .driver_info - Otherwise it looks good.

Acked-by: Peter Korsgaard <jacmet@sunsite.dk>

-- 
Bye, Peter Korsgaard
