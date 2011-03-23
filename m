From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] usbnet: use eth%d name for known ethernet devices
Date: Wed, 23 Mar 2011 18:13:41 +0100
Message-ID: <201103231813.41776.arnd@arndb.de>
References: <4D79F068.2080009@linaro.org> <20110323162251.GA9367@kroah.com> <201103231756.39849.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: andy.green@linaro.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Nicolas Pitre <nicolas.pitre@linaro.org>,
	Jaswinder Singh <jaswinder.singh@linaro.org>,
	Linux USB list <linux-usb@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	broonie@opensource.wolfsonmicro.com, roger.quadros@nokia.com,
	grant.likely@secretlab.ca, netdev@vger.kernel.org,
	David Brownell <dbrownell@users.sourceforge.net>
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201103231756.39849.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 23 March 2011, Arnd Bergmann wrote:
> --- a/drivers/net/usb/smsc75xx.c
> +++ b/drivers/net/usb/smsc75xx.c
> @@ -1244,7 +1244,7 @@ static const struct driver_info smsc75xx_info = {
>         .rx_fixup       = smsc75xx_rx_fixup,
>         .tx_fixup       = smsc75xx_tx_fixup,
>         .status         = smsc75xx_status,
> -       .flags          = FLAG_ETHER | FLAG_SEND_ZLP,
> +       .flags          = FLAG_ETHER | FLAG_SEND_ZLP | FLAG_REALLY_ETHER,
>  };
>  
>  static const struct usb_device_id products[] = {
> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> index bc86f4b..c98d3a7 100644
> --- a/drivers/net/usb/smsc95xx.c
> +++ b/drivers/net/usb/smsc95xx.c
> @@ -1231,7 +1231,7 @@ static const struct driver_info smsc95xx_info = {
>         .rx_fixup       = smsc95xx_rx_fixup,
>         .tx_fixup       = smsc95xx_tx_fixup,
>         .status         = smsc95xx_status,
> -       .flags          = FLAG_ETHER | FLAG_SEND_ZLP,
> +       .flags          = FLAG_ETHER | FLAG_SEND_ZLP | FLAG_REALLY_ETHER,
>  };
>  

These two hunks are from an earlier version of the patch and should not
be there, they break compilation. I'll wait for more comments and
then send a fixed version.

	Arnd
