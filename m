From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 14749] New: Kernel locks up after a few minutes of heavy
 surfing
Date: Mon, 7 Dec 2009 09:01:54 -0800
Message-ID: <20091207090154.6bbfe8e2@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43522 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757954AbZLGRCE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2009 12:02:04 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id A79874F4030
	for <netdev@vger.kernel.org>; Mon,  7 Dec 2009 09:02:10 -0800 (PST)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ovyyT8G0dkW0 for <netdev@vger.kernel.org>;
	Mon,  7 Dec 2009 09:01:55 -0800 (PST)
Received: from nehalam (pool-71-117-243-57.ptldor.fios.verizon.net [71.117.243.57])
	by mail.vyatta.com (Postfix) with ESMTP id 6944D4F4024
	for <netdev@vger.kernel.org>; Mon,  7 Dec 2009 09:01:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 6 Dec 2009 13:40:19 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 14749] New: Kernel locks up after a few minutes of heavy surfing


http://bugzilla.kernel.org/show_bug.cgi?id=14749

           Summary: Kernel locks up after a few minutes of heavy surfing
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.31.6
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: rankincj@yahoo.com
        Regression: Yes


Created an attachment (id=24049)
 --> (http://bugzilla.kernel.org/attachment.cgi?id=24049)
Warnings found in kernel, relating to network corruption.

This bug is new as of 2.6.31.x kernels. After a short period of heavy surfing
(e.g. lots of tabs open in Firefox), the kernel will suddenly stop responding.
Nothing is written to the serial console, and the machine stops responding to
pings. My only clue so far has been a warning which I found once in my dmesg
log (attached).

I have already tried manually applying this patch from the upcoming -stable
queue:

net-fix-sk_forward_alloc-corruption.patch

to no effect.

I am currently switching back to Fedora's 2.6.31.6-145.fc12.i686 kernel to see
if it is more stable. (I cannot trust 2.6.31.6 any more.)

-- 
Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.


-- 
