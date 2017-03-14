From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: debug ATU Age Time
Date: Tue, 14 Mar 2017 09:56:41 -0400
Message-ID: <87inncj71i.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170313192043.12478-1-vivien.didelot@savoirfairelinux.com> <20170313223932.GC14183@lunn.ch> <b7d0e92f-45cb-929d-a724-2a582621f8e1@gmail.com> <20170313225845.GE14183@lunn.ch> <535be006-e384-aca3-ee8b-4ed36b66b97a@neratec.com> <20170314120539.GT15842@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Jason Cobham <jcobham@questertangent.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Matthias May <matthias.may@neratec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314120539.GT15842@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> The never ever seeing R/W failure on MDIO bus is not exactly accurate.
>> We had with art (atheros calibration tool) the problem that interrupts
>> were being disabled which lead to MDIO operations running into
>> timout/failing.
>
> Yes, i've seen similar with power management bugs for the MDIO
> driver. But you get a cascade of failures, lots of warnings and error
> prints, it is clear something bad has happened, and the switch is in
> an inconsistent state. So having one more debug print which is also
> inconsistent does no really harm.
>
> Anyway, this whole conversation has taken more effort than just making
> this simple change to remove a few lines of code. So lets drop it and
> move on.

I don't understand nor agree with the fact that sometimes it's OK to not
check for errors, based on one developer assumptions. Not checking
return code is wrong and very likely error-prone.

If you really want to stand for that point, please send a patch series
which turns mv88e6xxx_read() and mv88e6xxx_write() into void functions.
I'd be glad to review and discuss this further. That would indeed make
*all* the driver code simpler.

Thanks,

        Vivien
