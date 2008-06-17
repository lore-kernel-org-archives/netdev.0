From: Dave Jones <davej@codemonkey.org.uk>
Subject: Fwd: [Bug 451804] New: kernel: KERNEL: assertion (flags &
	MSG_PEEK) failed at net/ipv4/tcp.c (1354)
Date: Tue, 17 Jun 2008 10:40:56 -0400
Message-ID: <20080617144056.GA19275@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="VS++wcV0S1rZb1Fb"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from testure.choralone.org ([194.9.77.134]:53543 "EHLO
	testure.choralone.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758477AbYFQOgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 10:36:50 -0400
Received: from davej by testure.choralone.org with local (Exim 4.69)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1K8cMi-00055F-4t
	for netdev@vger.kernel.org; Tue, 17 Jun 2008 15:40:56 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

This one been reported yet ?

	Dave

-- 
http://www.codemonkey.org.uk

--VS++wcV0S1rZb1Fb
Content-Type: message/rfc822
Content-Disposition: inline

Return-path: <apache@redhat.com>
X-Spam-Checker-Version: SpamAssassin 3.2.4 (2008-01-01) on
	testure.choralone.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=5.0 tests=AWL,BAYES_00,
	RCVD_IN_DNSWL_MED,SPF_PASS autolearn=ham version=3.2.4
Envelope-to: davej@codemonkey.org.uk
Delivery-date: Tue, 17 Jun 2008 15:23:54 +0100
Received: from mx1-phx.redhat.com ([209.132.177.92] helo=mx1.util.phx.redhat.com)
	by testure.choralone.org with esmtp (Exim 4.69)
	(envelope-from <apache@redhat.com>)
	id 1K8c6E-0004gZ-F8
	for davej@codemonkey.org.uk; Tue, 17 Jun 2008 15:23:54 +0100
Received: from bz-web1.app.phx.redhat.com (nat-pool.util.phx.redhat.com [10.8.5.200])
	by mx1.util.phx.redhat.com (8.13.1/8.13.1) with ESMTP id m5HEJa7l028944
	for <davej@codemonkey.org.uk>; Tue, 17 Jun 2008 10:19:37 -0400
Received: from bz-web1.app.phx.redhat.com (localhost.localdomain [127.0.0.1])
	by bz-web1.app.phx.redhat.com (8.13.1/8.13.1) with ESMTP id m5HEJVuu024882
	for <davej@codemonkey.org.uk>; Tue, 17 Jun 2008 10:19:36 -0400
Received: (from apache@localhost)
	by bz-web1.app.phx.redhat.com (8.13.1/8.13.1/Submit) id m5HEGlX9024587;
	Tue, 17 Jun 2008 10:16:47 -0400
Date: Tue, 17 Jun 2008 10:16:47 -0400
From: bugzilla@redhat.com
To: davej@codemonkey.org.uk
Subject: [Bug 451804] New: kernel: KERNEL: assertion (flags & MSG_PEEK) failed at net/ipv4/tcp.c (1354)
Content-type: text/plain; charset=utf-8
Message-ID: <bug-451804-263030@bugzilla.redhat.com>
X-Loop: bugzilla@redhat.com
X-BeenThere: bugzilla@redhat.com
X-Bugzilla-Product: Fedora
X-Bugzilla-Version: 9
X-Bugzilla-Component: kernel
X-Bugzilla-Status: NEW
X-Bugzilla-Comment: Public
X-Bugzilla-Reason: AssignedTo
X-Bugzilla-Changed-Fields: New

Please do not reply directly to this email. All additional
comments should be made in the comments box of this bug report.




https://bugzilla.redhat.com/show_bug.cgi?id=451804

           Summary: kernel: KERNEL: assertion (flags & MSG_PEEK) failed at
                    net/ipv4/tcp.c (1354)
           Product: Fedora
           Version: 9
          Platform: i386
        OS/Version: Linux
            Status: NEW
          Severity: medium
          Priority: low
         Component: kernel
        AssignedTo: kernel-maint@redhat.com
        ReportedBy: ekanter@rcn.com
         QAContact: extras-qa@fedoraproject.org


Description of problem:

Using following wireless pcmcia card

kernel: ath5k_pci 0000:02:00.0: registered as 'phy0'
kernel: ath5k phy0: Atheros AR2413 chip found (MAC: 0x78, PHY: 0x45)

on SONY VIAO PCG-F590 laptop.

configured NFS server and attempted to copy large file into the system. the
speed is very slow. many assertion messages in the log:

kernel: recvmsg bug: copied CEDBCDF6 seq CEDBD39E
kernel: KERNEL: assertion (flags & MSG_PEEK) failed at net/ipv4/tcp.c (1354)

As soon as opened firefox and attempted to file a bug (while NFS transfer was
active) the kernel hung (caps lock and scroll lock LED blink). Tried several times.

Version-Release number of selected component (if applicable):

kernel-2.6.25.6-55.fc9.i686

How reproducible:

always

Steps to Reproduce:

see description.

-- 
Configure bugmail: https://bugzilla.redhat.com/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.

--VS++wcV0S1rZb1Fb--
