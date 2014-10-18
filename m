From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: return -EBUSY for runtime suspend
Date: Fri, 17 Oct 2014 23:46:53 -0400 (EDT)
Message-ID: <20141017.234653.505926640053533707.davem@davemloft.net>
References: <87zjcvgn1x.fsf@nemi.mork.no>
	<1394712342-15778-65-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-65-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Fri, 17 Oct 2014 16:55:08 +0800

> Remove calling cancel_delayed_work_sync() for runtime suspend,
> because it would cause dead lock. Instead, return -EBUSY to
> avoid the device enters suspending if the net is running and
> the delayed work is pending or running. The delayed work would
> try to wake up the device later, so the suspending is not
> necessary.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied.
