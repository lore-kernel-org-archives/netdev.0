From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 2938] New: broken udp packets silently dropped
Date: Wed, 23 Jun 2004 10:22:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040623102251.11654dc3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Wed, 23 Jun 2004 03:02:37 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 2938] New: broken udp packets silently dropped


http://bugme.osdl.org/show_bug.cgi?id=2938

           Summary: broken udp packets silently dropped
    Kernel Version: 2.6.6
            Status: NEW
          Severity: normal
             Owner: niv@us.ibm.com
         Submitter: martin@rabbta.com


Distribution: Debian testing
Hardware Environment: Intel(R) Xeon(TM) CPU 3.06GHz, Intel Corp. 82546EB Gigabit
Ethernet Controller (Copper) (rev 01)
Software Environment: iptables, netstat, tethereal
Problem Description: 
Packets arrive to my MAC and my IP (according to output from tethereal as well
as log output from iptables), but get dropped at "Routing Decision" in
http://ebtables.sourceforge.net/br_fw_ia/PacketFlow.png (according to log output
from iptables). 
No mention of new packet receive errors in "netstat -s". 
On a 2.4.22-kernel the listening socket gets a "Resource temporarily
unavailable" and "netstat -s" shows new packet receive errors when the same
source sends packets.

Steps to reproduce:
I will try to submit a tethereal-dump as soon as I get the possibility to do
this again. But probably all you need to do is send packets with wrong checksum
to a 2.6.6-kernel and watch them get silently dropped.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
