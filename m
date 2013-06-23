From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH 1/1] net: add dm9620 net usb driver
Date: Sun, 23 Jun 2013 22:00:52 +0200
Message-ID: <87mwqglhqj.fsf@dell.be.48ers.dk>
References: <1371730801-2288-1-git-send-email-josright123@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, joseph_chang@davicom.com.tw,
	josright@hotmail.com
To: Joseph CHANG <josright123@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371730801-2288-1-git-send-email-josright123@gmail.com> (Joseph
	CHANG's message of "Thu, 20 Jun 2013 20:20:01 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Joseph" == Joseph CHANG <josright123@gmail.com> writes:

 Joseph> DM9620 is an USB2.0 network adapter rather than DM9601 USB1.1. This
 Joseph> driver processed the RX data 4 bytes header, TX data 2 bytes header,
 Joseph> make the control bit exactly right in PHY write function, and optional
 Joseph> IFF_ALLMUTLI bit for RX control.

But dm9601.c already supports the dm9620 based devices. Why another
driver for the same hardware?

Please CC me on dm9601 related patches.

 Joseph> Tested good for many platforms, include X86 desktop and ARM embedded.

 Joseph> +static struct usb_driver dm9620_driver = {
 Joseph> +	.name = "dm9620",
 Joseph> +	.id_table = products,
 Joseph> +	.probe = usbnet_probe,
 Joseph> +	.disconnect = usbnet_disconnect,
 Joseph> +	.suspend = usbnet_suspend,
 Joseph> +	.resume = usbnet_resume,
 Joseph> +	.disable_hub_initiated_lpm = 1,
 Joseph> +};
 Joseph> +
 Joseph> +module_usb_driver(dm9620_driver);
 Joseph> +
 Joseph> +MODULE_AUTHOR("Peter Korsgaard <jacmet@sunsite.dk>");

I'm not the author of this file.


-- 
Bye, Peter Korsgaard
