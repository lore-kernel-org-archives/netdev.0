From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 3/6] net: dsa: mv88e6xxx: add a software reset op
Date: Thu, 01 Dec 2016 15:41:20 -0500
Message-ID: <87vav3gz67.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <20161130225930.25510-1-vivien.didelot@savoirfairelinux.com> <20161130225930.25510-4-vivien.didelot@savoirfairelinux.com> <20161130232633.GS21645@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161130232633.GS21645@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
>> index ab52c37..9e51405 100644
>> --- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
>> +++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
>> @@ -765,6 +765,9 @@ struct mv88e6xxx_ops {
>>  	int (*phy_write)(struct mv88e6xxx_chip *chip, int addr, int reg,
>>  			 u16 val);
>>  
>> +	/* Switch Software Reset */
>> +	int (*reset)(struct mv88e6xxx_chip *chip);
>> +
>
> Hi Vivien
>
> In my huge patch series of 6390, i've been using a g1_ prefix for
> functionality which is in global 1, g2_ for global 2, etc.  This has
> worked for everything so far with the exception of setting which
> reserved MAC addresses should be sent to the CPU. Most devices have it
> in g2, but 6390 has it in g1.
>
> Please could you add the prefix.

I don't understand. It looks like you are talking about the second part
of the comment I made on your RFC patchset, about the Rsvd2CPU feature:

https://www.mail-archive.com/netdev@vger.kernel.org/msg139837.html

Switch reset routines are implemented in this patch in global1.c as
mv88e6185_g1_reset and mv88e6352_g1_reset.

6185 and 6352 are implementation references for other switches.

Thanks,

        Vivien
