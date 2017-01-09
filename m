From: michael-dev <michael-dev@fami-braun.de>
Subject: Re: [PATCH net-next] bridge: multicast to unicast
Date: Mon, 09 Jan 2017 16:25:54 +0100
Message-ID: <ebc5050e12c04273fa518e35d7f0b8bc@fami-braun.de>
References: <20170102193214.31723-1-linus.luessing@c0d3.blue>
 <1483706872.4089.8.camel@sipsolutions.net>
 <8836daaa-9638-4502-d079-fd428595f822@nbd.name>
 <1483710841.12677.1.camel@sipsolutions.net>
 <22fad045-57c6-7789-d19f-f47bd0faf441@fami-braun.de>
 <20170107145516.GE3134@otheros> <1483949336.17582.3.camel@sipsolutions.net>
 <6f5ec9f1-800a-2bc4-2f41-9d803343bb22@fami-braun.de>
 <1483964159.17582.34.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Linus_L=C3=BCssing?= <linus.luessing@c0d3.blue>,
        Felix Fietkau <nbd@nbd.name>, netdev@vger.kernel.org,
        "David S . Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483964159.17582.34.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 09.01.2017 13:15, schrieb Johannes Berg:
>> That is bridge fdb entries (need to) expire so the bridge might
>> "forget" a still-connected station not sending but only consuming
>> broadcast traffic.
> 
> Ok, that I don't know. Somehow if you address a unicast packet there
> the bridge has to make a decision - so it really should know?

If the bridge has not learned the unicast destination mac address on any 
port, it will flood the packet on all ports except the port it received 
the packet on.

Regards,
M. Braun
