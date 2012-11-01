From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next 1/8] bridge: bridge port parameters over netlink
Date: Wed, 31 Oct 2012 18:33:29 -0700
Message-ID: <5091D169.9070302@intel.com>
References: <20121030005731.843020405@vyatta.com> <20121030005835.289407930@vyatta.com> <50912F4D.2090602@intel.com> <20121031143020.62e08062@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:48412 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754479Ab2KABde (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2012 21:33:34 -0400
In-Reply-To: <20121031143020.62e08062@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>> here I added nested bridge attributes to IFLA_AF_SPEC and pass them down
>> to the drivers as needed. Should we merge these two sets so that we have
>> only a single nested set of bridge attributes? Either in IFLA_AF_SPEC or
>> IFLA_PROTINFO.
>>

[...]

>
> This is an area where there is no clear choice.
> I would like to keep AF_UNSPEC for non-protocol stuff,
> that is why I targeted PF_BRIDGE:IFLA_PROTINFO.
>

Works for me.

> Other alternative would be to add sysctl which is less message
> based, but is more general. (ie. /default and /all are available).
>

I would just assume use netlink seeing this is common for all the other
networking bits and any networking app is already likely to be handling
these events.

.John
