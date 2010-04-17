From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 17:22:49 -0700
Message-ID: <i2s65634d661004161722hece6f9d4naf528c37b63fffbc@mail.gmail.com>
References: <1271446679.16881.4298.camel@edumazet-laptop>
	 <20100416.154932.147279343.davem@davemloft.net>
	 <20100416.155340.256882855.davem@davemloft.net>
	 <20100416.155707.66748057.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:49287 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932497Ab0DQAWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 20:22:52 -0400
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o3H0Mo2e027109
	for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 17:22:51 -0700
Received: from pwi9 (pwi9.prod.google.com [10.241.219.9])
	by wpaz33.hot.corp.google.com with ESMTP id o3H0MnUs032701
	for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 17:22:50 -0700
Received: by pwi9 with SMTP id 9so2458672pwi.27
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 17:22:49 -0700 (PDT)
In-Reply-To: <20100416.155707.66748057.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ugh, vmalloc.h must be sneaking in through some other header file for
me :-(  Sorry about that.  Do you need me to respin the patch?

Tom

On Fri, Apr 16, 2010 at 3:57 PM, David Miller <davem@davemloft.net> wrote:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 16 Apr 2010 15:53:40 -0700 (PDT)
>
>> From: David Miller <davem@davemloft.net>
>> Date: Fri, 16 Apr 2010 15:49:32 -0700 (PDT)
>>
>>> Great, I'll add this to net-next-2.6 right now.
>>
>> I had to add an include of linux/vmalloc.h to net/core/sysctl_net_core.c
>> to fix the build while committing this.
>
> net/core/net-sysfs.c needed it too :-/
>
