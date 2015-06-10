From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 99711] New: AX25 ROSE module fails to unload
Date: Tue, 9 Jun 2015 17:04:13 -0700
Message-ID: <20150609170413.1b99f6fa@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:32904 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754067AbbFJAEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 20:04:10 -0400
Received: by qcnj1 with SMTP id j1so11926752qcn.0
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 17:04:10 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id 79sm3411199qkz.30.2015.06.09.17.04.09
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 17:04:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 9 Jun 2015 11:58:56 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 99711] New: AX25 ROSE module fails to unload


https://bugzilla.kernel.org/show_bug.cgi?id=99711

            Bug ID: 99711
           Summary: AX25 ROSE module fails to unload
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6,3.x,4.x
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: richard@rns-stearn.demon.co.uk
        Regression: No

Created attachment 179241
  --> https://bugzilla.kernel.org/attachment.cgi?id=179241&action=edit
Adding usage count and socket locking to ROSE module.

The ROSE kernel module fails to unload as the usage count is non-zero.

To reproduce:
  Requires AX25 and ROSE modules to be built
  AX25 library, tools and applications to be installed
  Configure a ROSE interface
  Send at least one packet over the interface
  Tear down the ROSE link
  The ROSE module will fail to unload with a random number in the device usage
count.
  Requires a reboot to remove the module.

-- 
You are receiving this mail because:
You are the assignee for the bug.
