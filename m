From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 57711] New: RTL-8110SC/8169SC driver hangs on 1G mode
Date: Tue, 7 May 2013 09:09:16 -0700
Message-ID: <20130507090916.7a756620@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?B?ZnJhbudvaXM=?= romieu <romieu@fr.zoreil.com>,
	hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:37567 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757929Ab3EGQJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 12:09:21 -0400
Received: by mail-pd0-f178.google.com with SMTP id w11so513072pde.23
        for <netdev@vger.kernel.org>; Tue, 07 May 2013 09:09:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 7 May 2013 00:32:28 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 57711] New: RTL-8110SC/8169SC driver hangs on 1G mode


https://bugzilla.kernel.org/show_bug.cgi?id=57711

           Summary: RTL-8110SC/8169SC driver hangs on 1G mode
           Product: Networking
           Version: 2.5
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: fojtik@penguin.cz
        Regression: No


The ethernet driver is rock stable on 10M/100M modes. 

1G mode causes ethernet device freezing. But everything else seems to continue
working. I am not alone who is facing this problem.

Here is another desperate guy:
http://forums.debian.net/viewtopic.php?f=7&t=62789

It looks like drop packet count starts to increase and the device is not able
to receive packet. All packets are dropped.
---------------------------------------------------------
eth2      Link encap:Ethernet  HWaddr 00:30:18:A9:F4:01  
          inet addr:10.23.202.49  Bcast:10.23.202.55  Mask:255.255.255.248
          inet6 addr: fe80::230:18ff:fea9:f401/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:15642592 errors:0 dropped:251658225 overruns:0 frame:0
          TX packets:18904013 errors:0 dropped:92 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:1555731278 (1483.6 Mb)  TX bytes:1855203093 (1769.2 Mb)
          Interrupt:19 Base address:0xc800 
---------------------------------------------------------

It seems to be different kind of bug than this one:
https://bugzilla.kernel.org/show_bug.cgi?id=16276

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
