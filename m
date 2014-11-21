From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/2] r8152: adjust rx functions
Date: Fri, 21 Nov 2014 14:53:34 -0500 (EST)
Message-ID: <20141121.145334.65720125038869042.davem@davemloft.net>
References: <1394712342-15778-88-Taiwan-albertk@realtek.com>
	<1394712342-15778-98-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-98-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 20 Nov 2014 10:29:04 +0800

> v3:
> For patch #1, remove unnecessary initialization for ret and
> unnecessary blank line in r8152_submit_rx().
> 
> v2:
> For patch #1, set actual_length to 0 before adding the rx to the
> list, when a error occurs.
> 
> For patch #2, change the flow. Stop submitting the rx if a error
> occurs, and add the remaining rx to the list for submitting later.
> 
> v1:
> Adjust some flows and codes which are relative to r8152_submit_rx()
> and rtl_start_rx().

Series applied, thanks.
