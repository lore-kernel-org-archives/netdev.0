From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: NULL out phydev after removing mdio bus
Date: Fri, 07 Oct 2016 23:57:18 -0400 (EDT)
Message-ID: <20161007.235718.1329800164848117692.davem@davemloft.net>
References: <1475853202-19903-1-git-send-email-xander.huff@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
        nathan.sullivan@ni.com, linux-kernel@vger.kernel.org,
        brad.mouring@ni.com
To: xander.huff@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475853202-19903-1-git-send-email-xander.huff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xander Huff <xander.huff@ni.com>
Date: Fri, 7 Oct 2016 10:13:22 -0500

> From: Nathan Sullivan <nathan.sullivan@ni.com>
> 
> To ensure the dev->phydev pointer is not used after becoming invalid in
> mdiobus_unregister, set it to NULL. This happens when removing the macb
> driver without first taking its interface down, since unregister_netdev
> will end up calling macb_close.
> 
> Signed-off-by: Xander Huff <xander.huff@ni.com>
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
> Signed-off-by: Brad Mouring <brad.mouring@ni.com>

Applied.
