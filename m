From: Andrew Morton <akpm@linux-foundation.org>
Subject: Fw: [Bugme-new] [Bug 8085] New: performance drop in 2.6.20
Date: Mon, 26 Feb 2007 07:20:53 -0800
Message-ID: <20070226072053.20573672.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, a1bert@atlas.cz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:49301 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030276AbXBZPVz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 10:21:55 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


ooh.

Begin forwarded message:

Date: Mon, 26 Feb 2007 07:10:48 -0800
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 8085] New: performance drop in 2.6.20


http://bugzilla.kernel.org/show_bug.cgi?id=8085

           Summary: performance drop in 2.6.20
    Kernel Version: 2.6.20
            Status: NEW
          Severity: normal
             Owner: shemminger@osdl.org
         Submitter: a1bert@atlas.cz


Most recent kernel where this bug did *NOT* occur: 2.6.19.5
Distribution: slackware based
Hardware Environment: Xeon + e1000
Software Environment: gcc 3.3.x
Problem Description: noticeable (10-15%) routing and bridging (possibly 
overall) performance drop between 2.6.19.5 - 2.6.20 (2.6.20.1 2.6.21-rc1 too) 
same configs

we are experiencing performance drop on our rather busy(>150kpps >700Mbps in 
one direction) bridge with ebtables and routers (210k routes, >30kpps duplex). 
It's not e1000 issue.

Steps to reproduce:

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
