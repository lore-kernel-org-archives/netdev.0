From: Rick Jones <rick.jones2@hp.com>
Subject: Re: a tap mystery
Date: Mon, 01 Jul 2013 16:33:44 -0700
Message-ID: <51D211D8.3000802@hp.com>
References: <51B66C74.2050801@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:46862 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755601Ab3GAXdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 19:33:46 -0400
Received: from g4t0018.houston.hp.com (g4t0018.houston.hp.com [16.234.32.27])
	by g4t0017.houston.hp.com (Postfix) with ESMTP id 63C93382F0
	for <netdev@vger.kernel.org>; Mon,  1 Jul 2013 23:33:45 +0000 (UTC)
Received: from [16.103.148.51] (tardy.usa.hp.com [16.103.148.51])
	by g4t0018.houston.hp.com (Postfix) with ESMTP id 349FF100E8
	for <netdev@vger.kernel.org>; Mon,  1 Jul 2013 23:33:45 +0000 (UTC)
In-Reply-To: <51B66C74.2050801@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/10/2013 05:16 PM, Rick Jones wrote:
> I have a small test script which runs a netperf TCP_RR test with an ever
> increasing number of tap devices on the system.  In this case the system
> is a venerable Centrino-based laptop on AC power at fixed frequency,
> with idle=poll for perf profiling purposes, the irqbalanced shot in the
> head and the IRQ of the Intel Corporation 82566MM pointed at CPU 0,
> whereon I have also bound the netperf process.  The other system is my
> personal workstation and the network connection between them is a
> private, back-to-back link.  The kernel on the laptop is a 3.5.0-30
> generic kernel.
>
> For the first 1024 tap devices created on the system, and put into the
> "UP" state, what netperf reports for CPU utilization and service demand
> is consistent with increasing per-packet costs which seems to be
> consistent with list_for_each_entry_rcu(ptype, &ptype_all, list) usage
> in dev_queue_xmit_nit and __netif_receive_skb.
>
>
> But somewhere between 1024 and 2048 tap devices some sort of miracle
> occurs and the CPU utilization and service demand drop.  Considerably.

And the same thing happens with an ~5 day old 3.10.0-rc6+ net-next kernel.

happy benchmarking,

rick jones
