From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 43671] New: 1282:9102 Davicom DM9102 issue
Date: Mon, 25 Jun 2012 08:15:15 -0700
Message-ID: <20120625081515.02a6b109@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48039 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750820Ab2FYPP1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2012 11:15:27 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 4A8621440004
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 08:15:26 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id QjOozNKgPv6H for <netdev@vger.kernel.org>;
	Mon, 25 Jun 2012 08:15:21 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	by mail.vyatta.com (Postfix) with ESMTPSA id 784201440005
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 08:15:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sat, 23 Jun 2012 05:16:31 +0000 (UTC)
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 43671] New: 1282:9102 Davicom DM9102 issue


https://bugzilla.kernel.org/show_bug.cgi?id=43671

           Summary: 1282:9102 Davicom DM9102 issue
           Product: Networking
           Version: 2.5
    Kernel Version: Linux version 3.5.0-999-generic (apw@gomeisa) (gcc
                    version 4.6.3 (Ubuntu/Linaro 4.6.3-1ubuntu5) )
                    #201206090407 SMP Sat Jun 9 08:14:58 UTC 2012
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: p.satishchandra@gmail.com
        Regression: No


Created an attachment (id=74001)
 --> (https://bugzilla.kernel.org/attachment.cgi?id=74001)
cpuinfo, dmesg, iomem, ioports, lspci, modules, scsi

Ethernet cards of Davicom DM9102 do not work. Many people suggest trying with
'dmfe' module rather than 'tulip' but neither works. The syslog is full of
'eth0: Tx timeout - resetting' messages. The bug is also reported in Launchpad
(url - https://bugs.launchpad.net/ubuntu/+source/linux/+bug/819868) but it was
suggested to report it to the mainline kernel.

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
