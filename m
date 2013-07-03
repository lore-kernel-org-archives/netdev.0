From: Ben Greear <greearb@candelatech.com>
Subject: Re: 3.9.5+:  Crash in tcp_input.c:4810.
Date: Tue, 02 Jul 2013 21:49:42 -0700
Message-ID: <51D3AD66.8030506@candelatech.com>
References: <51BF50B3.1080403@candelatech.com>   <1371493059.3252.200.camel@edumazet-glaptop>   <51D1C620.8030007@candelatech.com>  <1372813467.4979.46.camel@edumazet-glaptop>  <51D398C0.5060802@candelatech.com> <1372826512.4979.49.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38649 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193Ab3GCEuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 00:50:20 -0400
In-Reply-To: <1372826512.4979.49.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/2013 09:41 PM, Eric Dumazet wrote:
> On Tue, 2013-07-02 at 20:21 -0700, Ben Greear wrote:
>
>> What kinds of things could a driver do to cause this.  Maybe modify an
>> skb after it has sent it up the stack, or something like that?
>>
>
> It might be a genuine TCP bug, who knows...
>
>
>> We haven't been able to reproduce on a clean 3.10 yet...but it often takes days,
>> so we'll leave the test up through end of this week if we don't hit it
>> sooner...
>
> TCP collapse is/should be really rare, but losses can of course trigger
> it.

Well, network emulators are easy to come by in the office....  Maybe running
a bunch of TCP connections through a lossy network would exercise this code
path a bit?  Aside from random pkt loss, any other types of network conditions
that might help trigger this faster?

I'll set up some tests using some wired ethernet...if we can trigger it there
then we at least know it doesn't depend on ath9k...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
