From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 104161] New: DLNA services disappear on bridge device
 shortly after starting the dlna service
Date: Mon, 7 Sep 2015 11:01:43 -0700
Message-ID: <20150907110143.0480992f@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35629 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717AbbIGSBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 14:01:32 -0400
Received: by pacfv12 with SMTP id fv12so104313029pac.2
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2015 11:01:32 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by smtp.gmail.com with ESMTPSA id xs7sm529340pab.4.2015.09.07.11.01.31
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 11:01:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 7 Sep 2015 13:31:54 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 104161] New: DLNA services disappear on bridge device shortly after starting the dlna service


https://bugzilla.kernel.org/show_bug.cgi?id=104161

            Bug ID: 104161
           Summary: DLNA services disappear on bridge device shortly after
                    starting the dlna service
           Product: Networking
           Version: 2.5
    Kernel Version: 4.2
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: t.powa@gmx.de
        Regression: No

Hi,
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=9afd85c9e4552b276e2f4cfefd622bdeeffbbf26

This commit introduces a weird behaviour on my dlna server, commit was
bisected.

This commit was merged into 4.2 series, which makes my dlna/upnp services
disappear real soon after starting from discovering from other clients.
Localhost seems not to be affected but every external discovery is broken.
The dlna services run on a bridge device with IPV4. Mythtv and Minidlna both
disappear after some minutes of running.
4.2 with those 3 patches reverted makes it work as it should:
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=a516993f0ac1694673412eb2d16a091eafa77d2a
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=fcba67c94abe83e0e69a65737000ccbb16a4fa03
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=9afd85c9e4552b276e2f4cfefd622bdeeffbbf26

Do you need any more information to get this really weird bug fixed?

Thanks in advance.

-- 
You are receiving this mail because:
You are the assignee for the bug.
