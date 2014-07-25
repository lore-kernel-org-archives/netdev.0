From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: fix the checking of the usb speed
Date: Thu, 24 Jul 2014 23:38:07 -0700 (PDT)
Message-ID: <20140724.233807.867041649917385199.davem@davemloft.net>
References: <1394712342-15778-15-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	andrey.krieger.utkin@gmail.com
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-15-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 24 Jul 2014 16:37:43 +0800

> When the usb speed of the RTL8152 is not high speed, the USB_DEV_STAT[2:1]
> should be equal to [0 1]. That is, the STAT_SPEED_FULL should be equal
> to 2.
> 
> There is a easy way to check the usb speed by the speed field of the
> struct usb_device. Use it to replace the original metheod.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> Spotted-by: Andrey Utkin <andrey.krieger.utkin@gmail.com>

Applied, thanks.
