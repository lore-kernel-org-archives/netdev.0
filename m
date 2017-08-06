From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 196595] New: Regression IGMP sysctl init values if not
 IP_MULTICAST
Date: Sat, 5 Aug 2017 21:38:46 -0700
Message-ID: <20170805213846.0df6ef45@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35279 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751270AbdHFEiu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 00:38:50 -0400
Received: by mail-pf0-f172.google.com with SMTP id t86so21889576pfe.2
        for <netdev@vger.kernel.org>; Sat, 05 Aug 2017 21:38:50 -0700 (PDT)
Received: from xeon-e3 (76-14-207-240.or.wavecable.com. [76.14.207.240])
        by smtp.gmail.com with ESMTPSA id c12sm8915331pfe.154.2017.08.05.21.38.49
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 05 Aug 2017 21:38:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sat, 05 Aug 2017 23:57:48 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 196595] New: Regression IGMP sysctl init values if not IP_MULTICAST


https://bugzilla.kernel.org/show_bug.cgi?id=196595

            Bug ID: 196595
           Summary: Regression IGMP sysctl init values if not IP_MULTICAST
           Product: Networking
           Version: 2.5
    Kernel Version: 4.5 - 4.12
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: stephen@networkplumber.org
          Reporter: vmlinuz386@gmail.com
        Regression: No

I just upgraded from 4.4.x to 4.12.x and detected that igmp related settings
are not set to default values (1, 20, 10):

net.ipv4.igmp_link_local_mcast_reports = 0
net.ipv4.igmp_max_memberships = 0
net.ipv4.igmp_max_msf = 0

This is fixed if I enable IP_MULTICAST. Looks like a regression since some
changes made to "Namespaceify" commit dcd87999d415d39cf2ae510bfed6b8206d778e1c 
and related commits.

-- 
You are receiving this mail because:
You are the assignee for the bug.
