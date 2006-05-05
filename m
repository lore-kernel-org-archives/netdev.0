From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 6495] New: Vlan MTU Fragmentation
Date: Thu, 4 May 2006 23:56:28 -0700
Message-ID: <20060504235628.33041b55.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:13996 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932470AbWEEG4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 02:56:38 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Thu, 4 May 2006 23:15:56 -0700
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 6495] New: Vlan MTU Fragmentation


http://bugzilla.kernel.org/show_bug.cgi?id=6495

           Summary: Vlan MTU Fragmentation
    Kernel Version: 2.6.16.12
            Status: NEW
          Severity: normal
             Owner: shemminger@osdl.org
         Submitter: slavon@bigtelecom.ru


Steps to reproduce:

ifconfing eth0 mtu 1500
ifconfing eth0.100 mtu 1500

ping www.ru -s 2000
-- BAD --

----------------

ifconfing eth0 mtu 1500
ifconfing eth0.100 mtu 1496

ping www.ru -s 2000
--NORMAL--

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
