From: Rick Jones <rick.jones2@hp.com>
Subject: NIC interrupt assignments under UltraSPARC-T1
Date: Wed, 13 Sep 2006 17:47:27 -0700
Message-ID: <4508A69F.8060102@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:22169 "EHLO palrel11.hp.com")
	by vger.kernel.org with ESMTP id S1751283AbWINArb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 20:47:31 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel11.hp.com (Postfix) with ESMTP id 2063535825
	for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 17:47:28 -0700 (PDT)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id RAA26509
	for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 17:47:27 -0700 (PDT)
To: Linux Network Development list <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 From time to time I "play" with netperf on different systems.  I happen 
to have occasion to play with a T2000.  Under Solaris 10 I am able to 
coerce the interrupts of the different core GbEs to be on different 
cores rather than strands of the same core.

Under a 2.6.15 kernel (Ubuntu Dapper) it would appear that the old 
standby of "echo affinity mask to the IRQ" doesn't "work" - no matter 
how I change the mask for a NIC, running a netperf TCP_RR test seems to 
show the interrupts happening on the same strand.

Is it indeed not possible to alter the interrupt assignments or have I 
(as I'm wont to do) missed something quasi-obvious?

thanks,

rick jones
