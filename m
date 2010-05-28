From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev/fec: fix ifconfig eth0 down hang issue
Date: Fri, 28 May 2010 03:40:48 -0700 (PDT)
Message-ID: <20100528.034048.35019513.davem@davemloft.net>
References: <1275037685-14555-1-git-send-email-bryan.wu@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@gmail.com, s.hauer@pengutronix.de, gerg@uclinux.org,
	amit.kucheria@canonical.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bryan.wu@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1275037685-14555-1-git-send-email-bryan.wu@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bryan Wu <bryan.wu@canonical.com>
Date: Fri, 28 May 2010 17:08:05 +0800

> BugLink: http://bugs.launchpad.net/bugs/559065
> 
> In fec open/close function, we need to use phy_connect and phy_disconnect
> operation before we start/stop phy. Otherwise it will cause system hang.
> 
> Only call fec_enet_mii_probe() in open function, because the first open
> action will cause NULL pointer error.
> 
> Signed-off-by: Bryan Wu <bryan.wu@canonical.com>

Applied, thanks.
