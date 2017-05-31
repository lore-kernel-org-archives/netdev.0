From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: remove dev arg of
 dsa_register_switch
Date: Wed, 31 May 2017 12:36:01 -0400 (EDT)
Message-ID: <20170531.123601.869584973980453827.davem@davemloft.net>
References: <20170526221251.14972-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170526221251.14972-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri, 26 May 2017 18:12:51 -0400

> The current dsa_register_switch function takes a useless struct device
> pointer argument, which always equals ds->dev.
> 
> Drivers either call it with ds->dev, or with the same device pointer
> passed to dsa_switch_alloc, which ends up being assigned to ds->dev.
> 
> This patch removes the second argument of the dsa_register_switch and
> _dsa_register_switch functions.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Those invariants seem to hold indeed, so this looks fine, applied.
