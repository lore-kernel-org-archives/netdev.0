From: Amos Jeffries <squid3@treenet.co.nz>
Subject: Re: [RFC PATCH 00/18] netfilter: IPv6 NAT
Date: Wed, 30 Nov 2011 02:24:26 +1300
Message-ID: <4ED4DD0A.7030005@treenet.co.nz>
References: <CAF9AA63.1622%ulrich.weber@sophos.com> <a2407c3b6405bd682cedad6db82cf225@treenet.co.nz> <4ED4A399.6090709@sophos.com> <alpine.LNX.2.01.1111291255200.20965@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ulrich Weber <ulrich.weber@sophos.com>,
	"sclark46@earthlink.net" <sclark46@earthlink.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1111291255200.20965@frira.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30/11/2011 1:23 a.m., Jan Engelhardt wrote:
> On Tuesday 2011-11-29 10:19, Ulrich Weber wrote:
>> On 28.11.2011 23:03, Amos Jeffries wrote:
>>> I'm going to dare to call FUD on those statements...
>>>    * Load Balancing - what is preventing your routing rules or packet
>>>   marking using the same criteria as the NAT changer? nothing. Load
>>>   balancing works perfectly fine without NAT.
> Source address selection, having to occur on the source, would
> require that the source has to know all the parameters that a {what
> would have been your NAT GW} would need to know, which means you have
> to (a) collect and/or (b) distribute this information. Given two
> uplinks that only allow a certain source network address (different
> for each uplink), combined with the desire to balance on utilization,
> (a) a client is not in the position to easily obtain this data unless
> it is the router for all participants itself,

There you are adding a straw-man component into the mix. "Given two 
uplinks that only allow a certain source network address ", yes I agree, 
NAT is the sugar that makes these uplinks work. Irrelevant of load 
balancing.

In the same way the security != NAT, so too load balancing != NAT. As 
I'm sure you are all well aware.

Looking back at Ulrichs' original statement after reading yours it's 
clear he probably meant that (I hope so at least). The first reading 
though was that NAT by itself provided easy load balancing and DMZ.  I 
argue neither for or against validity of NAT. Just the Fuzziness 
Uncertainty and Doubt created by the particular statement was of a high 
amount.

>   (b) the clients needs
> to cooperate, and one cannot always trust client devices, or hope for
> their technical cooperation (firewalled themselves off).
>
>

>> I fully agree. NAT can not replace your firewall rules.
>>
>> However with NAT you could get some kind of anonymity.
> Same network prefix, some cookies, or a login form. Blam, identified,
> or at least (Almost-)Uniquely Identified Visitor tagging.
>
> Everybody should come out of their worshipping NAT for anonymity
> now - at best, that is an Emperor's Clothes' kind of anonymity.
>
>> Think of Tor: If your server/client operates with private IP addresses,
>> your public IP address is still masked after a security breach.
> If one's tor peer was busted, they would have the address.
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

