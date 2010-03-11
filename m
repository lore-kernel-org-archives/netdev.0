From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 15517] New: big file transfers stall and break network
Date: Thu, 11 Mar 2010 08:46:30 -0800
Message-ID: <20100311084630.64b85696@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41475 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933285Ab0CKRUo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 12:20:44 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 280534F4334
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 09:20:39 -0800 (PST)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ouGtW+BVpxm9 for <netdev@vger.kernel.org>;
	Thu, 11 Mar 2010 09:20:38 -0800 (PST)
Received: from nehalam (unknown [10.250.0.103])
	by mail.vyatta.com (Postfix) with ESMTP id 835004F42E9
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 09:20:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 11 Mar 2010 14:40:12 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 15517] New: big file transfers stall and break network


http://bugzilla.kernel.org/show_bug.cgi?id=15517

           Summary: big file transfers stall and break network
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.32.9
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: conrad_s@rocketmail.com
        Regression: Yes


Created an attachment (id=25475)
 --> (http://bugzilla.kernel.org/attachment.cgi?id=25475)
lspci output, from working 2.6.31

Upgrading to kernel 2.6.32.9 on a 64-bit machine (Fedora 12,
2.6.32.9-67.fc12.x86_64) caused breakage in transfer of large files over SSH
and SMB, followed by breaking network access.

To reproduce, copy a large file (> 900 MB) using SSH or SMB (mounted either
directly via "mount" or indirectly via "gfvs / nautilus").  Copy stalls and
network becomes unusable (e.g. can't ssh to any other host).

Previous kernel 2.6.31.12 (Fedora 12, 2.6.31.12-174.2.22.fc12.x86_64) works
fine.

-- 

