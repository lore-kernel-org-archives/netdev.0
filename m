From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net/usb/r815x: replace USB buffer from stack to
 DMA-able
Date: Wed, 24 Jul 2013 17:49:47 -0700 (PDT)
Message-ID: <20130724.174947.452272360732442554.davem@davemloft.net>
References: <D7C722C73C7A400780358D0376412267@realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <D7C722C73C7A400780358D0376412267@realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: hayeswang <hayeswang@realtek.com>
Date: Tue, 23 Jul 2013 17:26:04 +0800

> diff --git a/drivers/net/usb/r815x.c b/drivers/net/usb/r815x.c
> index 8523922..e9b99ba 100644
> --- a/drivers/net/usb/r815x.c
> +++ b/drivers/net/usb/r815x.c
> @@ -24,34 +24,43 @@
>  
>  static int pla_read_word(struct usb_device *udev, u16 index)
>  {
> - int data, ret;
> + int ret;
>   u8 shift = index & 2;
> - __le32 ocp_data;
> + __le32 *tmp;

Your email client has corrupted these patches.
