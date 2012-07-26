From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: r8169, 3.5.0, does't work at all
Date: Thu, 26 Jul 2012 23:44:25 +0300
Message-ID: <e9e38770b95bc3664fdc642fdfb65a13@visp.net.lb>
References: <88f2e8e7f795239ec4bc759dcda61665@visp.net.lb>
 <20120726195658.GA14668@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:35356 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314Ab2GZUo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 16:44:27 -0400
In-Reply-To: <20120726195658.GA14668@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-07-26 22:56, Francois Romieu wrote:
> Denys Fedoryshchenko <denys@visp.net.lb> :
>> Just pushed new kernel to test cluster and got this:
> [...]
>> [    1.606212] r8169 0000:03:00.0: eth1: RTL8168b/8111b at
>> 0xf8606000, 00:08:54:57:7a:33, XID 18000000 IRQ 44
>> [    1.606366] r8169 0000:03:00.0: eth1: jumbo features [frames:
>> 4080 bytes, tx checksumming: ko]
>> ....
>> [   20.406090]     input device check on
>> [   20.406177]     Actions configured
>> [   21.526836] r8169 0000:02:00.0: eth0: link up
>> [   28.038386] ------------[ cut here ]------------
>> [   28.038438] WARNING: at net/sched/sch_generic.c:255
>> dev_watchdog+0xd6/0x12a()
>> [   28.038489] Hardware name:
>> [   28.038534] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed
>
> Right at startup.
>
> Which kernel did you previously use ?
>
> This is exactly the primary device I use to access my test computer.
>
> .config and .dmesg will be welcome as well.
http://www.nuclearcat.com/dmesg.txt
http://www.nuclearcat.com/config.txt

There ifplugd also running, and udhcpc, both from busybox.
Now machine are deployed to production , working fine with 3.4.6 
kernel. I can do limited tests on it,
and i can search for more machines with similar cards.

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
