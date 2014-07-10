From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 79891] New: Router causes TCP retransmits for windows
 hosts after "ip_forward: fix inverted local_df test"
Date: Thu, 10 Jul 2014 06:44:33 -0700
Message-ID: <20140710064433.1fd17105@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:59754 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbaGJNoi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 09:44:38 -0400
Received: by mail-pa0-f51.google.com with SMTP id hz1so11031819pad.24
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 06:44:38 -0700 (PDT)
Received: from samsung-9 ([2001:67c:618:606:9870:53bf:8402:7d53])
        by mx.google.com with ESMTPSA id pq3sm62022515pbb.57.2014.07.10.06.44.37
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 10 Jul 2014 06:44:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 10 Jul 2014 06:20:14 -0700
=46rom: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla=
=2Ekernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 79891] New: Router causes TCP retransmits for windows hos=
ts after "ip_forward: fix inverted local_df test"


https://bugzilla.kernel.org/show_bug.cgi?id=3D79891

            Bug ID: 79891
           Summary: Router causes TCP retransmits for windows hosts aft=
er
                    "ip_forward: fix inverted local_df test"
           Product: Networking
           Version: 2.5
    Kernel Version: 3.2.60
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: tm@del.bg
        Regression: No

Created attachment 142651
  --> https://bugzilla.kernel.org/attachment.cgi?id=3D142651&action=3De=
dit
TCP retransmissions from a windows host

After upgrading a router to Linux 3.2.60 most windows machines behind i=
t
started experiencing connection stalls. Downgrade to 3.2.59 resolved th=
e
problem. Using git bisect I pinpointed it to
"59d9f389df3cdf72833d5ee17c3fe959b6bdc792 is the first bad commit", whi=
ch
entered the kernel from here
http://marc.info/?l=3Dlinux-netdev&m=3D139949081418806&w=3D2

No connection problems for Linux hosts at all =E2=80=93 only windows. P=
lease, find
attached tcpdump packet capture demonstrating the bad behaviour.

--=20
You are receiving this mail because:
You are the assignee for the bug.
