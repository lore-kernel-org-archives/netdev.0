From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 net-next v2 12/12] net: dsa: mv88e6xxx: add support for DSA ageing time
Date: Mon, 18 Jul 2016 15:59:38 -0400
Message-ID: <87eg6q3efp.fsf@ketchup.mtl.sfl>
References: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com> <20160718184628.13103-13-vivien.didelot@savoirfairelinux.com> <20160718191644.GG31103@lunn.ch> <87d1malpcd.fsf@ketchup.mtl.sfl> <20160718193253.GJ31103@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160718193253.GJ31103@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Lunn <andrew@lunn.ch> writes:

>> Nope, the bridge ageing time is not per-port, even though switchdev ops
>> are per-port by design. This is a switch-wide attribute.
>
> So you are saying the core is doing all the reference counting, etc,
> when swapping between fast and slow ageing?

I don't see how checking for the fastest ageing time would fix support
for multiple bridges... I think that would make the code much more
complex for a small value. Multiple logical bridges on top of a single
physical switch is still a tricky topic.

Maybe we can keep it simple for the moment with this switch-wide
set_ageing_time operation, and later add a patch for the DSA layer to
cache and elect the ageing time per-port or per-bridge.

Thanks,

        Vivien
