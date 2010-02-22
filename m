From: Cong Wang <amwang@redhat.com>
Subject: Re: [net-next PATCH v5 2/3] sysctl: add proc_do_large_bitmap
Date: Mon, 22 Feb 2010 10:45:44 +0800
Message-ID: <4B81EFD8.8020202@redhat.com>
References: <1266752533.3428.28.camel@Nokia-N900-42-11>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58215 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754050Ab0BVCmQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Feb 2010 21:42:16 -0500
In-Reply-To: <1266752533.3428.28.camel@Nokia-N900-42-11>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila wrote:
> 
> But I think its worth to keep the whitespaces in beetween, e.g. allow
> 
> $ echo '1, 2 ,3 ' >   ip_local_reserved_ports.


Sure.

> 
>> Also, if I write an invalid value, it does reject this, but the previous
>> value in that file is cleared, shouldn't we keep the previous one?
>>
>>
> 
> The only way I see to fix this is to return EINVAL if we detect a write with offset.


Yeah, we shouldn't continue once we find any invalid value.

> 
> IMO we should do that for the other proc write routines as well, as otherwise ther result is confusing, e.g.
> 
> write("1 2"); write(" 3");
> 
> will set first value in the vector to 1, than second value to 2 then *first* value to 3.
> 
> I am all for it, but again, this changes userspace ABI. 

Sorry, is this related with the problem I mentioned above? Both "1 2"
and " 3" are valid values.

Thanks.
