From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next V1 1/9] IB/ipoib: Add support for clones / multiple
 childs on the same partition
Date: Wed, 18 Jul 2012 15:11:16 -0700
Message-ID: <50073484.9070501@intel.com>
References: <1342609202-32427-2-git-send-email-ogerlitz@mellanox.com> <20120718.113850.305478348143779010.davem@davemloft.net> <CAJZOPZ+v291u5fSxJBu6q86LSpGAUgxLkhQb-ucL+g=hXba8cQ@mail.gmail.com> <20120718.143608.2101579052587289420.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, shlomop@mellanox.com, erezsh@mellanox.co.il
To: David Miller <davem@davemloft.net>, or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:24646 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753351Ab2GRWLS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 18:11:18 -0400
In-Reply-To: <20120718.143608.2101579052587289420.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/18/2012 2:36 PM, David Miller wrote:
> From: Or Gerlitz <or.gerlitz@gmail.com>
> Date: Thu, 19 Jul 2012 00:24:58 +0300
>
>> On Wed, Jul 18, 2012 at 9:38 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Or Gerlitz <ogerlitz@mellanox.com>
>>
>>>> All sorts of childs are still created/deleted through sysfs, in a
>>>> similar manner to the way legacy child interfaces are.
>>
>>> Network device instantiation of this type is the domain of
>>> rtnl_link_ops rather than ugly sysfs interfaces.
>>
>> Didn't add any **new** sysfs interfaces in this patch. The IPoIB sysfs
>> entries to create child devices are there from IPoIB's day one, and
>> we're only extending them a tiny bit.
>
> That's extremely unfortunate, having private ways of instantiating
> networking devices leads to an extremely poor user experience.
>
> Would you like to have to train every single user in the case
> where each and every driver author makes his own unique way
> of configuring his hardware?
> --

Or,

I've got a rough patch to use rtnl_link_ops to add what we've been
calling 'virtual machine device queues' or VMDq. This looks a lot
like macvlan with offloaded switching and I believe similar to your
child case above.

Also what is a "pkey"

I'll post it as a use at your own risk shortly although this week I'm
short on time so maybe next week I can get something more "real" out.
Been stealing cycles between other work things today.

If you want to do complete it more power to you.

.John
