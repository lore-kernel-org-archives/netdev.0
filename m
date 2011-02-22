From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH-v2] Added support for usb ethernet (0x0fe6, 0x9700)
Date: Tue, 22 Feb 2011 16:23:44 +0100
Message-ID: <87hbbwqein.fsf@macbook.be.48ers.dk>
References: <20110222144110.GG2122@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Shahar Havivi <shaharh@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110222144110.GG2122@redhat.com> (Shahar Havivi's message of
	"Tue, 22 Feb 2011 16:41:11 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Shahar" == Shahar Havivi <shaharh@redhat.com> writes:

 Shahar> The device is very similar to (0x0fe6, 0x8101),
 Shahar> And works well with dm9601 driver.

 Shahar> Signed-off-by: Shahar Havivi <shaharh@redhat.com>

Acked-by: Peter Korsgaard <jacmet@sunsite.dk>

 Shahar> ---
 Shahar> v2:
 Shahar> Fix Peter Korsgaard comments:
 Shahar> got rid of empty line,
 Shahar> move after the 0x8101 device
 Shahar> ---
 Shahar>  drivers/net/usb/dm9601.c |    4 ++++
 Shahar>  1 files changed, 4 insertions(+), 0 deletions(-)

 Shahar> diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
 Shahar> index 02b622e..5002f5b 100644
 Shahar> --- a/drivers/net/usb/dm9601.c
 Shahar> +++ b/drivers/net/usb/dm9601.c
 Shahar> @@ -651,6 +651,10 @@ static const struct usb_device_id products[] = {
 Shahar>  	.driver_info = (unsigned long)&dm9601_info,
 Shahar>  	 },
 Shahar>  	{
 Shahar> +	 USB_DEVICE(0x0fe6, 0x9700),	/* DM9601 USB to Fast Ethernet Adapter */
 Shahar> +	 .driver_info = (unsigned long)&dm9601_info,
 Shahar> +	 },
 Shahar> +	{
 Shahar>  	 USB_DEVICE(0x0a46, 0x9000),	/* DM9000E */
 Shahar>  	 .driver_info = (unsigned long)&dm9601_info,
 Shahar>  	 },
 Shahar> -- 
 Shahar> 1.7.4


-- 
Bye, Peter Korsgaard
