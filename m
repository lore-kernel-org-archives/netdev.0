From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 71781] New: Kernel panic - not syncing: Fatal exception in
 interrupt
Date: Mon, 10 Mar 2014 09:12:08 -0700
Message-ID: <20140310091208.65c31c75@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:38860 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277AbaCJQMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 12:12:13 -0400
Received: by mail-pd0-f178.google.com with SMTP id x10so7220864pdj.23
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 09:12:11 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id xn10sm9007706pab.0.2014.03.10.09.12.10
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 10 Mar 2014 09:12:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 10 Mar 2014 05:51:48 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 71781] New: Kernel panic - not syncing: Fatal exception in interrupt


https://bugzilla.kernel.org/show_bug.cgi?id=71781

            Bug ID: 71781
           Summary: Kernel panic - not syncing: Fatal exception in
                    interrupt
           Product: Networking
           Version: 2.5
    Kernel Version: 3.10.32
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: blocking
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: asilva@wirelessmundi.com
        Regression: No

Created attachment 128811
  --> https://bugzilla.kernel.org/attachment.cgi?id=128811&action=edit
full boot sequence log

The servers just panic on boot time:

[   18.647435] BUG: unable to handle kernel NULL pointer dereference at
0000000000000080
[   18.656468] IP: [<ffffffff810f4c8d>] ____cache_alloc+0x1f/0x290
[   18.663269] PGD 0 
[   18.665581] Oops: 0000 [#1] SMP 

.... (see attach log for the full message)

[   19.200202] ---[ end trace 85fce9ca9a98a944 ]---
[   19.207209] Kernel panic - not syncing: Fatal exception in interrupt
[   19.216142] Rebooting in 1 seconds..

-- 
You are receiving this mail because:
You are the assignee for the bug.
