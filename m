From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 104301] New: Connect failure on sctp socket under debug
Date: Wed, 9 Sep 2015 07:47:59 -0700
Message-ID: <20150909074759.1e256966@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35603 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397AbbIIOrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 10:47:48 -0400
Received: by pacfv12 with SMTP id fv12so12603727pac.2
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 07:47:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 9 Sep 2015 13:57:38 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 104301] New: Connect failure on sctp socket under debug


https://bugzilla.kernel.org/show_bug.cgi?id=104301

            Bug ID: 104301
           Summary: Connect failure on sctp socket under debug
           Product: Networking
           Version: 2.5
    Kernel Version: 3.13.0-63-generic
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: riccardomanfrin@gmail.com
        Regression: No

When starting an sctp client with gdb, I experience a connect failure (-1 is
returned), with errno 106 (Transport endpoint is already connected).

If I then cat /proc/net/sctp/assocs, I see the connection and I see the
successful handshake on wireshark.

If I ignore the connect failure, and pretend I'm actually connected, I can send
and receive packets without any trouble.

The same client application, run not-under-gdb, does not exhibits the issue and
the connect returns 0.

-- 
You are receiving this mail because:
You are the assignee for the bug.
