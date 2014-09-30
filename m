From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: fix setting RTL8152_UNPLUG
Date: Tue, 30 Sep 2014 16:24:13 -0400 (EDT)
Message-ID: <20140930.162413.1928220515698421769.davem@davemloft.net>
References: <1394712342-15778-50-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-50-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 30 Sep 2014 16:48:01 +0800

> The flag of RTL8152_UNPLUG should only be set when the device is
> unplugged, not each time the rtl8152_disconnect() is called.
> Otherwise, the device wouldn't be stopped normally.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thanks.
