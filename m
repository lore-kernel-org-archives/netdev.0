From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 10/11] net: dsa: mv88e6xxx: remove EEE support
Date: Tue, 1 Aug 2017 19:27:57 +0200
Message-ID: <20170801172757.GL23157@lunn.ch>
References: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
 <20170731221719.16695-11-vivien.didelot@savoirfairelinux.com>
 <20170801142843.GE23157@lunn.ch>
 <87r2wv2tci.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20170801160628.GJ23157@lunn.ch>
 <17c26dee-c285-4dd5-1be0-286c0126d4db@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <17c26dee-c285-4dd5-1be0-286c0126d4db@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> If the MAC does not support EEE but the PHY does I think you can still
> allow EEE to be advertised and enabled, you just won't have the MAC be
> able to leverage the power savings that EEE brings. AFAICT this is still
> a valid mode whereby the PHY is put in a lower power mode, just not the
> whole transmit path (MAC + PHY).

Hi Florian

I read a couple of datasheets for a few phys doing EEE. Both said the
same, the MAC has to indicate to the PHY when low power should be
entered and existed. The PHY itself does not appear to do anything on
its own.

It would be good to read the standards about this. But i don't think
we should tell userspace EEE is enabled, if the PHY has it enabled,
but the MAC is not capable and hence EEE is not actually being used at
all.

	Andrew
