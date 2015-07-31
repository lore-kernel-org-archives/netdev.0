From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8152: disable the capability of zero length
Date: Fri, 31 Jul 2015 15:25:10 -0700 (PDT)
Message-ID: <20150731.152510.581787329996480106.davem@davemloft.net>
References: <1394712342-15778-165-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-165-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Fri, 31 Jul 2015 11:23:39 +0800

> The UEFI driver would enable zero length, and the Linux driver doesn't
> need it. Zero length let the hw complete the transfer with length 0,
> when there is no received packet. It would add the load of USB host
> controller and reduce the performance.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied.
