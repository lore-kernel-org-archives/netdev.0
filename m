From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 11/12] net: dsa: mv88e6xxx: add Energy Detect ops
Date: Tue, 18 Jul 2017 14:59:44 -0400
Message-ID: <87d18xpo4f.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170717210405.GC11719@lunn.ch> <20170717.141048.999243831453421230.davem@davemloft.net> <e65f425d-d6c2-f1c3-ea92-c2a0878add44@gmail.com> <20170718.104636.315406311682846961.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: David Miller <davem@davemloft.net>, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170718.104636.315406311682846961.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

David Miller <davem@davemloft.net> writes:

> However, in this particular case, this issue was brought to Vivien's
> attention multiple times in the past.
>
> And I think the direct PHY poking issue is much more important than
> these seemingly endless reorganizations of the driver that Vivien is
> doing.
>
> So I personally share Andrew's serious frustration that we are doing
> constant reorgs but not addressing directly the specific issues that
> one has been made clearly aware of.

We support 26 Marvell Ethernet switch chips, so I am often comparing the
documentation of many of them to make sure the driver stops writing
arbitrary registers, ending up with many inconsistencies (like Remote
Management being currently enabled on all chips with an RMU, fix coming)
mainly due to poor documentation and device setup.

I know this looks boring, I do not particularly enjoy it myself, but I
think this is also important. I don't mind fixing the poking function as
well in the near future.


Thanks,

        Vivien
