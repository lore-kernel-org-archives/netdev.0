From: Patrick McHardy <kaber@trash.net>
Subject: Re: re-formated /Re: Hi!Couldn't you take a look at kernel stack's
 trace? (ip_route_input+0x91a/0xcc9)/
Date: Thu, 12 Jun 2008 14:07:06 +0200
Message-ID: <4851116A.6040805@trash.net>
References: <43d009740806100736y343bad9bt3a8b365292cced49@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: for.poige+linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37982 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753698AbYFLMHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 08:07:09 -0400
In-Reply-To: <43d009740806100736y343bad9bt3a8b365292cced49@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Igor Podlesny wrote:
>  Pid: 8, comm: sirq-net-rx/0 Not tainted (2.6.25.4-rt4aa-gcc43 #1)
>  EIP: 0060:[<c0313d75>] EFLAGS: 00010202 CPU: 0
>  EIP is at ip_route_input+0x91a/0xcc9
>  EAX: 00000000 EBX: f5a69e00 ECX: f7477e14 EDX: 00000001
>  ESI: 0f6ea8c0 EDI: f7477ea4 EBP: ffffff8f ESP: f7477e38
>   DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068 preempt:00000001
>  Process sirq-net-rx/0 (pid: 8, ti=f7476000 task=f746c690 task.ti=f7476000)
>  Stack: 00000000 016ea8c0 f6e2f180 00000001 c04f1964 00000001 f5a69e00 016ea8c0
>         00000000 00000000 c04851cc f786d640 00000000 00000006 00000000 016ea8c0
>         0f6ea8c0 00000000 00000000 00000000 00000000 00000000 00000000 00000000
>  Call Trace:
>   [<c024d578>] __next_cpu+0x12/0x21
>   [<c0333ee8>] arp_process+0x1fe/0x5fe
>   [<c01277f5>] wake_up_process+0xe/0x10
>   [<c0172e80>] __kmalloc+0x97/0xcb
>   [<c02f16be>] __alloc_skb+0x45/0xf2
>   [<c02f58da>] netif_receive_skb+0x2dd/0x30b
>   [<c02f5975>] process_backlog+0x6d/0xc1
>   [<c02f46a3>] net_rx_action+0x65/0x14c
>   [<c01304dd>] ksoftirqd+0x138/0x214
>   [<c01303a5>] ksoftirqd+0x0/0x214
>   [<c013c30e>] kthread+0x38/0x5d
>   [<c013c2d6>] kthread+0x0/0x5d
>   [<c0113f3f>] kernel_thread_helper+0x7/0x10

Whats sirq-net-rx? Doesn't seem to be present in the mainline tree.
