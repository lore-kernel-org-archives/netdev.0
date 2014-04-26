From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 74851] New: Using kernel 3.14.x causes NAT Clients having
 very slow upload (< 5kb/s) or timeouts
Date: Fri, 25 Apr 2014 18:41:42 -0700
Message-ID: <20140425184143.2796a3bc@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:60340 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321AbaDZBlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 21:41:46 -0400
Received: by mail-qg0-f51.google.com with SMTP id f51so4808159qge.38
        for <netdev@vger.kernel.org>; Fri, 25 Apr 2014 18:41:46 -0700 (PDT)
Received: from samsung-9 (pool-72-79-201-28.spfdma.east.verizon.net. [72.79.201.28])
        by mx.google.com with ESMTPSA id q5sm12227517qam.37.2014.04.25.18.41.45
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Apr 2014 18:41:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 25 Apr 2014 11:29:02 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 74851] New: Using kernel 3.14.x causes NAT Clients having very slow upload (< 5kb/s) or timeouts


https://bugzilla.kernel.org/show_bug.cgi?id=74851

            Bug ID: 74851
           Summary: Using kernel 3.14.x causes NAT Clients having very
                    slow upload (< 5kb/s) or timeouts
           Product: Networking
           Version: 2.5
    Kernel Version: 3.14.1
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: ck@conrad-kostecki.de
        Regression: No

Hi!
I've recently upgraded on my router-gentoo box my kernel from 3.13.x to 3.14.1.
The kernel boots fine, but it causes, that every client behind NAT cannot
upload anymore fast. The upload starts very fast (~ 400kb/s) for about 0.5 sec
and drops immediately to about 2-5kb/s. There are also sometime timeouts after
a few more seconds. Only the upload seems to be affected, while downloads is
always full speed and works fine. Uploading directly on the gentoo-router box
works always fine with the new kernel!

I've tried gentoo-sources and vanilla-sources. Both gave me the same result. I
don't know, how to debug this problem. Which information do you need?

Conrad

-----

Gentoo Linux
Kernel 3.15.6 / 3.14.1
iptables v1.4.21
4x Intel 82574L (Soekris net6501-70 platform)

-- 
You are receiving this mail because:
You are the assignee for the bug.
