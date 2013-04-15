From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 56631] New: niu Sun Neptune 10G fiber card - "transmit
 timed out"
Date: Mon, 15 Apr 2013 08:03:42 -0700
Message-ID: <20130415080342.1d028f8d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f47.google.com ([209.85.210.47]:38864 "EHLO
	mail-da0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983Ab3DOPEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 11:04:09 -0400
Received: by mail-da0-f47.google.com with SMTP id s35so2117278dak.20
        for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 08:04:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 15 Apr 2013 06:25:44 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 56631] New: niu Sun Neptune 10G fiber card - "transmit timed out"


https://bugzilla.kernel.org/show_bug.cgi?id=56631

           Summary: niu Sun Neptune 10G fiber card - "transmit timed out"
           Product: Networking
           Version: 2.5
    Kernel Version: 3.9.0
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: blocking
          Priority: P1
         Component: Other
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: arb@sat.dundee.ac.uk
        Regression: Yes


[Ref. bug 10801 still not solved]

The system will hang with the message
"niu: xxx: eth2: Transmit timed out, resetting"
It will then remain hung with messages output every 5 seconds.

This has also been observed (but not every time):
WARNING: at sch_generic:255 dev_watchdog
NETDEV WATCHDOG: eth2 (niu): transmit queue xx timed out

Has been seen to occur in kernels 3.2, 3.5 and 3.9.
Hardware: "Sun Fire X2250" with "Oracle/SUN Multithreaded 10-Gigabit Ethernet
Network Controller (rev 01)"
Software: Ubuntu Precise 12.04.2 running as a NFS client

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
