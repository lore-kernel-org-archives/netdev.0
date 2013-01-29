From: Ben Greear <greearb@candelatech.com>
Subject: Re: Can we replace the msleep(250) in dev.c  netdev_wait_allrefs?
Date: Tue, 29 Jan 2013 12:24:19 -0800
Message-ID: <51082FF3.4090805@candelatech.com>
References: <51082A64.2090702@candelatech.com> <1359490897.30177.4.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38174 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751647Ab3A2UYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 15:24:20 -0500
In-Reply-To: <1359490897.30177.4.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/29/2013 12:21 PM, Eric Dumazet wrote:
> On Tue, 2013-01-29 at 12:00 -0800, Ben Greear wrote:
>> I think there was a proposal to change it to schedule_timeout_uninterruptible(1);
>> some time ago, but that change never made it upstream (at least not in 3.7.5)?
>>
>> Thanks,
>> Ben
>>
>
> Honestly we should fix the bug at this point, not hide it.
>
> We could use msleep(2500) to make sure people will complain ;)

Well, few will notice that either, or at least are unlikely
to know what to blame.

If we should just never reach that code, maybe a WARN_ON_ONCE() when
we do?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
