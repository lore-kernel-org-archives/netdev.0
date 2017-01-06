From: Felix Fietkau <nbd@nbd.name>
Subject: Re: [PATCH net-next] bridge: multicast to unicast
Date: Fri, 6 Jan 2017 14:54:55 +0100
Message-ID: <21c1c361-eef0-aa53-ecd5-b5154c51462d@nbd.name>
References: <20170102193214.31723-1-linus.luessing@c0d3.blue>
 <1483706872.4089.8.camel@sipsolutions.net>
 <8836daaa-9638-4502-d079-fd428595f822@nbd.name>
 <1483710841.12677.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        Michael Braun <michael-dev@fami-braun.de>
To: Johannes Berg <johannes@sipsolutions.net>,
        =?UTF-8?Q?Linus_L=c3=bcssing?= <linus.luessing@c0d3.blue>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483710841.12677.1.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-01-06 14:54, Johannes Berg wrote:
> 
>> The bridge layer can use IGMP snooping to ensure that the multicast
>> stream is only transmitted to clients that are actually a member of
>> the group. Can the mac80211 feature do the same?
> 
> No, it'll convert the packet for all clients that are behind that
> netdev. But that's an argument for dropping the mac80211 feature, which
> hasn't been merged upstream yet, no?
Right.

- Felix
