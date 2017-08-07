From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: User per-cpu 64-bit statistics
Date: Sun, 06 Aug 2017 21:27:05 -0700 (PDT)
Message-ID: <20170806.212705.710269830764257465.davem@davemloft.net>
References: <20170804043328.4730-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemlot.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170804043328.4730-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu,  3 Aug 2017 21:33:27 -0700

> During testing with a background iperf pushing 1Gbit/sec worth of
> traffic and having both ifconfig and ethtool collect statistics, we
> could see quite frequent deadlocks. Convert the often accessed DSA slave
> network devices statistics to per-cpu 64-bit statistics to remove these
> deadlocks and provide fast efficient statistics updates.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied with appropriate Fixes: tag added.

Thanks.
