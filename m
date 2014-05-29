From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 77081] New: sock_tx_timestamp for SOCK_RAW
Date: Thu, 29 May 2014 09:00:28 -0700
Message-ID: <20140529090028.73cde5d2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:58805 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756871AbaE2QAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 12:00:35 -0400
Received: by mail-pa0-f53.google.com with SMTP id kp14so576918pab.26
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 09:00:34 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id fe2sm1877088pbc.68.2014.05.29.09.00.33
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 29 May 2014 09:00:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 29 May 2014 02:00:26 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 77081] New: sock_tx_timestamp for SOCK_RAW


https://bugzilla.kernel.org/show_bug.cgi?id=77081

            Bug ID: 77081
           Summary: sock_tx_timestamp for SOCK_RAW
           Product: Networking
           Version: 2.5
    Kernel Version: 3.14
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: enhancement
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: yangzhe1990@gmail.com
        Regression: No

I just wonder if we could enable the support for AF_INET / AF_INET6, SOCK_RAW
sockets. We already have that for UDP packets.

We only need to add a line of sock_tx_timestamp(sk, &ipc.tx_flags) after
net/ipv4/raw.c:525, and change net/ipv6/ip6_output.c:1257 to     if
(sk->sk_type == SOCK_DGRAM || sk->sk_type == SOCK_RAW).

-- 
You are receiving this mail because:
You are the assignee for the bug.
