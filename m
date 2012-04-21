From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/19] net: Sysctl simplifications and
 enhancements
Date: Fri, 20 Apr 2012 21:24:21 -0400 (EDT)
Message-ID: <20120420.212421.411640492608879760.davem@davemloft.net>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
	<4F912240.8010802@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, serge@hallyn.com,
	gaofeng@cn.fujitsu.com, pablo@netfilter.org, shemminger@vyatta.com
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38040 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119Ab2DUBZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 21:25:40 -0400
In-Reply-To: <4F912240.8010802@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Fri, 20 Apr 2012 12:45:52 +0400

> On 04/20/2012 03:17 AM, Eric W. Biederman wrote:
>> 
>> Summary:
>> - Kill approximately 400 lines of code
>> - Allow all networking sysctls with just CAP_NET_ADMIN
>> - Hide all networking sysctls that don't apply to your current network namespace.
>> - Uniformly register flat sysctl tables not sysctl tables with .child entries
>> - Readable string paths for registering sysctls
>> 
>> Eric W. Biederman (19):
>>       net: Implement register_net_sysctl.
>>       net sysctl:  Register an empty /proc/sys/net
>>       net sysctl: Initialize the network sysctls sooner to avoid problems.
>>       net: Kill register_sysctl_rotable
>>       net: Move all of the network sysctls without a namespace into init_net.
>>       net core: Remove unneded creation of an empty  net/core sysctl directory
>>       net ipv6: Remove unneded registration of an empty net/ipv6/neigh
>>       net ipv4: Remove the unneeded registration of an empty net/ipv4/neigh
>>       net ax25: Simplify and cleanup the ax25 sysctl handling.
>>       net llc: Don't use sysctl tables with .child entries.
>>       net ipv6: Don't use sysctl tables with .child entries.
>>       net neighbour:  Convert to use register_net_sysctl
>>       net decnet:  Convert to use register_net_sysctl
>>       net ipv6:  Convert addrconf to use register_net_sysctl
>>       net ipv4:  Convert devinet to use register_net_sysctl
>>       net: Convert nf_conntrack_proto to use register_net_sysctl
>>       net: Convert all sysctl registrations to register_net_sysctl
>>       net: Delete all remaining instances of ctl_path
>>       net: Remove register_net_sysctl_table
> 
> After resolving issues with Eric
> 
> Acked-by: Pavel Emelyanov <xemul@parallels.com>

Series applied, thanks everyone.
