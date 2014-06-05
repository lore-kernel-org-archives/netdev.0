From: "Arankal, Nagaraj P" <nagaraj.p.arankal@hp.com>
Subject: bnx2x: [bnx2x_release_hw_lock:2226(eth3)]lock_status 0x0
 resource_bit 0x1. Unlock was called but lock wasn't taken!
Date: Thu, 5 Jun 2014 10:14:52 +0000
Message-ID: <1C24E2A22F3B0C4CAC3C670E0EF37E72063072C6@G6W2489.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t1626.atlanta.hp.com ([15.192.137.9]:36555 "EHLO
	g5t1626.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbaFEKQO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 06:16:14 -0400
Received: from G6W4001.americas.hpqcorp.net (g6w4001.atlanta.hp.com [16.205.80.210])
	(using TLSv1 with cipher AES128-SHA (128/128 bits))
	(No client certificate requested)
	by g5t1626.atlanta.hp.com (Postfix) with ESMTPS id 8038F287
	for <netdev@vger.kernel.org>; Thu,  5 Jun 2014 10:16:13 +0000 (UTC)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
While executing some functional tests on one of my Server containing bnx2x card, I have observed following messages in /var/log/kern.log


root@dl380g8-2x:/var/log# cat /var/log/kern.log
May 14 06:56:55 dl380g8-2x kernel: [59572.519249] bnx2x: [bnx2x_acquire_hw_lock:2192(eth3)]Timeout
May 14 06:56:55 dl380g8-2x kernel: [59572.519260] bnx2x: [bnx2x_release_hw_lock:2226(eth3)]lock_status 0x0 resource_bit 0x1. Unlock was called but lock wasn't taken!
May 14 07:21:11 dl380g8-2x kernel: [61028.418935] bnx2x: [bnx2x_acquire_hw_lock:2192(eth3)]Timeout
May 14 07:21:11 dl380g8-2x kernel: [61028.418946] bnx2x: [bnx2x_release_hw_lock:2226(eth3)]lock_status 0x0 resource_bit 0x1. Unlock was called but lock wasn't taken!
May 14 08:42:32 dl380g8-2x kernel: [65906.724350] bnx2x: [bnx2x_acquire_hw_lock:2192(eth3)]Timeout
May 14 08:42:32 dl380g8-2x kernel: [65906.724361] bnx2x: [bnx2x_release_hw_lock:2226(eth3)]lock_status 0x0 resource_bit 0x1. Unlock was called but lock wasn't taken!
May 14 09:37:16 dl380g8-2x kernel: [69188.417427] bnx2x: [bnx2x_acquire_hw_lock:2192(eth3)]Timeout
May 14 09:37:16 dl380g8-2x kernel: [69188.417438] bnx2x: [bnx2x_release_hw_lock:2226(eth3)]lock_status 0x0 resource_bit 0x1. Unlock was called but lock wasn't taken!
May 14 09:55:19 dl380g8-2x kernel: [70270.645449] bnx2x: [bnx2x_acquire_hw_lock:2192(eth3)]Timeout
May 14 09:55:19 dl380g8-2x kernel: [70270.645460] bnx2x: [bnx2x_release_hw_lock:2226(eth3)]lock_status 0x0 resource_bit 0x1. Unlock was called but lock wasn't taken!
May 14 12:41:23 dl380g8-2x kernel: [80229.646043] bnx2x: [bnx2x_acquire_hw_lock:2192(eth3)]Timeout
May 14 12:41:23 dl380g8-2x kernel: [80229.646055] bnx2x: [bnx2x_release_hw_lock:2226(eth3)]lock_status 0x0 resource_bit 0x1. Unlock was called but lock wasn't taken!
May 14 14:45:01 dl380g8-2x kernel: [87643.062018] bnx2x: [bnx2x_acquire_hw_lock:2192(eth3)]Timeout
May 14 14:45:01 dl380g8-2x kernel: [87643.062029] bnx2x: [bnx2x_release_hw_lock:2226(eth3)]lock_status 0x0 resource_bit 0x1. Unlock was called but lock wasn't taken!
May 14 15:12:15 dl380g8-2x kernel: [89276.234304] bnx2x: [bnx2x_acquire_hw_lock:2192(eth3)]Timeout
May 14 15:12:15 dl380g8-2x kernel: [89276.234315] bnx2x: [bnx2x_release_hw_lock:2226(eth3)]lock_status 0x0 resource_bit 0x1. Unlock was called but lock wasn't taken!
root@dl380g8-2x:/var/log# 


Any idea why?

Kernel version : 3.6.26
Bnx2x driver version : 1.78.80

Thanks,
Nagaraj
