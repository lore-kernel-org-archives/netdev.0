From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 0/2] r8152: device reset
Date: Thu, 30 Jul 2015 14:04:01 -0700 (PDT)
Message-ID: <20150730.140401.2147687049481097497.davem@davemloft.net>
References: <1394712342-15778-156-Taiwan-albertk@realtek.com>
	<1394712342-15778-162-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-162-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Wed, 29 Jul 2015 20:39:07 +0800

> v3:
> For patch #2, remove cancel_delayed_work().
> 
> v2:
> For patch #1, remove usb_autopm_get_interface(), usb_autopm_put_interface(), and
> the checking of intf->condition.
> 
> For patch #2, replace the original method with usb_queue_reset_device() to reset
> the device. 
> 
> v1:
> Although the driver works normally, we find the device may get all 0xff data when
> transmitting packets on certain platforms. It would break the device and no packet
> could be transmitted. The reset is necessary to recover the hw for this situation.

Series applied, thanks.
