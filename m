From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: qca_spi: Don't clear IFF_BROADCAST
Date: Thu, 25 Feb 2016 16:14:37 -0500 (EST)
Message-ID: <20160225.161437.1865514268079345124.davem@davemloft.net>
References: <1456255404-8668-1-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: stefan.wahren@i2se.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456255404-8668-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Wahren <stefan.wahren@i2se.com>
Date: Tue, 23 Feb 2016 19:23:23 +0000

> Currently qcaspi_netdev_setup accidentally clears IFF_BROADCAST.
> So fix this by keeping the flags from ether_setup.
> 
> Reported-by: Michael Heimpold <michael.heimpold@i2se.com>
> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
> Fixes: 291ab06ecf67 (net: qualcomm: new Ethernet over SPI driver for QCA7000)

Applied and queued up for -stable.
