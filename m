From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 52481] New: Occasional NULL pointer dereference during ftp
 networking since 3.7
Date: Thu, 10 Jan 2013 09:21:36 -0800
Message-ID: <20130110092136.0a74f203@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36728 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751907Ab3AJRXD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 12:23:03 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 32B861410447
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 09:23:03 -0800 (PST)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id yEoere-mR5VH for <netdev@vger.kernel.org>;
	Thu, 10 Jan 2013 09:23:02 -0800 (PST)
Received: from nehalam.linuxnetplumber.net (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	by mail.vyatta.com (Postfix) with ESMTPSA id 090B41410444
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 09:23:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue,  8 Jan 2013 14:29:18 +0000 (UTC)
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 52481] New: Occasional NULL pointer dereference during ftp networking since 3.7


https://bugzilla.kernel.org/show_bug.cgi?id=52481

           Summary: Occasional NULL pointer dereference during ftp
                    networking since 3.7
           Product: Networking
           Version: 2.5
    Kernel Version: 3.7.0
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: itumaykin@gmail.com
        Regression: Yes


Created an attachment (id=90771)
 --> (https://bugzilla.kernel.org/attachment.cgi?id=90771)
lspci -vvv

I am experiencing occasional panics during ftp networking after installing
kernel 3.7.0.

I have vsftpd-3.0.2 up and running on port 21 with configuration not changed
for months, I use passive FTP with nf_conntrack_ftp helper. My distro is
Hardened Gentoo amd64 and I use not vanilla kernel, but with some Gentoo
specific and grsec specific patches.

Anyway, with kernel 3.5.4 I had no problems with my FTP at all, but with 3.7.0
there are random panics during or after FTP sessions. It happens more often
after sessions with lots of data transferred, but sometimes only `ls` is enough
to hang my machine.
The nature of these errors is unknown to me, but the issue is definetely within
the kernel as I tried to downgrade solely kernel back to 3.5.4 and everything
returned back to normal.

Also, I don't have traces of these panics in my logs, but I took photos of one
of such cases. Here are links to them:
https://docs.google.com/folder/d/0B9NAm8_0mptgU2RrMTZWX0NucUk/edit

I understand there is probably not enough info to investigate the source of
this issue, but I am ready to provide any additional info or do some testing.

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
