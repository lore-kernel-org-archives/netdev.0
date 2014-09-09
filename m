From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 84051] New: Panic while transferring bigger amount of data
 with device driver "forcedeth"
Date: Mon, 8 Sep 2014 17:28:04 -0700
Message-ID: <20140908172804.6d5f19ed@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:65025 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753533AbaIIA2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 20:28:19 -0400
Received: by mail-pa0-f47.google.com with SMTP id ey11so5828253pad.6
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 17:28:19 -0700 (PDT)
Received: from uryu.home.lan ([67.204.147.58])
        by mx.google.com with ESMTPSA id bv5sm9882556pbc.20.2014.09.08.17.28.18
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 08 Sep 2014 17:28:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 7 Sep 2014 23:43:26 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 84051] New: Panic while transferring bigger amount of data with device driver "forcedeth"


https://bugzilla.kernel.org/show_bug.cgi?id=84051

            Bug ID: 84051
           Summary: Panic while transferring bigger amount of data with
                    device driver "forcedeth"
           Product: Networking
           Version: 2.5
    Kernel Version: 3.14.4
          Hardware: Intel
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: mapo2364@gmail.com
        Regression: No

Created attachment 149391
  --> https://bugzilla.kernel.org/attachment.cgi?id=149391&action=edit
/var/log/messages with kernel panic

Overview: 

While transferring about 20GB (~40MB/s) over SSH the kernel is going to panic.
After about a minute.


Steps to Reproduce: 

1) git clone of a big repo

2) wait


Actual Results: 

Kernel Panic: see attached log


Build Date & Hardware:

Linux client-01 3.14.4-aufs-x86_64-mynet-latest-unstable #1 SMP Sat Jul 5
13:06:29 CEST 2014 x86_64 AMD Phenom(tm) II X4 955 Processor AuthenticAMD
GNU/Linux
aufs-sources from gentoo portage


PS: This is my first bug report. Please feel free to ask for further
information, if needed.

-- 
You are receiving this mail because:
You are the assignee for the bug.
