From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [RFC PATCH 00/18] netfilter: IPv6 NAT
Date: Tue, 29 Nov 2011 13:23:52 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1111291255200.20965@frira.zrqbmnf.qr>
References: <CAF9AA63.1622%ulrich.weber@sophos.com> <a2407c3b6405bd682cedad6db82cf225@treenet.co.nz> <4ED4A399.6090709@sophos.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Amos Jeffries <squid3@treenet.co.nz>,
	"sclark46@earthlink.net" <sclark46@earthlink.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ulrich Weber <ulrich.weber@sophos.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4ED4A399.6090709@sophos.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tuesday 2011-11-29 10:19, Ulrich Weber wrote:
> On 28.11.2011 23:03, Amos Jeffries wrote:
>> I'm going to dare to call FUD on those statements...
>>   * Load Balancing - what is preventing your routing rules or packet
>>  marking using the same criteria as the NAT changer? nothing. Load
>>  balancing works perfectly fine without NAT.

Source address selection, having to occur on the source, would
require that the source has to know all the parameters that a {what
would have been your NAT GW} would need to know, which means you have
to (a) collect and/or (b) distribute this information. Given two
uplinks that only allow a certain source network address (different
for each uplink), combined with the desire to balance on utilization,
(a) a client is not in the position to easily obtain this data unless
it is the router for all participants itself, (b) the clients needs
to cooperate, and one cannot always trust client devices, or hope for
their technical cooperation (firewalled themselves off).

Yes, NAT is evil, but if you actually think about it, policies are
best applied where [the policy] originates from. After all, we also
don't do LSRR, instead, routers do the routing, because they just
know much better.

> I fully agree. NAT can not replace your firewall rules.
>
> However with NAT you could get some kind of anonymity.

Same network prefix, some cookies, or a login form. Blam, identified,
or at least (Almost-)Uniquely Identified Visitor tagging.

Everybody should come out of their worshipping NAT for anonymity
now - at best, that is an Emperor's Clothes' kind of anonymity.

> Think of Tor: If your server/client operates with private IP addresses,
> your public IP address is still masked after a security breach.

If one's tor peer was busted, they would have the address.
