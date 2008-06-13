From: Adrian Bunk <bunk@kernel.org>
Subject: [Bug 10903] New: ssh connections hang with 2.6.26-rc5 (fwd)
Date: Fri, 13 Jun 2008 12:54:49 +0300
Message-ID: <20080613095449.GA17460@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: bugme-daemon@bugzilla.kernel.org, didier@raboud.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:47502 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753721AbYFMJ4A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jun 2008 05:56:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A 2.6.26-rc networking regression?

Please reply via email.


----- Forwarded message from bugme-daemon@bugzilla.kernel.org -----

Date: Fri, 13 Jun 2008 02:39:17 -0700 (PDT)
From: bugme-daemon@bugzilla.kernel.org
To: bunk@kernel.org
Subject: [Bug 10903] New: ssh connections hang with 2.6.26-rc5

http://bugzilla.kernel.org/show_bug.cgi?id=10903

           Summary: ssh connections hang with 2.6.26-rc5
           Product: Networking
           Version: 2.5
     KernelVersion: 2.6.26-rc5
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
        AssignedTo: acme@ghostprotocols.net
        ReportedBy: didier@raboud.com


Latest working kernel version: 2.6.25-2
Earliest failing kernel version: 2.6.26-rc5
Distribution: Debian (Lenny + Sid)
Hardware Environment: amd64 (Dell Latitude D630)
Software Environment: KDE
Problem Description:

With kernel version 2.6.26-rc5, the ssh connections to remote servers randomly
hang (no error message). No amelioration despite the activation of
"ServerAliveInterval" on both sides.

Steps to reproduce:

Connect to a remote ssh server and do some stuff. After some time, the
connection will hang.

Please ask for details.


------- You are receiving this mail because: -------
