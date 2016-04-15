From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 4/7] net: dsa: mv88e6xxx: add family to info
Date: Fri, 15 Apr 2016 17:06:41 -0400
Message-ID: <871t661t0e.fsf@ketchup.mtl.sfl>
References: <1460744750-13896-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1460744750-13896-5-git-send-email-vivien.didelot@savoirfairelinux.com> <20160415191149.GA18523@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <notmuch-sha1-5b8efc36765bacf253ff62234056042d5c4c5c37>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vivien Didelot <vivien.didelot@savoirfairelinux.com> writes:

>>> +	{ MV88E6XXX_INFO(6165, 0x165, "Marvell 88E6165") },
>>
>> I think 
>>
>>> +	{ MV88E6XXX_INFO(MV88E6XXX_FAMILY_6165, 0x165, "Marvell 88E6165") },
>>
>> is clearer. It is hard to know what these values mean unless you go
>> look at the macro.
>
> Same goes for the MV88E6XXX_INFO macro... I wanted to avoid long lines
> while keeping the info table clear enough.
>
>     MV88E6XXX_INFO(0x121, "Marvell 88E6123",
>                    MV88E6XXX_FAMILY_6165,) },
>    /*             Family   Prod   Name             */
>    { MV88E6XXX_INFO(6165, 0x121, "Marvell 88E6123") },
>    { MV88E6XXX_INFO(6165, 0x161, "Marvell 88E6161") },
>    { MV88E6XXX_INFO(6165, 0x165, "Marvell 88E6165") },
>    { MV88E6XXX_INFO(6165, 0x165, "Marvell 88E6165") },
>
> But I don't really mind in fact, we'll do as you guys wish.

Oops, sent too fast. Thinking about that, I'll just keep plain struct
mv88e6xxx_info in the tables and we will maybe introduce such macro when
merging everything together.

Thanks,
Vivien
