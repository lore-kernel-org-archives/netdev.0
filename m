From: Bing Zhao <bzhao@marvell.com>
Subject: RE: [PATCH] [trivial] wireless: mwifiex: Fix typo in
 wireless/mwifiex driver
Date: Fri, 30 Nov 2012 11:30:58 -0800
Message-ID: <477F20668A386D41ADCC57781B1F70430D13A09128@SC-VEXCH1.marvell.com>
References: <1354280911-4866-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: Masanari Iida <standby24x7@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"trivial@kernel.org" <trivial@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354280911-4866-1-git-send-email-standby24x7@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Masanari,

Thanks for your patch.

> Subject: [PATCH] [trivial] wireless: mwifiex: Fix typo in wireless/mwifiex driver
> 
> Correct spelling typo in wireless/mwifiex driver.
> 
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>

Acked-by: Bing Zhao <bzhao@marvell.com>

Regards,
Bing

> ---
>  drivers/net/wireless/mwifiex/sta_ioctl.c | 2 +-
>  drivers/net/wireless/mwifiex/usb.c       | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/mwifiex/sta_ioctl.c b/drivers/net/wireless/mwifiex/sta_ioctl.c
> index 552d72e..21035e6 100644
> --- a/drivers/net/wireless/mwifiex/sta_ioctl.c
> +++ b/drivers/net/wireless/mwifiex/sta_ioctl.c
> @@ -463,7 +463,7 @@ int mwifiex_enable_hs(struct mwifiex_adapter *adapter)
>  	}
> 
>  	if (adapter->hs_activated) {
> -		dev_dbg(adapter->dev, "cmd: HS Already actived\n");
> +		dev_dbg(adapter->dev, "cmd: HS Already activated\n");
>  		return true;
>  	}
> 
> diff --git a/drivers/net/wireless/mwifiex/usb.c b/drivers/net/wireless/mwifiex/usb.c
> index 22a5916..5eb3b33 100644
> --- a/drivers/net/wireless/mwifiex/usb.c
> +++ b/drivers/net/wireless/mwifiex/usb.c
> @@ -351,7 +351,7 @@ static int mwifiex_usb_probe(struct usb_interface *intf,
>  	card->udev = udev;
>  	card->intf = intf;
> 
> -	pr_debug("info: bcdUSB=%#x Device Class=%#x SubClass=%#x Protocl=%#x\n",
> +	pr_debug("info: bcdUSB=%#x Device Class=%#x SubClass=%#x Protocol=%#x\n",
>  		 udev->descriptor.bcdUSB, udev->descriptor.bDeviceClass,
>  		 udev->descriptor.bDeviceSubClass,
>  		 udev->descriptor.bDeviceProtocol);
> --
> 1.8.0.1.347.gf94c325
