From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 92121] New: acpid cannot connect to netlink socket
 (bisected)
Date: Tue, 27 Jan 2015 12:00:52 +0000
Message-ID: <20150127120052.2d3f2a20@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:48792 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754139AbbA0MBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 07:01:01 -0500
Received: by mail-pa0-f52.google.com with SMTP id kx10so18116589pab.11
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 04:01:00 -0800 (PST)
Received: from uryu.home.lan ([144.49.132.22])
        by mx.google.com with ESMTPSA id g6sm1392502pdo.76.2015.01.27.04.00.58
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jan 2015 04:01:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 26 Jan 2015 14:15:55 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 92121] New: acpid cannot connect to netlink socket (bisected)


https://bugzilla.kernel.org/show_bug.cgi?id=92121

            Bug ID: 92121
           Summary: acpid cannot connect to netlink socket (bisected)
           Product: Networking
           Version: 2.5
    Kernel Version: 3.19.0-rc6
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: ziegler@uni-freiburg.de
        Regression: Yes

acpid ouputs the following:

  Cannot bind netlink socket: No such file or directory
  acpid: cannot open generic netlink socket
  acpid: starting up with netlink and the input layer

The commit responsible for that is

  5ad6300524c0332ac67e912c20d6e5cf262ba58f

  genetlink: disallow subscribing to unknown mcast group

Reverting lets the bug vanish

-- 
You are receiving this mail because:
You are the assignee for the bug.
