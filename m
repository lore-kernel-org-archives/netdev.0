From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4449] New: IPSec tunnel forwarding problem
Date: Wed, 6 Apr 2005 02:35:15 -0700
Message-ID: <20050406023515.538d73c1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoann.allain@thomson.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Wed, 6 Apr 2005 02:28:56 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4449] New: IPSec tunnel forwarding problem


http://bugme.osdl.org/show_bug.cgi?id=4449

           Summary: IPSec tunnel forwarding problem
    Kernel Version: 2.6.11-uml
            Status: NEW
          Severity: blocking
             Owner: shemminger@osdl.org
         Submitter: yoann.allain@thomson.net


Distribution: Debian sarge 
Hardware Environment: x86
Software Environment: ipsec-tools-0.5
Problem Description:  IP packets that should be forwarded after being decrypted
out of a IPSec tunnel are not forwarded.

Steps to reproduce: Lets take three hosts A B and C:
B is the gateway between A and C.

A<------->B<------->C

First check that ping from A to C are working. If not check forwarding options in B.

Then create an Ipsec tunnel between two hosts A and B.

A<========>B<------->C

Once the IPSec tunnel established, and iptables configured on B to print logs
(for hooks Input Forward and Pre-Routing), try again to ping C from A.

You should see that packets arrives to B in ESP format and goes to:

hook

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
