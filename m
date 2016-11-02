From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 08/11] net: dsa: mv88e6xxx: add port duplex setter
Date: Wed, 02 Nov 2016 02:12:03 +0100
Message-ID: <87pome4rdo.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <20161101032023.32762-1-vivien.didelot@savoirfairelinux.com> <20161101032023.32762-9-vivien.didelot@savoirfairelinux.com> <20161101094440.GC2802@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161101094440.GC2802@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>>  	int (*port_set_link)(struct mv88e6xxx_chip *chip, int port, int link);
>> +
>> +	/* Port's MAC duplex mode
>> +	 *
>> +	 * Use DUPLEX_HALF or DUPLEX_FULL to force half or full duplex, or
>> +	 * DUPLEX_UNKNOWN for normal duplex detection.
>> +	 */
>> +	int (*port_set_duplex)(struct mv88e6xxx_chip *chip, int port, int dup);
>
> Again, i think DUPLEX_UNFORCED, or DUPLEX_AUTO would be better.

DUPLEX_UNKNOWN and SPEED_UNKNOWN are existing values used by the
phy/ethtool interface for the phy_device. I prefered to use them when
possible instead of creating new ones.

Thanks,

        Vivien
