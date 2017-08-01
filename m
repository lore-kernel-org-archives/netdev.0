From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 10/11] net: dsa: mv88e6xxx: remove EEE support
Date: Tue, 01 Aug 2017 16:08:15 -0400
Message-ID: <87d18fkq4w.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com> <20170731221719.16695-11-vivien.didelot@savoirfairelinux.com> <20170801142843.GE23157@lunn.ch> <87r2wv2tci.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <20170801160628.GJ23157@lunn.ch> <87h8xrfdrp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87h8xrfdrp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vivien Didelot <vivien.didelot@savoirfairelinux.com> writes:

> Second option is: we keep it KISS and let the driver define its noop,
> but as I explain, it is confusing, especially for the get operation.

In fact we should be good because the DSA layer will call
ds->ops->{g,s}et_mac_eee before phy_ethtool_{g,s}et_eee, so if the DSA
driver didn't touch the ethtool_eee structure, the PHY ops will anyway.

I'm sending a v2 right away.


Thanks,

        Vivien
