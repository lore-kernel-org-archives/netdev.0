From: Sharat Masetty <sharat04@gmail.com>
Subject: RPS vs RFS
Date: Thu, 3 Apr 2014 13:14:04 -0600
Message-ID: <CAJzFV36pTwUyfoW=Jz1tBKSYbZTLvokOLST+XoX593YP6oN7Pw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: sharat chandra <sharat04@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:35090 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753321AbaDCTOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 15:14:06 -0400
Received: by mail-we0-f172.google.com with SMTP id t61so2384633wes.3
        for <netdev@vger.kernel.org>; Thu, 03 Apr 2014 12:14:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am trying to understand the true benefit of RFS over RPS. In the
kernel documentation scaling.txt, the author talks about data cache
hitrate, can someone explain what this actually means? In which
scenarios would RFS be beneficial? Why would it help to have network
stack run on the same core on which the application for a stream/flow
is running?


Consider a NIC with a single receive queue, single interrupt line, and
iperf application is pulling data off this NIC card. In case where
iperf may still be running on the same core on which the interrupts
are delivered, then in that case the whole stack is pinned to the same
core, and would not be benefiting a lot from this scheme




References:
https://www.kernel.org/doc/Documentation/networking/scaling.txt

https://lwn.net/Articles/382428/

Regards,
Sharat
