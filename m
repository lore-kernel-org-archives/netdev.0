From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 43277] New: net/e1000e set mtu larger than 1500 fails
Date: Tue, 22 May 2012 11:19:50 -0700
Message-ID: <20120522111950.4548747c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sf.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42061 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759437Ab2EVST4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2012 14:19:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 22 May 2012 18:13:21 +0000 (UTC)
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 43277] New: net/e1000e set mtu larger than 1500 fails


https://bugzilla.kernel.org/show_bug.cgi?id=43277

           Summary: net/e1000e set mtu larger than 1500 fails
           Product: Networking
           Version: 2.5
    Kernel Version: 3.4
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: che@chrekh.se
        Regression: Yes


In kernel 3.4 I can no longer use jumbo-frames with my e1000e network
interface.

 $ sudo ip link set eth1 mtu 9000
 RTNETLINK answers: Invalid argument

Card-info (from kernel-log)

 e1000e 0000:05:00.1: eth1: (PCI Express:2.5GT/s:Width x4) 00:1b:78:59:84:25
 e1000e 0000:05:00.1: eth1: Intel(R) PRO/1000 Network Connection
 e1000e 0000:05:00.1: eth1: MAC: 0, PHY: 4, PBA No: D51930-003

I have bisected and found:

 70495a500d787c0c90a136acf454cb7d0eecd82e is the first bad commit

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
