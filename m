From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: RE: [PATCH net-next 5/5] net: dsa: split dsa_port's netdev member
Date: Fri, 13 Oct 2017 10:26:21 -0400
Message-ID: <87y3ofi0oi.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20171012225156.20758-1-vivien.didelot@savoirfairelinux.com> <20171012225156.20758-6-vivien.didelot@savoirfairelinux.com> <5b637ea3-6c4b-1d93-ed43-09038af473f9@gmail.com> <063D6719AE5E284EB5DD2968C1650D6DD0094DFE@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel\@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: David Laight <David.Laight@ACULAB.COM>,
        'Florian Fainelli' <f.fainelli@gmail.com>,
        "netdev\@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0094DFE@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

David Laight <David.Laight@ACULAB.COM> writes:

> From: Florian Fainelli
>> Sent: 13 October 2017 00:05
> ...
>> How about using:
>> 
>> 	union {
>> 		struct net_device *master;
>> 		struct net_device *slave;
>> 	} netdev;
> ...
>
> You can remove the 'netdev' all the compilers support unnamed unions.

There are issues with older GCC versions, see the commit 42275bd8fcb3
("switchdev: don't use anonymous union on switchdev attr/obj structs")

That's why I kept it in the v2 I sent.


Thanks,

        Vivien
