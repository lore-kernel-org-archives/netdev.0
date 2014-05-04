From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 75411] New: kernel panic when start using VirtIO network
 in VM
Date: Sun, 4 May 2014 11:25:06 -0700
Message-ID: <20140504112506.5d472295@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:52632 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbaEDSZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 14:25:10 -0400
Received: by mail-pd0-f181.google.com with SMTP id w10so5855454pde.26
        for <netdev@vger.kernel.org>; Sun, 04 May 2014 11:25:09 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id nx12sm50876313pab.6.2014.05.04.11.25.08
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sun, 04 May 2014 11:25:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sat, 3 May 2014 11:10:40 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 75411] New: kernel panic when start using VirtIO network in VM


https://bugzilla.kernel.org/show_bug.cgi?id=75411

            Bug ID: 75411
           Summary: kernel panic when start using VirtIO network in VM
           Product: Networking
           Version: 2.5
    Kernel Version: kernel-3.14.2-200.fc20.x86_64
          Hardware: All
                OS: Linux
              Tree: Fedora
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: i.gnatenko.brain@gmail.com
        Regression: No

Steps to reproduce:
1. create VM (kvm)
2. add bridged(?) VirtIO network or e1000(?)
3. start using internet from VM

Actual results:
Kernel panic (screenshoot in attach)

Expected results:
all works OK

Additional info:
when I;ve used e1000 driver for VM I've got this bug:
https://bugzilla.redhat.com/show_bug.cgi?id=1093708

-- 
You are receiving this mail because:
You are the assignee for the bug.
