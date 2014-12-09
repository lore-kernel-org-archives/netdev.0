From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8152: redefine REALTEK_USB_DEVICE
Date: Tue, 09 Dec 2014 13:41:35 -0500 (EST)
Message-ID: <20141209.134135.1917776346032039917.davem@davemloft.net>
References: <1394712342-15778-106-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-106-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 4 Dec 2014 10:43:11 +0800

> Redefine REALTEK_USB_DEVICE for the desired USB interface for probe().
> There are three USB interfaces for the device. USB_CLASS_COMM and
> USB_CLASS_CDC_DATA are for ECM mode (config #2). USB_CLASS_VENDOR_SPEC
> is for the vendor mode (config #1). However, we are not interesting
> in USB_CLASS_CDC_DATA for probe(), so redefine REALTEK_USB_DEVICE
> to ignore the USB interface class of USB_CLASS_CDC_DATA.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied.
