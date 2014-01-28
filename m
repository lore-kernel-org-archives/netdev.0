From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] USB2NET : SR9800 : One chip USB2.0 USB2NET SR9800
 Device Driver Support
Date: Tue, 28 Jan 2014 00:59:32 -0800
Message-ID: <1390899572.20150.97.camel@joe-AO722>
References: <1390898200-9925-1-git-send-email-liujunliang_ljl@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, horms@verge.net.au, romieu@fr.zoreil.com,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	sunhecheng@vip.126.com
To: liujunliang_ljl@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390898200-9925-1-git-send-email-liujunliang_ljl@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-01-28 at 16:36 +0800, liujunliang_ljl@163.com wrote:
> From: Liu Junliang <liujunliang_ljl@163.com>

trivial comments...

> diff --git a/drivers/net/usb/sr9800.c b/drivers/net/usb/sr9800.c

[]

> +static int sr_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
> +{
[]
> +		if (size != ((~header >> 16) & 0x07ff)) {
> +			netdev_err(dev->net,
> +				   "sr_rx_fixup() Bad Header Length\n");

printks with embedded functions names are
generally better using "%s: ", __func__

			netdev_err(dev->net, "%s: Bad header length\n",
				   __func__);

[]

> +			netdev_err(dev->net,
> +				   "sr_rx_fixup() Bad RX Length %d\n", size);

etc.

> +	if (skb->len != offset) {
> +		netdev_err(dev->net, "sr_rx_fixup() Bad SKB Length %d\n",
> +			   skb->len);

etc.

[]

> +static inline int sr9800_set_default_mode(struct usbnet *dev)
> +{

rather a big function to inline

[]

> +	if (ret < 0) {
> +		netdev_dbg(dev->net, "Write IPG,IPG1,IPG2 failed: %d", ret);

missing newline terminations

> +	netdev_dbg(dev->net, "RX_CTL is 0x%04x after all initializations",
> +		   rx_ctl);

etc...
