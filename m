From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 75221] New: CONFIG_PROC_SYSCTL is required for networking
Date: Thu, 1 May 2014 09:15:15 -0700
Message-ID: <20140501091515.2371058e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:44745 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbaEAQPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 12:15:19 -0400
Received: by mail-pd0-f182.google.com with SMTP id v10so3288326pde.13
        for <netdev@vger.kernel.org>; Thu, 01 May 2014 09:15:18 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id bs17sm160825359pac.28.2014.05.01.09.15.17
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 01 May 2014 09:15:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 1 May 2014 03:17:32 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 75221] New: CONFIG_PROC_SYSCTL is required for networking


https://bugzilla.kernel.org/show_bug.cgi?id=75221

            Bug ID: 75221
           Summary: CONFIG_PROC_SYSCTL is required for networking
           Product: Networking
           Version: 2.5
    Kernel Version: 3.14.2
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: stefan@konink.de
        Regression: No

I am in the proces of building an embedded kernel which I wanted to limit in
both functionality and memory. For this reason I disabled CONFIG_PROC_SYSCTL. I
have figured out the hard way that this functionality implements the successful
randomisation of source ports, it might be responsible for the initialisation
of net.ipv4.ip_local_port_range.

Effectively, booting a kernel with ip=dhcp works. Ping-pong (ICMP) to and from
an address works. DNS queries (UDP/53) don't because the source port remains 0,
a connection to a typical webserver also seems to result in a no reply
situation.

-- 
You are receiving this mail because:
You are the assignee for the bug.
