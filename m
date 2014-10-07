From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH v1 1/3] net: sched: af_packet support for direct
 ring access
Date: Mon, 06 Oct 2014 21:25:12 -0700
Message-ID: <54336B28.4030003@intel.com>
References: <20141006000629.32055.2295.stgit@nitbit.x32> <20141006.174243.1946917197540493301.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, fw@strlen.de, gerlitz.or@gmail.com,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	john.ronciak@intel.com, amirv@mellanox.com, eric.dumazet@gmail.com,
	danny.zhou@intel.com
To: David Miller <davem@davemloft.net>, john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:6212 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750895AbaJGEZd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 00:25:33 -0400
In-Reply-To: <20141006.174243.1946917197540493301.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/2014 02:42 PM, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Sun, 05 Oct 2014 17:06:31 -0700
> 
>> This patch adds a net_device ops to split off a set of driver queues
>> from the driver and map the queues into user space via mmap. This
>> allows the queues to be directly manipulated from user space. For
>> raw packet interface this removes any overhead from the kernel network
>> stack.
> 
> About the facility in general, I am generally in favor, as I expressed
> at the networking track in Chiacgo.
> 
> But you missed the mark wrt. describing the descriptors.
> 
> I do not want you to give device IDs.
> 
> I want the code to be %100 agnostic to device or vendor IDs.
> 

OK. I'll work on this and have a v2 after net-next opens again.

Thanks!

> Really "describe" the descriptor.  Not just how large is it (32-bits,
> 64-bits, etc.), but also: 1) is it little or big endian 2) where is
> the length field 3) where is control bit "foo" located, etc.
> 
> That's what I want to see in "struct tpacket_dev_info", rather than
> device IDs and "versions".
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
