From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 195969] New: ipsec icmp and udp works, tcp doesn't work
Date: Tue, 6 Jun 2017 12:14:39 -0700
Message-ID: <20170606121439.6d24d7f0@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:35255 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751888AbdFFTOw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 15:14:52 -0400
Received: by mail-pg0-f51.google.com with SMTP id k71so4964953pgd.2
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 12:14:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sat, 03 Jun 2017 06:25:05 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 195969] New: ipsec icmp and udp works, tcp doesn't work


https://bugzilla.kernel.org/show_bug.cgi?id=195969

            Bug ID: 195969
           Summary: ipsec icmp and udp works, tcp doesn't work
           Product: Networking
           Version: 2.5
    Kernel Version: 4.11.3-1-ARCH
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: dev@djagoo.io
        Regression: No

A few days ago I updated to 4.11.3-1-ARCH. After that my VPN access to our
corporate network was broken.

The connection is established and I can use UDP (i.e. DNS) and ICMP. All TCP
connections I tried (ssh, smb, http...) failed.

On the AUR page "MartinDiehl commented on 2017-05-25 19:57" the same error. 

https://aur.archlinux.org/packages/strongswan/

And I found a bug report on redhat bugzilla:

https://bugzilla.redhat.com/show_bug.cgi?id=1458222

-- 
You are receiving this mail because:
You are the assignee for the bug.
