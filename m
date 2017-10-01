From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 197099] New: Kernel panic in interrupt [l2tp_ppp]
Date: Sun, 1 Oct 2017 10:21:10 -0700
Message-ID: <20171001102110.24184f1b@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:50463 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751093AbdJARVS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 13:21:18 -0400
Received: by mail-pg0-f54.google.com with SMTP id p5so1923409pgn.7
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 10:21:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 01 Oct 2017 16:22:33 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 197099] New: Kernel panic in interrupt [l2tp_ppp]


https://bugzilla.kernel.org/show_bug.cgi?id=197099

            Bug ID: 197099
           Summary: Kernel panic in interrupt [l2tp_ppp]
           Product: Networking
           Version: 2.5
    Kernel Version: 4.8.13-1.el6.elrepo.x86_64
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: svimik@gmail.com
        Regression: No

Created attachment 258685
  --> https://bugzilla.kernel.org/attachment.cgi?id=258685&action=edit  
stacktrace screenshot

Hello!

Getting kernel panics on multiple servers. Since it mentions l2tp_core,
l2tp_ppp and ppp_generic, I decided to report it to Networking (correct me if
I'm wrong).

Unfortunately I'm still struggling with making kdump work, so the trace
screenshot is all I have at this moment. The only hope is that this stacktrace
means something to the guys that wrote the code.

-- 
You are receiving this mail because:
You are the assignee for the bug.
