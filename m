From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: RE: [PATCH net-next 5/5] net: dsa: split dsa_port's netdev member
Date: Fri, 13 Oct 2017 12:50:29 -0400
Message-ID: <87infjm1pm.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20171012225156.20758-1-vivien.didelot@savoirfairelinux.com> <20171012225156.20758-6-vivien.didelot@savoirfairelinux.com> <5b637ea3-6c4b-1d93-ed43-09038af473f9@gmail.com> <063D6719AE5E284EB5DD2968C1650D6DD0094DFE@AcuExch.aculab.com> <87y3ofi0oi.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <874lr3vzg4.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <063D6719AE5E284EB5DD2968C1650D6DD0094FEF@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Lunn <andrew@lunn.ch>,
        "kernel\@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>,
        'Florian Fainelli' <f.fainelli@gmail.com>,
        "netdev\@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0094FEF@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

David Laight <David.Laight@ACULAB.COM> writes:

> From: Vivien Didelot
>> Sent: 13 October 2017 16:29
>> Vivien Didelot <vivien.didelot@savoirfairelinux.com> writes:
>> 
>> >>> How about using:
>> >>>
>> >>> 	union {
>> >>> 		struct net_device *master;
>> >>> 		struct net_device *slave;
>> >>> 	} netdev;
>> >> ...
>> >>
>> >> You can remove the 'netdev' all the compilers support unnamed unions.
>> >
>> > There are issues with older GCC versions, see the commit 42275bd8fcb3
>> > ("switchdev: don't use anonymous union on switchdev attr/obj structs")
>> >
>> > That's why I kept it in the v2 I sent.
>> 
>> At the same time, I can see that struct sk_buff uses anonym union a lot.
>> 
>> It seems weird that one raised a compiler issue for switchdev but not
>> for skbuff.h... Do you think it is viable to drop the name here then?
>
> I believe the problem is with initialisers for static structures
> that contain anonymous unions.

The dsa_port structures are dynamically allocated so this seems safe to
use an anonymous union here.

BTW v2 never left my computer in fact, so this will be fixed up in v2.


Thanks!

        Vivien
