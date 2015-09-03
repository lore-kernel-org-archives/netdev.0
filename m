From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 103991] New: skb legth doesn't match the sum of all the
 fragments length
Date: Thu, 3 Sep 2015 10:37:43 -0700
Message-ID: <20150903103743.56271574@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35098 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbbICRhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 13:37:33 -0400
Received: by pacfv12 with SMTP id fv12so53983014pac.2
        for <netdev@vger.kernel.org>; Thu, 03 Sep 2015 10:37:33 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by smtp.gmail.com with ESMTPSA id n6sm25980091pdr.55.2015.09.03.10.37.32
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 10:37:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There is really not enough information here to make a real evaluation.
kernel is old, hardware is unspecified, and the real problem is not well
identified.


Begin forwarded message:

Date: Thu, 3 Sep 2015 10:51:44 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 103991] New: skb legth doesn't match the sum of all the fragments length


https://bugzilla.kernel.org/show_bug.cgi?id=103991

            Bug ID: 103991
           Summary: skb legth doesn't match the sum of all the fragments
                    length
           Product: Networking
           Version: 2.5
    Kernel Version: 3.13.0-62-generic
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: tht1234@mailinator.com
        Regression: No

The DUT has 2 interfaces with the same 10GB Ethernet card .
The driver and H/W support TSO at 10G speed.
IP forwarding on the DUT is enabled.
Run iperf from a system connected to one interface to a system connedted to the
second interface:

      system A -------> DUT -------> system B

Watch the outgoing skbs on the DUT to system B:

  On packets with nr_frags == MAX_SKB_FRAGS (17) skb_len is *NOT* equal the
some of the skb->len - skb->data_len + all of its frag->size.

-- 
You are receiving this mail because:
You are the assignee for the bug.
