From: Ben Greear <greearb@candelatech.com>
Subject: Re: 3.9.5+:  Crash in tcp_input.c:4810.
Date: Mon, 08 Jul 2013 10:23:51 -0700
Message-ID: <51DAF5A7.60505@candelatech.com>
References: <51BF50B3.1080403@candelatech.com>    <1371493059.3252.200.camel@edumazet-glaptop>    <51D1C620.8030007@candelatech.com>   <1372813467.4979.46.camel@edumazet-glaptop>   <51D398C0.5060802@candelatech.com>  <1372826512.4979.49.camel@edumazet-glaptop>  <51D3AD66.8030506@candelatech.com> <1372827749.4979.52.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:58179 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894Ab3GHRXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 13:23:53 -0400
In-Reply-To: <1372827749.4979.52.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/2013 10:02 PM, Eric Dumazet wrote:
> On Tue, 2013-07-02 at 21:49 -0700, Ben Greear wrote:
>
>> Well, network emulators are easy to come by in the office....  Maybe running
>> a bunch of TCP connections through a lossy network would exercise this code
>> path a bit?  Aside from random pkt loss, any other types of network conditions
>> that might help trigger this faster?
>>
>> I'll set up some tests using some wired ethernet...if we can trigger it there
>> then we at least know it doesn't depend on ath9k...
>
> I tried a lot of things, including netem with many reorders and/or
> packetdrill tests, but so far not a single warning from tcp_collapse()

We ran a 5+ day test using un-modified 3.10 kernel and did not trigger
the bug.

So, I'm guessing the problem is either fixed upstream or is exacerbated
or caused by our local patches.  Sometime soon we'll start porting local
patches to newer kernels...we'll see what happens then.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
