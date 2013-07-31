From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] net: split rt_genid for ipv4 and ipv6
Date: Wed, 31 Jul 2013 14:57:10 -0700 (PDT)
Message-ID: <20130731.145710.1507535169314670977.davem@davemloft.net>
References: <1375144433-731-1-git-send-email-fan.du@windriver.com>
	<20130730070702.GG2490@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fan.du@windriver.com, nicolas.dichtel@6wind.com,
	yoshfuji@linux-ipv6.org, jmorris@namei.org,
	steffen.klassert@secunet.com, paul@paul-moore.com,
	netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33621 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753732Ab3GaV5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 17:57:11 -0400
In-Reply-To: <20130730070702.GG2490@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 30 Jul 2013 09:07:02 +0200

> On Tue, Jul 30, 2013 at 08:33:53AM +0800, Fan Du wrote:
>> Current net name space has only one genid for both IPv4 and IPv6, it has below
>> drawbacks:
>> 
>> - Add/delete an IPv4 address will invalidate all IPv6 routing table entries.
>> - Insert/remove XFRM policy will also invalidate both IPv4/IPv6 routing table
>>   entries even when the policy is only applied for one address family.
>> 
>> Thus, this patch attempt to split one genid for two to cater for IPv4 and IPv6
>> separately in a fine granularity.
>> 
>> Signed-off-by: Fan Du <fan.du@windriver.com>
> 
> Also this patch only applies with some fuzz, it addressed all my issues:
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks.
