From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 04/11] net: dsa: mv88e6xxx: add port FID accessors
Date: Wed, 02 Nov 2016 02:01:20 +0100
Message-ID: <87vaw64rvj.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <20161101032023.32762-1-vivien.didelot@savoirfairelinux.com> <20161101032023.32762-5-vivien.didelot@savoirfairelinux.com> <20161101093819.GA2802@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161101093819.GA2802@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> --- a/drivers/net/dsa/mv88e6xxx/port.c
>> +++ b/drivers/net/dsa/mv88e6xxx/port.c
>> @@ -61,6 +61,8 @@ int mv88e6xxx_port_set_state(struct mv88e6xxx_chip *chip, int port, u8 state)
>>  	return 0;
>>  }
>>  
>> +/* Offset 0x05: Port Control 1 */
>> +
>>  /* Offset 0x06: Port Based VLAN Map */
>>  
>>  int mv88e6xxx_port_set_vlan_map(struct mv88e6xxx_chip *chip, int port, u16 map)
>
> This comment seems in an odd place.

It isn't. Port's default FID uses register 0x05 and I document them
above the related functions.

Thanks,

        Vivien
