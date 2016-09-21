From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/5] r8152: correct the flow of PHY
Date: Wed, 21 Sep 2016 00:56:50 -0400 (EDT)
Message-ID: <20160921.005650.1495949763882776373.davem@davemloft.net>
References: <1394712342-15778-219-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-219-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 20 Sep 2016 16:22:04 +0800

> First, to enable the PHY as early as possible. Some settings may fail if the
> PHY is power down.
> 
> Move the other PHY settings to hw_phy_cfg() to make sure the order is correct.
> 
> Finally, disable ALDPS and EEE before updating the PHY for RTL8153.

Series applied, thanks.
