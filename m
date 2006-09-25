From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 7202] New: sun happy meal ethernet driver
 problem
Date: Mon, 25 Sep 2006 09:43:58 -0700
Message-ID: <20060925094358.7f4e7c2c.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: saurabhsinghvi@gmail.com,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18835 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750902AbWIYQoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 12:44:11 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Mon, 25 Sep 2006 09:23:59 -0700
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 7202] New: sun happy meal ethernet driver problem


http://bugzilla.kernel.org/show_bug.cgi?id=7202

           Summary: sun happy meal ethernet driver problem
    Kernel Version: 2.6.17
            Status: NEW
          Severity: normal
             Owner: acme@conectiva.com.br
         Submitter: saurabhsinghvi@gmail.com
                CC: saurabhsinghvi@gmail.com


Most recent kernel where this bug did not occur: 2.4.24
Distribution: Gentoo
Hardware Environment: Sun Ultra Sparc 5
Software Environment: linux
Problem Description: Outgoing packet dropping of tcp packets in the hme driver
for the sun happy meal ethernet. UDP packets work just fine. Below is a netio
test of the card. The sun computer is the server for the test and another
machine (which performs correctly for the same test with other machines) is a
client. The results posted are as viewed from the client. 

results with netio -t option (TCP):

Packet size  1k bytes:  10140 KByte/s Tx,  166 KByte/s Rx.
Packet size  2k bytes:  11068 KByte/s Tx,  117 KByte/s Rx.
Packet size  4k bytes:  11166 KByte/s Tx,  78516 Byte/s Rx.
Packet size  8k bytes:  10271 KByte/s Tx,  67 KByte/s Rx.
Packet size 16k bytes:  10328 KByte/s Tx,  61 KByte/s Rx.
Packet size 32k bytes:  10329 KByte/s Tx,  76849 Byte/s Rx.
Done.

results with netio -u option (UDP):

Packet size  1k bytes:  9388 KByte/s (0%) Tx,  10742 KByte/s (0%) Rx.
Packet size  2k bytes:  10268 KByte/s (0%) Tx,  11257 KByte/s (0%) Rx.
Packet size  4k bytes:  10541 KByte/s (0%) Tx,  11570 KByte/s (0%) Rx.
Packet size  8k bytes:  10528 KByte/s (0%) Tx,  11581 KByte/s (0%) Rx.
Packet size 16k bytes:  10542 KByte/s (0%) Tx,  11627 KByte/s (0%) Rx.
Packet size 32k bytes:  10572 KByte/s (0%) Tx,  11642 KByte/s (0%) Rx.
Done.


As can be seen above, the LAN is 10MB/s capable, while the card is barely
performing over a few hundred kbytes/s. 

Steps to reproduce: not working as-is.

The problem has been observed by atleast one other person
(http://forums.gentoo.org/viewtopic-t-500365-highlight-.html?sid=121fb7b0c83e17e7e18a5bce20a2971d)

Please look into it.

thanks
Saurabh

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
