From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: handle state correctly in phy_stop_machine
Date: Fri, 24 Mar 2017 12:27:57 -0700 (PDT)
Message-ID: <20170324.122757.1841749078351719249.davem@davemloft.net>
References: <1490214421-7269-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: zach.brown@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490214421-7269-1-git-send-email-zach.brown@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zach Brown <zach.brown@ni.com>
Date: Wed, 22 Mar 2017 15:27:01 -0500

> From: Nathan Sullivan <nathan.sullivan@ni.com>
> 
> If the PHY is halted on stop, then do not set the state to PHY_UP.  This
> ensures the phy will be restarted later in phy_start when the machine is
> started again.
> 
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
> Signed-off-by: Brad Mouring <brad.mouring@ni.com>
> Acked-by: Xander Huff <xander.huff@ni.com>
> Acked-by: Kyle Roeschley <kyle.roeschley@ni.com>

Applied and queued up for -stable, thanks.
