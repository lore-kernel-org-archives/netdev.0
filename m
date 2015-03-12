From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next V1 0/3] net/mlx4_core: Allow setting init-time
 device specific parameters
Date: Thu, 12 Mar 2015 15:31:30 -0400 (EDT)
Message-ID: <20150312.153130.1372889580818723770.davem@redhat.com>
References: <CAJL1qvHP0cLRVf53J9MuJrYCJLjE=mzEU70JofJ8zH_Yf-O16g@mail.gmail.com>
	<20150312.140505.1685428263314887570.davem@davemloft.net>
	<CAJL1qvHOFzAU=ciTR2A3AgoX622+c5wDYLEC07OaGwOZsC6jxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, amirv@mellanox.com,
	netdev@vger.kernel.org, hadarh@mellanox.com, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, talal@mellanox.com,
	shannon.nelson@intel.com, dledford@redhat.com,
	greearb@candelatech.com, gregory.v.rose@intel.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com
To: hadarh@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53398 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754184AbbCLTbl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2015 15:31:41 -0400
In-Reply-To: <CAJL1qvHOFzAU=ciTR2A3AgoX622+c5wDYLEC07OaGwOZsC6jxA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Date: Thu, 12 Mar 2015 20:59:26 +0200

> On Thu, Mar 12, 2015 at 8:05 PM, David Miller <davem@davemloft.net> wrote:
>> From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
>> Date: Thu, 12 Mar 2015 10:07:35 +0200
>>
>>> On Wed, Mar 11, 2015 at 7:14 PM, David Miller <davem@davemloft.net> wrote:
>>>>
>>>> From: Amir Vadai <amirv@mellanox.com>
>>>> Date: Wed, 11 Mar 2015 11:08:50 +0200
>>>>
>>>> > Also, customers are paying for a very sophisticated piece of
>>>> > hardware, and we would like to enable power user to tweak it in some
>>>> > situtations. Of course the default mode should be used in 99% of the
>>>> > use cases.
>>>>
>>>> How much money someone pays for your hardware has nothing to do with
>>>> the standards by which we design userspace interfaces to configure
>>>> these devices.
>>>>
>>>> These textual interfaces are arbitrary, and you are choosing it only
>>>> because you cannot come up with a more reasonable scheme,
>>>>
>>>> I'm not applying these changes.
>>>> --
>>>
>>> In previous conversations Greg suggested us to use configfs.
>>>
>>> Is this case a misuse of configfs?  maybe configfs should be deprecated... Greg?
>>>
>>> Is a scheme based on netlink will be acceptable by you?
>>
>> A portable, well typed, interface that other vendors could use if their
>> hardware had similar features would be acceptable.
> 
> Do you mean an interface implementation that reminds the ethtool
> private flags scheme but implemented through netlink, allows
> configuration without a netdevice and more flexibility?

I mean exactly what I said, neither more nor less.
