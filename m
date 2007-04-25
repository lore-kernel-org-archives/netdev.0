From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: sysctls
Date: Wed, 25 Apr 2007 14:06:34 -0600
Message-ID: <m1irbkqkvp.fsf@ebiederm.dsl.xmission.com>
References: <20070425122924.88391585.akpm@linux-foundation.org>
	<20070425.130011.21926881.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:37498 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993045AbXDYUHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 16:07:33 -0400
In-Reply-To: <20070425.130011.21926881.davem@davemloft.net> (David Miller's
	message of "Wed, 25 Apr 2007 13:00:11 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Wed, 25 Apr 2007 12:29:24 -0700
>
>> 
>> I note that the networking tree is adding new sysctls:
>> 
>> <<<<<<< HEAD/include/linux/sysctl.h
>>         NET_IPV6_ACCEPT_SOURCE_ROUTE=25,
>> =======
>>         NET_IPV6_OPTIMISTIC_DAD=24,
>>         NET_IPV6_ACCEPT_SOURCE_ROUTE=25,
>> >>>>>>> /include/linux/sysctl.h
>> 
>> (Well, it's trying to - there are some git rejects in net-2.6.22)
>
> I knew this was going to happen because of Yoshifuji's
> security fix, the conflict is trivial to resolve.
>
> I'll rebase the net-2.6.22 tree later today since all
> we should have before 2.6.21-final is the netlink
> OOPS'er fix Alexey just posted.

David for clarity do you happen to know of anyone using binary
sysctl values?

In particular is there any reason not to use CTL_UNNUMBERED
for new networking sysctls?

Eric

