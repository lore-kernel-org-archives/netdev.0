From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/19] netfilter: IPv6 NAT
Date: Sun, 26 Aug 2012 20:06:59 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208262005400.28940@stinky-local.trash.net>
References: <1344542943-11588-1-git-send-email-kaber@trash.net>
 <5038233F.7000202@tomt.net> <5038278A.6080901@tomt.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Andre Tomt <andre@tomt.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <5038278A.6080901@tomt.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 25 Aug 2012, Andre Tomt wrote:

> On 25. aug. 2012 02:58, Andre Tomt wrote:
>> On 09. aug. 2012 22:08, kaber@trash.net wrote:
>>> The following patches contain an updated version of IPv6 NAT against
>>> Linus' current tree.
>> 
>> Hmmm. Looking in my crystal ball (hi #ipv6!), I predict that if this
>> lands in mainline - and thus in consumer CPE/routers eventually - many
>> ISP's will have little incentive to actually implement assigning of
>> blocks to their consumer users like they "have to" today.
>> 
>> We have this wonderful chance of fixing a major problem with todays
>> internet, but now we are going down this very slippery slope.
>> 
>> I do need this code for a experimental project myself, and acknowledge
>> there may be some valid use cases, but I do not like the global
>> implications one bit.
>> 
>> At least some big fat warnings please?
>
> Clarification: This is about the NAT66 port-based 1:n NAT targets.

We can certainly add a warning to the Kconfig text or (better) the
iptables manpage. But only a very small percentage of people who
might end up (unknowingly) using this will ever see them.

Feel free to send a patch though.
