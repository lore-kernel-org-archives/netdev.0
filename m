From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 00/17] net: dsa: mv88e6xxx: rework ATU support
Date: Mon, 13 Mar 2017 10:52:10 -0400
Message-ID: <874lyxp6ud.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com> <d6ad6ba8-3b60-d017-24a9-1f19649d7b4d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d6ad6ba8-3b60-d017-24a9-1f19649d7b4d@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> Just some general note on the way the driver seems to be going there
> seems to be a multiplication of new ops being introduced, and most of
> them seem to default to the mv88e6xxx (generic) ones. Should you do
> something like:
>
> if (!ops->foo)
> 	ops->foo = mv88e6xxx_foo
>
> Such that you reduce the possibility for a specific switch model to lack
> such an operation?

You are correct, ideally generic library functions (the one starting
with the mv88e6xxx_ prefix) should not be assigned to ops.

The ops are const though. I'll come up with something maintainable.

Thanks!

        Vivien
