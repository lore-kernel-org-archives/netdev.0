From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 98781] New: WWAN: TX bytes counter shows very huge
 impossible value
Date: Tue, 26 May 2015 08:38:57 -0700
Message-ID: <20150526083857.78cb053b@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [209.85.220.42] ([209.85.220.42]:35078 "EHLO
	mail-pa0-f42.google.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752809AbbEZPkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 11:40:05 -0400
Received: by pacwv17 with SMTP id wv17so95448194pac.2
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 08:38:53 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id ym6sm13515470pac.32.2015.05.26.08.38.52
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 08:38:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sat, 23 May 2015 16:54:50 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 98781] New: WWAN: TX bytes counter shows very huge impossible value


https://bugzilla.kernel.org/show_bug.cgi?id=98781

            Bug ID: 98781
           Summary: WWAN: TX bytes counter shows very huge impossible
                    value
           Product: Networking
           Version: 2.5
    Kernel Version: 4.0.x
          Hardware: Intel
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: mm@superbash.de
        Regression: No

Since version 4.0.x the TX bytes counter of the WWAN module shows a weird
value.

Example:

$ > ifconfig wwan

wwan0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet xxx.xxx.xxx.xxx  netmask 255.255.255.252  broadcast
xxx.xxx.xxx.xxx
        inet6 xxxx::xxxx:xxxx:xxxx:xxxx  prefixlen 64  scopeid 0x20<link>
        ether xx:xx:xx:xx:xx:xx  txqueuelen 1000  (Ethernet)
        RX packets 19036  bytes 19190321 (18.3 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 15874  bytes 43228847574631 (39.3 TiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

39.3 TiB - wow, absolutely not true

The WWAN is used as bridge to my internet provider (LTE usb stick)

I use the counter to control the traffic. It's only the TX counter, the RX
works ok.

-- 
You are receiving this mail because:
You are the assignee for the bug.
