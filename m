From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 99411] New: Kernel panic after internet access goes down
Date: Wed, 3 Jun 2015 12:17:41 -0700
Message-ID: <20150603121741.2d18f583@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:33918 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754139AbbFCTRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 15:17:41 -0400
Received: by qcej9 with SMTP id j9so8602783qce.1
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 12:17:40 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id o130sm915383qhb.25.2015.06.03.12.17.39
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 12:17:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 3 Jun 2015 14:31:53 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 99411] New: Kernel panic after internet access goes down


https://bugzilla.kernel.org/show_bug.cgi?id=99411

            Bug ID: 99411
           Summary: Kernel panic after internet access goes down
           Product: Networking
           Version: 2.5
    Kernel Version: 4.0.4-2
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: blocking
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: mbarrera@gmx.com
        Regression: No

Created attachment 178711
  --> https://bugzilla.kernel.org/attachment.cgi?id=178711&action=edit
Full log for the kernel panic

Sometimes during the night the internet connection is reset by the ISP, after
some seconds Linux panics with the following:

BUG: unable to handle kernel paging request at ffffffffffffffd8
IP: [<ffffffff81093920>] kthread_data+0x10/0x20

-- 
You are receiving this mail because:
You are the assignee for the bug.
