From: Ben Greear <greearb@candelatech.com>
Subject: Re: question on pktgen shutdown logic.
Date: Wed, 22 May 2013 16:52:22 -0700
Message-ID: <519D5A36.6030000@candelatech.com>
References: <519D519B.8040406@candelatech.com>  <1369264921.3301.370.camel@edumazet-glaptop>  <519D54A8.4090707@candelatech.com> <1369265749.3301.372.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44720 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756611Ab3EVXwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 19:52:23 -0400
In-Reply-To: <1369265749.3301.372.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2013 04:35 PM, Eric Dumazet wrote:
> On Wed, 2013-05-22 at 16:28 -0700, Ben Greear wrote:
>
>> Ahh, so it waits for the pktgen_thread_worker method to return?
>>
>> Why do we bother with the pktgen_exiting flag at all...it
>> would seem that just checking kthread_should_stop() would
>> do the trick?
>
> If you have 4096 cpus, setting pktgen_exiting permits all pktgen exiting
> faster.
>
> Otherwise you wait about 400 seconds (4096 * HZ/10)

Ok, I think I understand now.

Thanks,
Ben

>
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
