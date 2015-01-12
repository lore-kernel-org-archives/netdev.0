From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2 RESEND] r8152: adjust r8152_submit_rx
Date: Mon, 12 Jan 2015 16:11:01 -0500 (EST)
Message-ID: <20150112.161101.337036741119753652.davem@davemloft.net>
References: <1394712342-15778-114-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-114-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Fri, 9 Jan 2015 10:26:34 +0800

> v2:
> Replace the patch #1 with "call rtl_start_rx after netif_carrier_on".
> 
> For patch #2, replace checking tp->speed with netif_carrier_ok.
> 
> v1:
> Avoid r8152_submit_rx() from submitting rx during unexpected
> moment. This could reduce the time of stopping rx.
> 
> For patch #1, the tp->speed should be updated early. Then,
> the patch #2 could use it to check the current linking status.

Series applied, thanks.
