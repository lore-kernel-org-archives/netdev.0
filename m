From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: qca_spi: Fix alignment issues in rx path
Date: Thu, 11 May 2017 12:14:39 -0400 (EDT)
Message-ID: <20170511.121439.1848705853202049320.davem@davemloft.net>
References: <1494337238-1699-1-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: stefan.wahren@i2se.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494337238-1699-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Wahren <stefan.wahren@i2se.com>
Date: Tue,  9 May 2017 15:40:38 +0200

> The qca_spi driver causes alignment issues on ARM devices.
> So fix this by using netdev_alloc_skb_ip_align().
> 
> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
> Fixes: 291ab06ecf67 ("net: qualcomm: new Ethernet over SPI driver for QCA7000")

Applied.
