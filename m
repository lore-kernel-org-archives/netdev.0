From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 11/12] net: dsa: mv88e6xxx: add Energy Detect ops
Date: Mon, 17 Jul 2017 15:32:52 -0400
Message-ID: <87bmoiuae3.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170717170346.19555-1-vivien.didelot@savoirfairelinux.com> <20170717170346.19555-12-vivien.didelot@savoirfairelinux.com> <20170717192734.GD9363@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170717192734.GD9363@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> I never liked this. I think it is architecturally wrong for the switch
> to be poking around in the PHY. It should ask the PHY driver. This is
> especially true for external PHYs which might not be a Marvell PHY.

I share the same concern. However this patch is just isolating the
existing code so that we get rid of the last caps and flags and stop
writing (without reading them first) arbitrary registers.

Once this portion is moved to the PHY driver, one can remove it from
mv88e6xxx.

Thanks,

        Vivien
