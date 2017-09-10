From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 196889] New: kernel panic net_rx_action+0x21e/0x22d
Date: Sun, 10 Sep 2017 10:32:05 -0700
Message-ID: <20170910103205.2f8c8819@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:35761 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751483AbdIJRcN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2017 13:32:13 -0400
Received: by mail-pg0-f54.google.com with SMTP id 188so11738328pgb.2
        for <netdev@vger.kernel.org>; Sun, 10 Sep 2017 10:32:13 -0700 (PDT)
Received: from xeon-e3 (76-14-207-240.or.wavecable.com. [76.14.207.240])
        by smtp.gmail.com with ESMTPSA id u73sm3073422pfi.58.2017.09.10.10.32.12
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 10 Sep 2017 10:32:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 10 Sep 2017 12:21:13 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 196889] New: kernel panic net_rx_action+0x21e/0x22d


https://bugzilla.kernel.org/show_bug.cgi?id=196889

            Bug ID: 196889
           Summary: kernel panic net_rx_action+0x21e/0x22d
           Product: Networking
           Version: 2.5
    Kernel Version: 4.13.0+
          Hardware: Intel
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: pstaszewski@itcare.pl
        Regression: No

Created attachment 258289
  --> https://bugzilla.kernel.org/attachment.cgi?id=258289&action=edit  
kernel panic screenshoot

Hardware:
Intel E5-2670
Network controllers
2x 10G Intel 82599
1x 100G Mellanox Connectx-5

Test scenario:
Packet generator -> (RX traffix on Mellanox 100G / 12Mpps UDP random
destination ip / random port )Tested HOST (TX traffix from Intel 82599 on 20
vlans attached to ethernet) -> Sink



Kernal panic occured after 5 minutes from start to send traffic by packet
generator.

-- 
You are receiving this mail because:
You are the assignee for the bug.
