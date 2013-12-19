From: Ben Greear <greearb@candelatech.com>
Subject: Re: Multicast routing stops functioning after 4G multicast packets
 recived.
Date: Thu, 19 Dec 2013 07:15:37 -0800
Message-ID: <52B30D99.5090504@candelatech.com>
References: <20131219144816.33310@gmx.com> <20131219150923.GB24118@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Bob Falken <NetFestivalHaveFun@gmx.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50374 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753159Ab3LSPQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 10:16:13 -0500
In-Reply-To: <20131219150923.GB24118@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/2013 07:09 AM, Hannes Frederic Sowa wrote:
> On Thu, Dec 19, 2013 at 03:48:16PM +0100, Bob Falken wrote:
>> Hello, I have an issue after kernel 2.6.37 and above.
>> If i roll back to kernel 2.6.36.4 everything is fine.
>> if recive more than 4294967295 multicast packets, the kernel does not register the multicast packets. and multicast routing does not functioning.
>> (Tested bouth FIB_HASH and FIB_TRIE)
>> Tested with xorp and pimd.
>> I have abount 24 multicast groups, and it takes me about 17hours to reproduce the issue after a reboot.
>> Reboot is reqired to fix the issue. (Tested to stop/start pimd/xorp, reload network module for the network interface "e1000e",
>> Used birdge adapter and remove bridge adapter and readd bridge adapter to clear counters. none of thouse solves the issue.)
>
> Please test this with a recent kernel. 2.6.37 is really old and you normally
> won't get good support here with such old kernels.

Note that he did test up to 3.11.9 and it still showed failures.

Thanks,
Ben

>
> Greetings,
>
>    Hannes
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
