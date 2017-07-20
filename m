From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: b53: Add missing ARL entries for BCM53125
Date: Thu, 20 Jul 2017 15:22:19 -0700 (PDT)
Message-ID: <20170720.152219.1741032866987867477.davem@davemloft.net>
References: <20170720192522.18048-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170720192522.18048-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 20 Jul 2017 12:25:22 -0700

> The BCM53125 entry was missing an arl_entries member which would
> basically prevent the ARL search from terminating properly. This switch
> has 4 ARL entries, so add that.
> 
> Fixes: 1da6df85c6fb ("net: dsa: b53: Implement ARL add/del/dump operations")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable, thanks.
