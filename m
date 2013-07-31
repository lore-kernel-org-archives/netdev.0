From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 60662] New: MosChip MCS7830 Ethernet adapter no longer
 working after usbnet changes in 3.10
Date: Wed, 31 Jul 2013 08:35:56 -0700
Message-ID: <20130731083556.63e31c71@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34323 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756560Ab3GaPgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 11:36:00 -0400
Received: by mail-pa0-f52.google.com with SMTP id kq13so987626pab.39
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 08:36:00 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-71-109.bvtn.or.frontiernet.net. [50.53.71.109])
        by mx.google.com with ESMTPSA id ue9sm5207572pab.7.2013.07.31.08.35.59
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 31 Jul 2013 08:35:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 31 Jul 2013 02:40:48 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 60662] New: MosChip MCS7830 Ethernet adapter no longer working after usbnet changes in 3.10


https://bugzilla.kernel.org/show_bug.cgi?id=60662

            Bug ID: 60662
           Summary: MosChip MCS7830 Ethernet adapter no longer working
                    after usbnet changes in 3.10
           Product: Networking
           Version: 2.5
    Kernel Version: 3.10.4
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: blocking
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: kernel-bugzilla@schmalmack.net
        Regression: No

This bug may or may not be related to
bug #60521 usbnet changes in 3.10 stop use of sierra_net devices
Since both resolutions are different, I decided to create a new bug.

With kernels 3.10.4 and 3.10.0, my Delock USB Ethernet adapter (using a MosChip
device) hardly survives the DHCP phase, then quickly becomes unresponsive. 
Sometimes even during DHCP.

Things went back to normal after reverting commit

4be74c130d1c5c03bccef0ab8d7a6bb71c7de53a usbnet: mcs7830: apply
usbnet_link_change

I haven't digged any further so far.

  Till

-- 
You are receiving this mail because:
You are the assignee for the bug.
