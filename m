From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH iproute2 v2] vxlan: Allow setting destination to
 unicast address.
Date: Thu, 11 Apr 2013 13:30:14 -0400 (EDT)
Message-ID: <20130411.133014.1750297317239802950.davem@davemloft.net>
References: <87li8pmkvh.wl%atzm@stratosphere.co.jp>
	<20130411082438.7fe3421b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: atzm@stratosphere.co.jp, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36838 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935754Ab3DKRaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 13:30:16 -0400
In-Reply-To: <20130411082438.7fe3421b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 11 Apr 2013 08:24:38 -0700

> On Thu, 11 Apr 2013 19:17:54 +0900
> Atzm Watanabe <atzm@stratosphere.co.jp> wrote:
> 
>> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
>> index 40167af..0bf03dc 100644
>> --- a/include/linux/if_link.h
>> +++ b/include/linux/if_link.h
>> @@ -296,6 +296,7 @@ enum {
>>  	IFLA_VXLAN_GROUP,
>>  	IFLA_VXLAN_LINK,
>>  	IFLA_VXLAN_LOCAL,
>> +	IFLA_VXLAN_REMOTE,
>>  	IFLA_VXLAN_TTL,
>>  	IFLA_VXLAN_TOS,
> 
> You can't insert another value into the middle of an enum list.
> It changes the kernel-userspace ABI values.

Right.
