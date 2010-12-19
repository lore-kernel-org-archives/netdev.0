From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: Re: [PATCH] iproute2: ip: add wilcard support for device matching
Date: Sun, 19 Dec 2010 09:32:17 +0000 (UTC)
Message-ID: <4D0FAD26.8050908@rosedu.org>
References: <1291993092-8675-1-git-send-email-opurdila@ixiacom.com>	 <201012101932.59352.opurdila@ixiacom.com>	 <1292002959.3580.321.camel@edumazet-laptop>	 <201012102006.03401.opurdila@ixiacom.com> <1292593088.2668.43.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:35105 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753820Ab0LSJbu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Dec 2010 04:31:50 -0500
Date: Mon, 20 Dec 2010 11:23:18 -0800
In-Reply-To: <1292593088.2668.43.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2010 5:38 AM, jamal wrote:
> On Fri, 2010-12-10 at 20:06 +0200, Octavian Purdila wrote:
>
>>> $ ip link add link bond0 "vlan\*199" type vlan id 199
>>> $ ifconfig "vlan\*199"
>>
>> :) Then use a special dev keyword like dev* ?
>>
>> $ ip link set dev* dummy set
>>
>> Or use a new flag to allow expansion?
>>
>> $ ip -e link set dev dummy* set
>
> There was something ive always wanted to do but
> havent had time. It will cut time in a big way the
> user-kernel interaction in precisely your situation.
>
> Add a new general purpose netdev 32 bit tag. You can use this
> feature to "group" netdevs. The group "all netdevs" is 0 - which
> is the default.
> I can group individual dummy interfaces into group 1.
> ip link dev dummy0 set group 1
> ..
> ..
> ip link dev dummy99 set group 1
>
> Then i can send a query to only ifup and ignore
> the 1000 vlans that exist.
>
> ip link dev ls group 1
>
> or if i didnt list the group, then group 0 is assumed.

I'll try to implement this approach in the next few days.

Vlad
