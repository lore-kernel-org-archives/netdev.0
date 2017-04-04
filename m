From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 195169] New: ip_route_input_noref panic
Date: Tue, 4 Apr 2017 13:20:15 -0700
Message-ID: <20170404132015.0d52ee61@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36289 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753288AbdDDUU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 16:20:27 -0400
Received: by mail-pg0-f50.google.com with SMTP id g2so160624928pge.3
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 13:20:27 -0700 (PDT)
Received: from xeon-e3 (204-195-18-65.wavecable.com. [204.195.18.65])
        by smtp.gmail.com with ESMTPSA id d1sm33342752pfa.5.2017.04.04.13.20.25
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Apr 2017 13:20:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 31 Mar 2017 02:54:55 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 195169] New: ip_route_input_noref panic


https://bugzilla.kernel.org/show_bug.cgi?id=195169

            Bug ID: 195169
           Summary: ip_route_input_noref panic
           Product: Networking
           Version: 2.5
    Kernel Version: 3.10.103
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: stephen@networkplumber.org
          Reporter: panweiping3@163.com
        Regression: No

Created attachment 255655
  --> https://bugzilla.kernel.org/attachment.cgi?id=255655&action=edit  
ip_route_input_noref

We hit a kernel panic on kernel 3.10.103.

Since we do not configure kdump, I can only take a picture after it hangs.

-- 
You are receiving this mail because:
You are the assignee for the bug.
