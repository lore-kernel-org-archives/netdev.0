From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 48601] New: Pauses while downloading
Date: Mon, 8 Oct 2012 09:29:49 -0700
Message-ID: <20121008092949.39d6cc4e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45370 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753542Ab2JHQa3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 12:30:29 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id D1BB01410202
	for <netdev@vger.kernel.org>; Mon,  8 Oct 2012 09:30:28 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id N-4+AobWkpT2 for <netdev@vger.kernel.org>;
	Mon,  8 Oct 2012 09:30:27 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	by mail.vyatta.com (Postfix) with ESMTPSA id D20E61410211
	for <netdev@vger.kernel.org>; Mon,  8 Oct 2012 09:30:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon,  8 Oct 2012 09:12:17 +0000 (UTC)
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 48601] New: Pauses while downloading


https://bugzilla.kernel.org/show_bug.cgi?id=48601

           Summary: Pauses while downloading
           Product: Networking
           Version: 2.5
    Kernel Version: 3.6
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: low
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: colbec@start.ca
        Regression: No


Using OpenSUSE 12.2, Gnome 3.6 with Network Manager.
Recently upgraded from kernel 3.5 to 3.6, at which point the issue began.

Observed symptoms: while downloading, the stream will stop at random points for
5 to 120+ seconds, and then resume the download.
Example 1: while browsing, click on a link one time in 10 (approx) will fail to
get the page, and a second click is successful. Sometimes it will begin to get
the page, then stop, use back button to get previous page back, click link
again and the page is fetched successfully.
Example 2: try to test download speed using speedtest.net, one test in two
shows a normal start to the download side of the test, during the test the
process stops, then recommences after a varying period 5 to 120+ seconds.
Pauses happen one or multiple times.
Example 3: attempt to download a 20MB mp4 using Firefox. Process begins
correctly, but during the download the process stops, again for 5-120 sec, and
resumes. Downloads take a long time, but will eventually complete. If I kick it
(pause, resume in download manager) it will complete faster.

I have replaced cables, NIC; return to kernel 3.5 eliminates the issue.

.config file was copied from a 3.4.2 kernel version, worked well for 3.5, and
also seemed to be good for 3.6 with the exception of failed webcam which needed
V4L reinstated.

--- Comment #1 from Alan <alan@lxorguk.ukuu.org.uk>  2012-10-08 15:03:59 ---
Please provide detailed information on the hardware or network setup. Without
that it's hard to do anything.

--- Comment #2 from colbec@start.ca  2012-10-08 15:43:58 ---
OK, first to note is that two Windows machines on the same network using the
same wireless route to the WAN do not show this issue. Since kernel 3.5 is
clear and only 3.6 is the problem this seems to rule out the network
components, but anyway I am connecting to the WAN through two Linksys WRT4GL
running DD-WRT. Route continues to WAN through a wireless high speed connection
via Motorola Canopy technology.

I have replaced the cabling with identical results.
I have added a PCI NIC (Realtek) which behaves the same way as the onboard NIC
(Atheros AR8131).

Memory 3.8 GiB, Intel Core 2 Quad Q8300 @ 2.5 GHz x 4
Graphics Intel G41 64 bit OS, Disk 500 GB.
Correction to Gnome version 3.4.2. (not stated 3.6)

I have a ream of further hardware info from Yast, please specify what detail
would be helpful.
