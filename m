From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 3/3] r8152: replace the return value of
 rtl_ops_init
Date: Sun, 05 Jan 2014 22:59:22 -0800
Message-ID: <1388991562.5808.39.camel@joe-AO722>
References: <1388990366-8508-1-git-send-email-hayeswang@realtek.com>
	 <1388990366-8508-4-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388990366-8508-4-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
[]
> @@ -2721,18 +2722,20 @@ static bool rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
[]
> +	if (ret)
> +		netif_err(tp, probe, tp->netdev, "Unknown Device");

This format should have a terminating newline
"Unknown Device\n"
