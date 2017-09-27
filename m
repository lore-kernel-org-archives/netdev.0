From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] net: dsa: use generic slave phydev
Date: Tue, 26 Sep 2017 20:06:51 -0700 (PDT)
Message-ID: <20170926.200651.424252266139986002.davem@davemloft.net>
References: <20170926211535.21273-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926211535.21273-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 26 Sep 2017 17:15:30 -0400

> DSA currently stores a phy_device pointer in each slave private
> structure. This requires to implement our own ethtool ksettings
> accessors and such.
> 
> This patchset removes the private phy_device in favor of the one
> provided in the net_device structure, and thus allows us to use the
> generic phy_ethtool_* functions.

Series applied, thanks Vivien.
