From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 11/12] net: dsa: mv88e6xxx: add Energy Detect
 ops
Date: Mon, 17 Jul 2017 13:45:49 -0700 (PDT)
Message-ID: <20170717.134549.2101398770863549187.davem@davemloft.net>
References: <20170717170346.19555-12-vivien.didelot@savoirfairelinux.com>
        <20170717192734.GD9363@lunn.ch>
        <87bmoiuae3.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        f.fainelli@gmail.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87bmoiuae3.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon, 17 Jul 2017 15:32:52 -0400

> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
>> I never liked this. I think it is architecturally wrong for the switch
>> to be poking around in the PHY. It should ask the PHY driver. This is
>> especially true for external PHYs which might not be a Marvell PHY.
> 
> I share the same concern. However this patch is just isolating the
> existing code so that we get rid of the last caps and flags and stop
> writing (without reading them first) arbitrary registers.
> 
> Once this portion is moved to the PHY driver, one can remove it from
> mv88e6xxx.

Seems a reasonable plan of action.

Andrew, do you agree?
