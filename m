From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 67841] New: IPX socket shutdown() is not implemented
Date: Fri, 27 Dec 2013 23:58:43 -0800
Message-ID: <20131227235843.0a3ff2f8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:50299 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980Ab3L1H6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 02:58:47 -0500
Received: by mail-pd0-f178.google.com with SMTP id y10so9765549pdj.9
        for <netdev@vger.kernel.org>; Fri, 27 Dec 2013 23:58:47 -0800 (PST)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id z10sm87726258pas.6.2013.12.27.23.58.46
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 27 Dec 2013 23:58:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 27 Dec 2013 19:38:42 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 67841] New: IPX socket shutdown() is not implemented


https://bugzilla.kernel.org/show_bug.cgi?id=67841

            Bug ID: 67841
           Summary: IPX socket shutdown() is not implemented
           Product: Networking
           Version: 2.5
    Kernel Version: 3.12.6
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: 00cpxxx@gmail.com
        Regression: No

With no support to shutdown a parallel (other thread) poll call is not waken up
so applications hang indefinitely while waiting for an answer.

Still in the latest development version as seen in:
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/net/ipx/af_ipx.c?id=refs/tags/v3.13-rc5#n1966

The problem was found while debugging a windows game through wine, the game is
Dune 2000 and the sister bug is http://bugs.winehq.org/show_bug.cgi?id=6941

-- 
You are receiving this mail because:
You are the assignee for the bug.
