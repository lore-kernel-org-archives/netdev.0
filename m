From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4037] New: Incorrect parameters handling in
 pktgen.c.
Date: Thu, 13 Jan 2005 11:53:28 -0800
Message-ID: <20050113115328.7d66410f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nmalykh@bilim.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Thu, 13 Jan 2005 08:29:49 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4037] New: Incorrect parameters handling in pktgen.c. 


http://bugme.osdl.org/show_bug.cgi?id=4037

           Summary: Incorrect parameters handling in pktgen.c.
    Kernel Version: <= 2.6.10
            Status: NEW
          Severity: normal
             Owner: acme@conectiva.com.br
         Submitter: nmalykh@bilim.com


Distribution: kernel source
Hardware Environment: ALL
Software Environment: ALL
Problem Description: Incorrect handling cur_udp_dst and cur_udp_src in function
mod_cur_headers(). Few mistakes in Documentation/networking/pktgen.txt

Steps to reproduce: set udp_src_min > udp_src_max or/and udp_dst_min >=
udp_dst_max in packet generation script

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
