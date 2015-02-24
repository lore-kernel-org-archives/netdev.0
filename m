From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 93731] New: GARP packet is not sent for interface up
Date: Tue, 24 Feb 2015 14:21:56 -0800
Message-ID: <20150224142156.5cd1ea91@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:34703 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752587AbbBXWV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 17:21:56 -0500
Received: by iecrp18 with SMTP id rp18so49971iec.1
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 14:21:56 -0800 (PST)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id t1sm10264152igs.0.2015.02.24.14.21.55
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 14:21:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 24 Feb 2015 08:07:40 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 93731] New: GARP packet is not sent for interface up


https://bugzilla.kernel.org/show_bug.cgi?id=93731

            Bug ID: 93731
           Summary: GARP packet is not sent for interface up
           Product: Networking
           Version: 2.5
    Kernel Version: 3.10
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: blocking
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: aniyas15@gmail.com
        Regression: No

Hi All,

I am working custom platform based on x86_64 running 3.10 kernel,
Recently I found an issue related to GARP. It seems like  no GARP
packets are being sent out when an Interface is made up. But I also
noticed that only when I use "arping" tool only then it sends out any
GARP packet.

I also try setting the net variable "arp_notify" then I see the
arp_send() function is being called after that I am unable to track
further.

Could you please help me, what could be issue, Is it a valid
expectation that during interface up the linux kernel should send out
GARP packet? If so, am I missing any kernel configuration related to
it?

Thanks in Advance.

Regards,
A.Mydeen.

-- 
You are receiving this mail because:
You are the assignee for the bug.
