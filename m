From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 195217] New: irda doesn't work
Date: Sat, 1 Apr 2017 16:42:51 -0700
Message-ID: <20170401164251.0c69b16d@plumbers-lap.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:34546 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751737AbdDAXm6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 19:42:58 -0400
Received: by mail-pg0-f43.google.com with SMTP id 21so93781924pgg.1
        for <netdev@vger.kernel.org>; Sat, 01 Apr 2017 16:42:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sat, 01 Apr 2017 22:02:08 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 195217] New: irda doesn't work


https://bugzilla.kernel.org/show_bug.cgi?id=195217

            Bug ID: 195217
           Summary: irda doesn't work
           Product: Networking
           Version: 2.5
    Kernel Version: 4.9.X, 4.10.X, 4.11-rcX
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: jb_69100@yahoo.com
        Regression: No

keyword : irda, MCS7780, networking, SIOCSIFFLAGS


Unable to run irda0 with kernel greater than 4.8.17
"ifconfig irda0 up" works with kernel 4.8.17 but fails with kernel 4.9.X,
4.10.X and 4.11-rcX. (SIOCSIFFLAGS: Ressource temporairement non disponible)


________________________________________________
Debian Release: 9.0
Architecture: amd64 (x86_64)
Kernel: Linux 4.10.8---2017-03-31.15h31mn (SMP w/8 CPU cores)


root@myPC:/# lsusb | grep MCS7780                                               
Bus 006 Device 002: ID 9710:7780 MosChip Semiconductor MCS7780 4Mbps Fast IrDA
Adapter

root@myPC:/# ifconfig irda0
irda0: flags=128<NOARP>  mtu 2048
        irda 00:00:00:00  txqueuelen 8  (IrLAP)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

root@myPC:/# ifconfig irda0 up
SIOCSIFFLAGS: Ressource temporairement non disponible

-- 
You are receiving this mail because:
You are the assignee for the bug.
