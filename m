From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Simple question about network stack
Date: Mon, 24 Dec 2007 12:52:38 +0300
Message-ID: <476F8166.4070801@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:33975 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589AbXLXKBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 05:01:23 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 30469A6C722
	for <netdev@vger.kernel.org>; Mon, 24 Dec 2007 12:52:45 +0300 (MSK)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id PbfVncOTzSTJ for <netdev@vger.kernel.org>;
	Mon, 24 Dec 2007 12:52:39 +0300 (MSK)
Received: from [87.255.0.131] (slavon.bigtelecom.ru [87.255.0.131])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 3B845A6C538
	for <netdev@vger.kernel.org>; Mon, 24 Dec 2007 12:52:39 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all.
Sorry for offtopic.
Have problems with balance CPU load in networking.

Have 2 Ethernet adapters e1000. Have 8 CPU (4 real).
Computer work as Shaper. Use only TC rules to shape and IPTABLES to drop.

rx on eth0 go to CPU0. traffic above 400mbs do 90% SI.
rx on eth1 go to CPU1. traffic above 400mbs do 90% SI.
All other CPUS 100%idle.

question:
1. I may balance load to other cpu? I understand that i can't balance
polling place, but find in TC and IPTABLES hash may do different cpu?
2. If SI on 1 cpu more then 100% (600mbs traffic) i see strange. SOFTIRQ
process do 100%. Traffic bandwidth go from 400mbs to 100 mbs. pings
trough computer go from 0.5ms to 100ms. 1 cpu use 100%. All other cpu
100%idle.  If traffic down - after some time cpu load again go to
different cpu.

P.S. Very strange that computer with 4(8) CPU and 1 CPU HT do some
network performance.
P.P.S Sorry for my English

Thanks for answers.
Slavon
