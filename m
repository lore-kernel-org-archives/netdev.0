From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 54861] New: r6040 net-driver on new kernels not
 work(3.X.X)
Date: Tue, 5 Mar 2013 08:30:32 -0800
Message-ID: <20130305083032.3a43c194@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:50913 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757247Ab3CEQag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 11:30:36 -0500
Received: by mail-pb0-f54.google.com with SMTP id rr4so4655913pbb.13
        for <netdev@vger.kernel.org>; Tue, 05 Mar 2013 08:30:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 5 Mar 2013 08:02:27 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 54861] New: r6040 net-driver on new kernels not work(3.X.X)


https://bugzilla.kernel.org/show_bug.cgi?id=54861

           Summary: r6040 net-driver on new kernels not work(3.X.X)
           Product: Networking
           Version: 2.5
    Kernel Version: 3.6.8 (3.7.8), possible all new versions
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: sunheretic13@gmail.com
        Regression: No


Created an attachment (id=94581)
 --> (https://bugzilla.kernel.org/attachment.cgi?id=94581)
kernel config files (2.6.37.2 , 3.6.8, 3.7.8)

Hello.

I have a problem.

I have a motherboard with processor RDC8610. As PHY-chip used tlk100 (Texas
Instruments). tlk100 uses "Generic PHY-driver" from kernel.

When I compile a kernel 2.6.37.2 works fine.

When I compile a kernel 3.6.8 or 3.7.8 I have problems in the network.
The built-in network card (r6040) does not work pings.
ifconfig shows no errors, but the "RX bytes"> 0 while the "TX bytes" = 0! It
seems that the transmitter is not initialized or not working.

Rarely get messages on the console:

eth1: link UP
eth1: link DOWN

As I see it, the value "TX bytes" from ifconfig increased (but not
significantly)


Network cable is connected and not damaged.

I can see that from the kernel version 2.6.37.2 to 3.6.8, the NIC driver r6040
upgraded from 0.26 (30May2010) to 0.28 (07Oct2011).

I attach the configuration files of the kernel.

What is it? Bug in the new driver r6040?
Or am I doing wrong?

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
