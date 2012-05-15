From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next 0/2] extend sch_mqprio to distribute traffic
 not only by ETS TC
Date: Tue, 15 May 2012 09:44:42 -0700
Message-ID: <4FB287FA.2060507@intel.com>
References: <1336287910-12010-1-git-send-email-amirv@mellanox.com> <4FA86EB8.2050006@intel.com> <4FA92606.6070401@mellanox.com> <4FAA0D2C.6040306@intel.com> <4FB15BEC.8040000@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Oren Duer <oren@mellanox.com>,
	Liran Liss <liranl@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Diego Crupnicoff <Diego@Mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41156 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933073Ab2EOQoq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2012 12:44:46 -0400
In-Reply-To: <4FB15BEC.8040000@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/14/2012 12:24 PM, Amir Vadai wrote:
>>>> On 5/6/2012 12:05 AM, Amir Vadai wrote:
>>>>> This series comes to revive the discussion initiated on the thread "net:
>>>>> support tx_ring per UP in HW based QoS mechanism" (see
>>>>> http://marc.info/?t=133165957200004&r=1&w=2) with the major issue to be address
>>>>> is - how should sk_prio<=>    TC be done, for both, tagged and untagged traffic.
>>>>> Following is a staged description addressing the background, problem
>>>>> description, current situation, suggestion for the change and implementation of
>>>>> it.

[...]

> John Hi,
> 
> After some internal discussions, it was agreed to line up with your
> approach, to leave mqprio an abstract skb->priority <=> queue set
> mapping and to ignore egress_map if mqprio is enabled.
> 

OK sounds good.

> It would be very nice, if the term 'tc' in kernel code would be
> replaced to queue set, since it is very misleading.
> 

Go ahead and write up a patch. Just be careful not to break existing
user visible API. I agree it is confusing.

> There still might be some small issues with skb_tx_hash for tagged
> traffic, which I will work on tomorrow, and hopefully will send a new
> patch set with the solution.
> 

What are the issues? Lets see a patch.

Thanks,
John
