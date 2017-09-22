From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/4] net: dsa: make slave close symmetrical to
 open
Date: Fri, 22 Sep 2017 18:34:16 +0200
Message-ID: <20170922163416.GB3470@lunn.ch>
References: <20170922161753.19563-1-vivien.didelot@savoirfairelinux.com>
 <20170922161753.19563-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170922161753.19563-4-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 22, 2017 at 12:17:52PM -0400, Vivien Didelot wrote:
> The DSA slave open function configures the unicast MAC addresses on the
> master device, enable the switch port, change its STP state, then start
> the PHY device.
> 
> Make the close function symmetric, by first stopping the PHY device,
> then changing the STP state, disabling the switch port and restore the
> master device.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
