From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 2/3] net: dsa: mv88e6xxx: make switchdev DB ops generic
Date: Wed, 31 Aug 2016 11:05:58 -0400
Message-ID: <87bn09x9k9.fsf@ketchup.mtl.sfl>
References: <20160829203246.18811-1-vivien.didelot@savoirfairelinux.com> <20160829203246.18811-3-vivien.didelot@savoirfairelinux.com> <20160831134943.GB15078@lunn.ch> <87shtlvw8c.fsf@ketchup.mtl.sfl> <20160831145303.GE15078@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160831145303.GE15078@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Lunn <andrew@lunn.ch> writes:

>> No. mv88e6xxx_port_db_dump already exists, this is the function called
>> mv88e6xxx_port_db_dump_one multiple time. Here, _one refers to an FID
>> (forwarding database). 88E6352 have 4096 FIDs.
>
> So maybe s/_one/_fid/ ?

If I have to respin this series, sure.

Thanks Andrew,

       Vivien
