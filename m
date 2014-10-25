From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 86851] New: Reproducible panic on heavy UDP traffic
Date: Sat, 25 Oct 2014 14:10:38 +0530
Message-ID: <20141025141038.26fa5ac2@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:39806 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679AbaJYTtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2014 15:49:10 -0400
Received: by mail-lb0-f176.google.com with SMTP id p9so3951677lbv.7
        for <netdev@vger.kernel.org>; Sat, 25 Oct 2014 12:49:08 -0700 (PDT)
Received: from uryu.home.lan ([88.128.80.74])
        by mx.google.com with ESMTPSA id m2sm2679099lam.41.2014.10.25.01.40.55
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sat, 25 Oct 2014 01:40:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 24 Oct 2014 11:34:08 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 86851] New: Reproducible panic on heavy UDP traffic


https://bugzilla.kernel.org/show_bug.cgi?id=86851

            Bug ID: 86851
           Summary: Reproducible panic on heavy UDP traffic
           Product: Networking
           Version: 2.5
    Kernel Version: 3.18-rc1
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: chutzpah@gentoo.org
        Regression: No

Created attachment 154861
  --> https://bugzilla.kernel.org/attachment.cgi?id=154861&action=edit
Panic message captured over serial console

This bug is being encountered on a machine with 6 ixgbe interfaces configured
as 3 bonded pairs. Currently using netperf for testing UDP throughput from ~136
client machines connected via 1G interfaces.

This is the command being run on the clients:
netperf -H XX.XX.XX.XX -t OMNI -l 60 -- -d send -T UDP -O throughput,direction
-m 16384

This is the command being run on the server:
netserver -4

-- 
You are receiving this mail because:
You are the assignee for the bug.
