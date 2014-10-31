From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: stop submitting intr for -EPROTO
Date: Fri, 31 Oct 2014 13:56:06 -0400 (EDT)
Message-ID: <20141031.135606.1420214285713635362.davem@davemloft.net>
References: <1394712342-15778-74-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-74-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Fri, 31 Oct 2014 13:35:57 +0800

> For Renesas USB 3.0 host controller, when unplugging the usb hub which
> has the RTL8153 plugged, the driver would get -EPROTO for interrupt
> transfer. There is high probability to get the information of "HC died;
> cleaning up", if the driver continues to submit the interrupt transfer
> before the disconnect() is called.
 ...
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thanks.
