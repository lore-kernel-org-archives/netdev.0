From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 107071] New: ip route add with src failes with RTNETLINK
 answers: Invalid argument
Date: Tue, 3 Nov 2015 13:08:20 -0800
Message-ID: <20151103130820.3356b6cd@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35255 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755304AbbKCVIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 16:08:09 -0500
Received: by pasz6 with SMTP id z6so29254650pas.2
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 13:08:08 -0800 (PST)
Received: from xeon-e3 (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by smtp.gmail.com with ESMTPSA id xm4sm31251095pab.27.2015.11.03.13.08.08
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 13:08:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a 4.3 kernel bug, not iproute2

Begin forwarded message:

Date: Tue, 3 Nov 2015 04:37:03 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 107071] New: ip route add with src failes with RTNETLINK answers: Invalid argument


https://bugzilla.kernel.org/show_bug.cgi?id=107071

            Bug ID: 107071
           Summary: ip route add with src failes with RTNETLINK answers:
                    Invalid argument
           Product: Networking
           Version: 2.5
    Kernel Version: 4.3.0
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: vladi@aresgate.net
        Regression: No

when I try to add sudo ip route add 10.248.5.0/24 dev bond0.250 table vlan_250
src 10.248.5.154

I get RTNETLINK answers: Invalid argument

On latest 4.3 compiled from source on ubuntu 14.04

strace:
https://bpaste.net/show/78afc27a1bb7

-- 
You are receiving this mail because:
You are the assignee for the bug.
