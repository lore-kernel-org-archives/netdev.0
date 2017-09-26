From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net] net: dsa: mv88e6xxx: lock mutex when freeing IRQs
Date: Tue, 26 Sep 2017 14:01:11 -0400
Message-ID: <87mv5h5ogo.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170926174837.15999-1-vivien.didelot@savoirfairelinux.com> <20170926180136.GD3325@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926180136.GD3325@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> In general, i tried to keep the mutex out of the interrupt code.  That
> is not totally possible, the IRQ thread handler needs it. But
> otherwise, the IRQ code assumes it is called with the mutex taken.
>
> So i think it is better to hold the mutex in mv88e6xxx_remove() when
> calling mv88e6xxx_g1_irq_free().

I'd prefer that too. Respinning, thanks!


    Vivien
