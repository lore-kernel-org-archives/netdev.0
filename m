From: Max Krasnyanskiy <maxk@qualcomm.com>
Subject: Re: RFC [PATCH net-2.6 1/6] net: Scheduling softirqs between CPUSs
Date: Fri, 07 Mar 2008 11:02:31 -0800
Message-ID: <47D19147.9070609@qualcomm.com>
References: <20080305205116.5989A412541@localhost> <20080305.132112.01598419.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@elte.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:23018 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755605AbYCGTCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 14:02:34 -0500
In-Reply-To: <20080305.132112.01598419.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: therbert@google.com (Tom Herbert)
> Date: Wed,  5 Mar 2008 12:51:16 -0800 (PST)
> 
>> This patch implements kernel changes to allow scheduling of softirq's between processors.
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
> 
> I've stated this in the past and I still feel that it is foolish to
> put all of this code into the kernel when every single piece of
> networking hardware will be doing this for us transparently.
> 
> Maybe if someone had proposed this 4 or 5 years ago, but right now
> this code will be irrelevant by the time it ships to any real users.

Plus it seems that for this kind of stuff it be better to replace network 
softirq with kthreads (like in -rt kernel) and let the scheduler take care of 
the load balancing. More flexible and scalable.
I'd suggest for your to play with -rt kernel and see if it already does what 
you need.

Max

