From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ipsec-next v2] xfrm: Use VRF master index if output
 device is enslaved
Date: Tue, 25 Aug 2015 11:25:20 -0700 (PDT)
Message-ID: <20150825.112520.1150630275289755593.davem@davemloft.net>
References: <1440108390-10192-1-git-send-email-dsa@cumulusnetworks.com>
	<E97BEDFF-A3B2-41B4-A669-969E7052C75E@cumulusnetworks.com>
	<20150821203132.GA3589@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@cumulusnetworks.com, dsa@cumulusnetworks.com,
	netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58696 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755497AbbHYSZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 14:25:22 -0400
In-Reply-To: <20150821203132.GA3589@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 21 Aug 2015 22:31:32 +0200

> On Fri, Aug 21, 2015 at 02:11:21AM +0300, Nikolay Aleksandrov wrote:
>> 
>> > On Aug 21, 2015, at 1:06 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> > 
>> > Directs route lookups to VRF table. Compiles out if NET_VRF is not
>> > enabled. With this patch able to successfully bring up ipsec tunnels
>> > in VRFs, even with duplicate network configuration.
>> > 
>> > Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>> > ---
>> > v2
>> > - use vrf_master_ifindex rather than vrf_master_ifindex_rcu
>> > 
>> > net/ipv4/xfrm4_policy.c | 7 +++++--
>> > net/ipv6/xfrm6_policy.c | 7 +++++--
>> > 2 files changed, 10 insertions(+), 4 deletions(-)
>> > 
>> 
>> Looks good to me,
>> 
>> Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> David, can you please take this directly into net-next?
> 
> Acked-by: Steffen Klassert <steffen.klassert@secunet.com>

Ok, done, thanks.
