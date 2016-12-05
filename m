From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH 1/1] net: usb: set error code when usb_alloc_urb fails
Date: Mon, 5 Dec 2016 16:20:27 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40976FA4@CHN-SV-EXMX02.mchp-main.com>
References: <1480764288-5448-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>
To: <bianpan2016@163.com>, <UNGLinuxDriver@microchip.com>,
        <netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480764288-5448-1-git-send-email-bianpan2016@163.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Signed-off-by: Pan Bian <bianpan2016@163.com>
> ---
>  drivers/net/usb/lan78xx.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
> index db558b8..f33460c 100644
> --- a/drivers/net/usb/lan78xx.c
> +++ b/drivers/net/usb/lan78xx.c
> @@ -3395,6 +3395,7 @@ static int lan78xx_probe(struct usb_interface *intf,
>  	if (buf) {
>  		dev->urb_intr = usb_alloc_urb(0, GFP_KERNEL);
>  		if (!dev->urb_intr) {
> +			ret = -ENOMEM;
>  			kfree(buf);
>  			goto out3;
>  		} else {
> --
> 1.9.1
> 
Acked-by: Woojung Huh <woojung.huh@microchip.com>
