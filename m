From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 22/23] [PATCH] [XFRM] POLICY: Support netlink socket interface
 for sub policy.
Date: Wed, 02 Aug 2006 10:46:50 +0900
Message-ID: <44D0040A.6040908@linux-ipv6.org>
References: <1154165455769-git-send-email-nakam@linux-ipv6.org> <20060801.172403.64001463.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:58769 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1750972AbWHBBqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 21:46:53 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060801.172403.64001463.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Date: Sat, 29 Jul 2006 18:30:55 +0900
> 
>> diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
>> index 901bb65..68d3443 100644
>> --- a/include/linux/xfrm.h
>> +++ b/include/linux/xfrm.h
>> @@ -303,12 +303,14 @@ #define XFRM_POLICY_BLOCK	1
>>  	__u8				flags;
>>  #define XFRM_POLICY_LOCALOK	1	/* Allow user to override global policy */
>>  	__u8				share;
>> +	__u8				type;
>>  };
>>  
>>  struct xfrm_userpolicy_id {
>>  	struct xfrm_selector		sel;
>>  	__u32				index;
>>  	__u8				dir;
>> +	__u8				type;
>>  };
>>  
>>  struct xfrm_user_acquire {
> 
> Again, these are user visible data structures which cannot be
> modified without changing the API.  Please use another xfrm
> netlink attribute or similar to pass this information.

I'll try to add XFRMA_POLICY_TYPE for this case.
Thanks,


-- 
Masahide NAKAMURA
