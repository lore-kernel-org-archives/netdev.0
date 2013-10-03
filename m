From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atl1e: enable support for NETIF_F_RXALL and
 NETIF_F_RXCRC features
Date: Thu, 03 Oct 2013 17:01:26 -0400 (EDT)
Message-ID: <20131003.170126.2297161431158026731.davem@davemloft.net>
References: <1380827917-22992-1-git-send-email-andrea.merello@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jie.yang@atheros.com, xiong.huang@atheros.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: andrea.merello@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380827917-22992-1-git-send-email-andrea.merello@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrea Merello <andrea.merello@gmail.com>
Date: Thu,  3 Oct 2013 21:18:37 +0200

> This patch allows (optionally, via ethtool) the atl1e NIC to:
> - Receive bad frames (runt, bad-fcs, etc..)
> - Receive full frames without stripping the FCS.
> 
> This has been tested on my board by injecting runt and bad-fcs
> frames with a FPGA-based device.
> 
> The particular scenario of receiving very short frames (<4 bytes)
> without passing FCS to the upper layer has been also tested:
> This could be potentially dangerous because the driver performs a
> 4 byte subtraction on the frame length, but I finally have NOT
> added anything to avoid this because it seems the NIC always
> discards frames so much short..
> If someone still have some reason to worry about this, please
> tell me.. I will add an explicit SW check..
> 
> Signed-off-by: Andrea Merello <andrea.merello@gmail.com>

Looks good, applied, thanks Andrea.
