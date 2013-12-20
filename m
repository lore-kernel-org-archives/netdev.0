From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 67431] New: Network operations not working
Date: Fri, 20 Dec 2013 08:00:02 -0800
Message-ID: <20131220080002.541ebf54@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:52547 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748Ab3LTQAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 11:00:07 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so2790033pab.34
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 08:00:06 -0800 (PST)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id yg3sm19807791pab.16.2013.12.20.08.00.05
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 20 Dec 2013 08:00:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 20 Dec 2013 07:47:55 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 67431] New: Network operations not working


https://bugzilla.kernel.org/show_bug.cgi?id=67431

            Bug ID: 67431
           Summary: Network operations not working
           Product: Networking
           Version: 2.5
    Kernel Version: 3.9 thru 3.11
          Hardware: x86-64
                OS: Linux
              Tree: Fedora
            Status: NEW
          Severity: blocking
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: info@vintageelectronics.ca
        Regression: No

All these issues cropped up after upgrading Fedora 14 64bit to Fedora 19 64bit 
in a box with Gigabyte GA-890XA-UD3 motherboard with onboard Realtek 8111D NIC
and Phenom II 955 CPU.

1. CIFS shares cannot close files. While copying files to Windows machines, the
0 size files get created, process then writes X number of bytes to the file and
freezes so that machine has to be rebooted. I can reproduce this 100%. KIO
seems to be a bit more stable in a sense that while writing to a network folder
in KDE the process still freezes, but operation can be cancelled. Not 100% sure
that it can be cancelled at all times, but I observed both behaviours with KDE:
freezing to death and cancel button stopping w/o freezing.

At the same time the same files can be pulled from a Windows machine using a
Samba share on F19 machine.

2. CUPS cannot print to the network printers. The JetDirect HP LJ 4000N that
worked fine under F14 now prints one empty sheet and 2nd sheet with error
message while LCD displays 'BAD TRANSMISSION' and error LED flashes. I can
reproduce this 100%

3. Thunderbird version 17 thru 26 cannot send HTML emails and plain text emails
longer than probably 1kB. New plain text emails go out, but replies to plain
text emails seem to be affected too. I can reproduce this 100%.

-- 
You are receiving this mail because:
You are the assignee for the bug.
