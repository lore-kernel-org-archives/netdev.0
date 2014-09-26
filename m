From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: fix the carrier off when autoresuming
Date: Fri, 26 Sep 2014 16:13:30 -0400 (EDT)
Message-ID: <20140926.161330.1243504275428423559.davem@davemloft.net>
References: <1394712342-15778-45-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-45-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 23 Sep 2014 16:31:47 +0800

> netif_carrier_off would be called when autoresuming, even though
> the cable is plugged. This causes some applications do relative
> actions when detecting the carrier off. Keep the status of the
> carrier, and let it be modified when the linking change occurs.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thanks.
