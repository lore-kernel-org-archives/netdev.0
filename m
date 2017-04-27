From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 6/6] bpf: show bpf programs
Date: Thu, 27 Apr 2017 18:28:17 +0200
Message-ID: <d99407db-895c-01c0-8e26-c6bd2b79d4ff@stressinduktion.org>
References: <20170426182419.14574-7-hannes@stressinduktion.org>
 <590112BE.7040902@iogearbox.net>
 <5b1f23e3-86a7-69aa-91e2-1dc72125f22b@stressinduktion.org>
 <20170427.120019.1559603500876505216.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org, ast@kernel.org,
        daniel@iogearbox.com, jbenc@redhat.com, aconole@bytheb.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:58477 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933243AbdD0Q2U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 12:28:20 -0400
In-Reply-To: <20170427.120019.1559603500876505216.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27.04.2017 18:00, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Thu, 27 Apr 2017 15:22:49 +0200
> 
>> Sure, that sounds super. But so far Linux and most (maybe I should write
>> all) subsystems always provided some easy way to get the insights of the
>> kernel without having to code or rely on special tools so far.
> 
> Not true.

Yes, I should not have written it that generally. ;)

> You cannot fully dump socket TCP internal state without netlink based
> tools.  It is just one of many examples.
>
> Can you dump all nftables rules without a special tool?

You got me here, I agree that not all state is discoverable via procfs.
But to some degree even netfilter and tcp do expose some considerable
amount of data via procfs. In the case of netfilter it might be less
valuable, though, I have to agree.

> I don't think this is a legitimate line of argument, and I want
> this to be done via the bpf() system call which is what people
> are working on.

I hope you saw that I was absolutely not against dumping or enumeration
with the bpf syscall. It will be the primary interface to debug ebpf and
I completely agree.

Merely I tried to establish the procfs interface as quick look interface
if some type of bpf program is loaded which could start any further
diagnosis. This interface should not have any dependencies and should
even work on embedded devices, where sometimes it might be difficult to
get a binary for the correct architecture installed ad-hoc (I am
thinking about openwrt). But this is definitely also solvable.

I do think if a common utility in util-linux, like lsbpf, is available I
will be fine.

Anyway, I will take this argument back.

Thanks,
Hannes
