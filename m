From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: Add support for 64-bit statistics
Date: Wed, 02 Aug 2017 16:49:51 -0700 (PDT)
Message-ID: <20170802.164951.1316163070425929253.davem@davemloft.net>
References: <20170801220036.11355-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801220036.11355-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue,  1 Aug 2017 15:00:36 -0700

> DSA slave network devices maintain a pair of bytes and packets counters
> for each directions, but these are not 64-bit capable. Re-use
> pcpu_sw_netstats which contains exactly what we need for that purpose
> and update the code path to report 64-bit capable statistics.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.

I would run ethtool -S and ifconfig under perf to see where it is
spending so much time.
