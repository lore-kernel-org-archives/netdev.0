From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [bugzilla-daemon@bugzilla.kernel.org: [Bug 66111] New: after
 this message ipv4 bond0  working i no try ipv6 not have this time]
Date: Fri, 29 Nov 2013 13:37:49 +0100
Message-ID: <20131129123749.GA5781@redhat.com>
References: <20131129110828.GO4118@order.stressinduktion.org>
 <5298886D.8090400@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3512 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752767Ab3K2MkT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Nov 2013 07:40:19 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rATCeIIw031676
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 29 Nov 2013 07:40:19 -0500
Content-Disposition: inline
In-Reply-To: <5298886D.8090400@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 29, 2013 at 01:28:29PM +0100, Nikolay Aleksandrov wrote:
>On 11/29/2013 12:08 PM, Hannes Frederic Sowa wrote:
>> ----- Forwarded message from bugzilla-daemon@bugzilla.kernel.org -----
>>
>> From: bugzilla-daemon@bugzilla.kernel.org
>> To: hannes@stressinduktion.org
>> Date: Fri, 29 Nov 2013 10:24:12 +0000
>> Subject: [Bug 66111] New: after this message ipv4 bond0  working i no try
>>  ipv6 not have this time
>> Message-ID: <bug-66111-16487@https.bugzilla.kernel.org/>
>>
>> https://bugzilla.kernel.org/show_bug.cgi?id=66111
>>
>>             Bug ID: 66111
>>            Summary: after this message ipv4 bond0  working i no try ipv6
>>                     not have this time
>>            Product: Networking
>>            Version: 2.5
>>     Kernel Version: Linux 12terr 3.12.1 #1 SMP Thu Nov 28 20:32:48 EET
>>                     2013 x86_64 GNU/Linux
>>           Hardware: x86-64
>>                 OS: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: IPV6
>>           Assignee: yoshfuji@linux-ipv6.org
>>           Reporter: korvin2000@gmail.com
>>         Regression: No
>>
>> [    8.449805] bonding: bond0: enslaving eth2 as an active interface with an up
>> link.
>> [    8.633226] RTNL: assertion failed at drivers/net/bonding/bond_main.c (3398)
>> [    8.633303] CPU: 0 PID: 2007 Comm: rpcbind Tainted: G           O 3.12.1 #1
>> [    8.633306] Hardware name: System manufacturer System Product Name/F2A85-V,
>> BIOS 5023 10/29/2012
>> [    8.633309]  0000000000000000 0000000000000000 ffffffff81347bc5
>> ffff880429ed5000
>> [    8.633314]  ffffffffa0106ea2 ffff880429ed5000 0000000000000000
>> ffff880429ed5000
>> [    8.633318]  ffffffff81297d35 0000000000000001 ffff88042994bc80
>> ffff88042cd45e4c
>> [    8.633321] Call Trace:
>> [    8.633331]  [<ffffffff81347bc5>] ? dump_stack+0x41/0x51
>> [    8.633340]  [<ffffffffa0106ea2>] ? bond_set_rx_mode+0x2d/0xa7 [bonding]
>> [    8.633345]  [<ffffffff81297d35>] ? __dev_mc_add+0x48/0x59
>> [    8.633351]  [<ffffffff813208fa>] ? igmp6_group_added+0x79/0x1a6
>> [    8.633355]  [<ffffffff810f82a9>] ? kmem_cache_alloc_trace+0xbc/0xcb
>> [    8.633359]  [<ffffffff81321c7c>] ? ipv6_dev_mc_inc+0x20e/0x236
>> [    8.633363]  [<ffffffff81321dba>] ? ipv6_sock_mc_join+0x116/0x171
>> [    8.633369]  [<ffffffff813174a5>] ? do_ipv6_setsockopt.isra.6+0x8ee/0xc76
>> [    8.633373]  [<ffffffff8128fc9b>] ? dev_name_hash.isra.59+0x20/0x35
>> [    8.633377]  [<ffffffff8128fd9d>] ? dev_get_by_name_rcu+0x31/0x52
>> [    8.633383]  [<ffffffff8111e0c7>] ? __inode_wait_for_writeback+0x67/0xae
>> [    8.633388]  [<ffffffff8104ee54>] ? wake_atomic_t_function+0x21/0x21
>> [    8.633393]  [<ffffffff8112e6ed>] ? fsnotify_clear_marks_by_inode+0xa0/0x10e
>> [    8.633396]  [<ffffffff810f7c8e>] ? kmem_cache_free+0x32/0xbf
>> [    8.633401]  [<ffffffff8110fb08>] ? dentry_kill+0x13d/0x148
>> [    8.633405]  [<ffffffff8110fd83>] ? dput+0xe5/0xef
>> [    8.633410]  [<ffffffff81317940>] ? ipv6_setsockopt+0x4f/0x97
>> [    8.633415]  [<ffffffff8128210d>] ? SyS_setsockopt+0x80/0xab
>> [    8.633418]  [<ffffffff813510e2>] ? system_call_fastpath+0x16/0x1b
>> [    8.907232] RPC: Registered named UNIX socket transport module.
>> [    8.907237] RPC: Registered udp transport module.
>> [    8.907239] RPC: Registered tcp transport module.
>> [    8.907241] RPC: Registered tcp NFSv4.1 backchannel transport module.
>>
>Hm, I believe this should be fixed by commit
>b32418705107265dfca5edfe2b547643e53a732e ("bonding: RCUify bond_set_rx_mode()").
>$ git tag --contains b32418705107265dfca5edfe2b547643e53a732e
>v3.13-rc1

Yep, indeed, commented on that BZ already.

>
>Nik
