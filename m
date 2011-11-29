From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: [RFC PATCH 00/18] netfilter: IPv6 NAT
Date: Tue, 29 Nov 2011 22:38:47 +0100
Message-ID: <4ED550E7.1090609@ans.pl>
References: <CAF9AA63.1622%ulrich.weber@sophos.com> <a2407c3b6405bd682cedad6db82cf225@treenet.co.nz> <4ED4A399.6090709@sophos.com> <alpine.LNX.2.01.1111291255200.20965@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Weber <ulrich.weber@sophos.com>,
	Amos Jeffries <squid3@treenet.co.nz>,
	"sclark46@earthlink.net" <sclark46@earthlink.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1111291255200.20965@frira.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2011-11-29 13:23, Jan Engelhardt wrote:
>
> On Tuesday 2011-11-29 10:19, Ulrich Weber wrote:
>> On 28.11.2011 23:03, Amos Jeffries wrote:
>>> I'm going to dare to call FUD on those statements...
>>>    * Load Balancing - what is preventing your routing rules or pack=
et
>>>   marking using the same criteria as the NAT changer? nothing. Load
>>>   balancing works perfectly fine without NAT.
>
> Source address selection, having to occur on the source, would
> require that the source has to know all the parameters that a {what
> would have been your NAT GW} would need to know, which means you have
> to (a) collect and/or (b) distribute this information. Given two
> uplinks that only allow a certain source network address (different
> for each uplink), combined with the desire to balance on utilization,
> (a) a client is not in the position to easily obtain this data unless
> it is the router for all participants itself, (b) the clients needs
> to cooperate, and one cannot always trust client devices, or hope for
> their technical cooperation (firewalled themselves off).
>
> Yes, NAT is evil, but if you actually think about it, policies are
> best applied where [the policy] originates from. After all, we also
> don't do LSRR, instead, routers do the routing, because they just
> know much better.
>
>> I fully agree. NAT can not replace your firewall rules.
>>
>> However with NAT you could get some kind of anonymity.
>
> Same network prefix, some cookies, or a login form. Blam, identified,
> or at least (Almost-)Uniquely Identified Visitor tagging.

But without NAT you have pretty big chance to have the same IPv6=20
*suffix* everywhere, based on you MAC address. In your Home, your Work,=
=20
in a Cafe or in a hotel during your vacations in Portugal. So yes, NAT=20
is not a perfect solution but it really helps you privacy.

Best regards,

			Krzysztof Ol=C4=99dzki

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
