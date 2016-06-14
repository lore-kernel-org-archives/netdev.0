From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 net-next v2 11/12] net: dsa: mv88e6xxx: add an SMI ops structure
Date: Tue, 14 Jun 2016 18:26:44 -0400
Message-ID: <87y467z9sr.fsf@ketchup.mtl.sfl>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com> <20160614183153.32327-12-vivien.didelot@savoirfairelinux.com> <20160614220435.GI12832@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160614220435.GI12832@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> +struct mv88e6xxx_smi_ops {
>> +	int (*read)(struct mii_bus *bus, int sw_addr,
>> +		    int addr, int reg, u16 *val);
>> +	int (*write)(struct mii_bus *bus, int sw_addr,
>> +		     int addr, int reg, u16 val);
>> +};
>> +
>
> I think this API would be better if it used ps, not bus and sw_addr.
>
> The only problem is the very first read to get the switch ID. I would
> add one more layer in between, so that you can call the lowest level
> functions without having a ps structure.

That's why I keep it simple for the moment.

The low-level API using ps is now _mv88e6xxx_reg_{read,write}. I can
rename them to mv88e6xxx_smi_{read,write} in v3 or later.

Thanks,

        Vivien
