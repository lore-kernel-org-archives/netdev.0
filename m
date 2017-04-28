From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 17/18] net: dsa: mv88e6xxx: support the VTU Page bit
Date: Fri, 28 Apr 2017 10:25:15 -0400
Message-ID: <87vapo38z8.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com> <20170426155336.5937-18-vivien.didelot@savoirfairelinux.com> <20170428125353.GK13231@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170428125353.GK13231@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> +	if (val & GLOBAL_VTU_VID_PAGE)
>> +		entry->vid |= 0x1000;
>
> I'm undecided myself, so i will just bring it up for discussion.
>
> Maybe it would be more readable to say:
>
> 		entry->vid += 4096;
>
> ???

VID values are usually 12-bit. Marvell uses 13-bit VID values for the
88E6390 family. Because Marvell is Marvell, the 13th bit of the VID is
the 14th bit of the VID register.

It feels natural to me to stay bitwise here when handling VID values.

That's not a big deal though, one can make it clearer later if needed.

Thanks,

        Vivien
