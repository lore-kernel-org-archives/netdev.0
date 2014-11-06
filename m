From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8152: disable the tasklet by default
Date: Wed, 05 Nov 2014 22:17:34 -0500 (EST)
Message-ID: <20141105.221734.1934150161399944443.davem@davemloft.net>
References: <1394712342-15778-83-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-83-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Wed, 5 Nov 2014 10:17:02 +0800

> Let the tasklet only be enabled after open(), and be disabled for
> the other situation. The tasklet is only necessary after open() for
> tx/rx, so it could be disabled by default.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thanks.
