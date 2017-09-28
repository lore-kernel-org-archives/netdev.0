From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: Fix network device registration order
Date: Thu, 28 Sep 2017 10:13:36 -0700 (PDT)
Message-ID: <20170928.101336.44666443551339165.davem@davemloft.net>
References: <20170925225553.566-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170925225553.566-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 25 Sep 2017 15:55:53 -0700

> We cannot be registering the network device first, then setting its
> carrier off and finally connecting it to a PHY, doing that leaves a
> window during which the carrier is at best inconsistent, and at worse
> the device is not usable without a down/up sequence since the network
> device is visible to user space with possibly no PHY device attached.
> 
> Re-order steps so that they make logical sense. This fixes some devices
> where the port was not usable after e.g: an unbind then bind of the
> driver.
> 
> Fixes: 0071f56e46da ("dsa: Register netdev before phy")
> Fixes: 91da11f870f0 ("net: Distributed Switch Architecture protocol support")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable.
