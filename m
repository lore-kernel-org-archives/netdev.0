From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 196529] New: NULL pointer deref in networking
Date: Sat, 29 Jul 2017 14:33:20 -0700
Message-ID: <20170729143320.347eb4d1@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:36079 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751612AbdG2VdX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 17:33:23 -0400
Received: by mail-pg0-f42.google.com with SMTP id 125so123902936pgi.3
        for <netdev@vger.kernel.org>; Sat, 29 Jul 2017 14:33:23 -0700 (PDT)
Received: from xeon-e3 (76-14-207-240.or.wavecable.com. [76.14.207.240])
        by smtp.gmail.com with ESMTPSA id q24sm53218120pfg.167.2017.07.29.14.33.22
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 29 Jul 2017 14:33:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sat, 29 Jul 2017 01:52:42 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 196529] New: NULL pointer deref in networking


https://bugzilla.kernel.org/show_bug.cgi?id=196529

            Bug ID: 196529
           Summary: NULL pointer deref in networking
           Product: Networking
           Version: 2.5
    Kernel Version: 4.13rc2
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: rcepeda1993@gmail.com
        Regression: No

Created attachment 257749
  --> https://bugzilla.kernel.org/attachment.cgi?id=257749&action=edit  
dmesg output

Just upgraded to 4.13rc2, rebooted, and my system crashed at my netmount init
script; says RIP is NULL, I am guessing a bad func call. I immediately thought
missing firmware in kernel, my kernel builds firmware in it, so I upgraded my
firmware to latest on git.kernel and made sure I had no warnings in dmesg about
missing firmware. Still, I receive this NULL pointer in the IP. If I disable my
netmount on boot, I can login, but can not bring up my interfaces, still get a
RIP err in kernel logs and cpu load sky-rockets.

I am willing to help and provide as much info as possible, thank you.

-- 
You are receiving this mail because:
You are the assignee for the bug.
