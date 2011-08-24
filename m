From: Ben Greear <greearb@candelatech.com>
Subject: Re: Interface without IP address can route??
Date: Wed, 24 Aug 2011 09:20:10 -0700
Message-ID: <4E5524BA.3070303@candelatech.com>
References: <4E5443CD.60502@candelatech.com> <1314190890.25967.114.camel@mojatatu> <4E54FBA6.6090905@candelatech.com> <20110824161557.GC611458@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, jamal <hadi@cyberus.ca>,
	netdev <netdev@vger.kernel.org>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60644 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751655Ab1HXQU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 12:20:57 -0400
In-Reply-To: <20110824161557.GC611458@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2011 09:15 AM, David Lamparter wrote:
> On Wed, Aug 24, 2011 at 06:24:54AM -0700, Ben Greear wrote:
>> On 08/24/2011 06:01 AM, jamal wrote:
>>> It makes sense to behave this way.
>>> IPv4 addresses are owned by the system not interfaces.
>>> If you want to control the forwarding behavior, control ARP so it doesnt
>>> respond on the interfaces with no IP.
>
> I agree.
>
>> I understand your argument about IPs being owned by system instead of
>> interface, but I think it's the wrong behaviour in this case.  Can
>> you think of any case where this behaviour actually helps?
>
> It's used for oddball /32 setups at server hosting farms that look like:
>        /--- eth0, no ip ---- server 0.1.4.5/32, default via 0.1.2.3
> router --- eth1, no ip ---- server 0.1.6.7/32, default via 0.1.2.3
>        \--- eth2, no ip ---- server 0.1.8.9/32, default via 0.1.2.3
>     \- eth3: 0.1.2.3/28 - to rest of internet
>
> The general idea is to a) conserve IPs and b) not renumber servers even
> when they move, so you end up with random scattered /32s on the servers
> and the router has no sensible IP.
>
>> Either way, it appears I can work around this by explicitly disabling
>> forwarding for this particular interface.
>
> I was about to suggest exactly this :)

Ok..glad to know there are folks with even crazier setups than mine :)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
