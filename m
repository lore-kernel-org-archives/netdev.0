From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 98521] New: bonding: kernel BUG at net/core/dev.c:2359
 when using traceroute6
Date: Mon, 18 May 2015 10:20:09 -0700
Message-ID: <20150518102009.18b9c332@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36336 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752579AbbERRUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 13:20:06 -0400
Received: by pabts4 with SMTP id ts4so160146393pab.3
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 10:20:06 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id y2sm10625306pdk.67.2015.05.18.10.20.05
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 10:20:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 17 May 2015 23:16:25 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 98521] New: bonding: kernel BUG at net/core/dev.c:2359 when using traceroute6


https://bugzilla.kernel.org/show_bug.cgi?id=98521

            Bug ID: 98521
           Summary: bonding: kernel BUG at net/core/dev.c:2359 when using
                    traceroute6
           Product: Networking
           Version: 2.5
    Kernel Version: 4.0.3
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: catdog2@tuxzone.org
        Regression: No

Created attachment 177171
  --> https://bugzilla.kernel.org/attachment.cgi?id=177171&action=edit
Snapshot of the panic message

When i do a "traceroute6 google.com" the kernel panics with "kernel BUG at
net/core/dev.c:2359". It only seems to happen when using a bonding interface
(ethernet + wlan in active-backup mode in my case). 
A snapshot of the message printed to the console is attached.

-- 
You are receiving this mail because:
You are the assignee for the bug.
