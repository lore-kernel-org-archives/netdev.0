From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 3747] New: HTB causes machine lockups
Date: Mon, 15 Nov 2004 12:20:59 -0800
Message-ID: <20041115122059.4cfcd213.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Mon, 15 Nov 2004 04:46:38 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 3747] New: HTB causes machine lockups


http://bugme.osdl.org/show_bug.cgi?id=3747

           Summary: HTB causes machine lockups
    Kernel Version: 2.4.26
            Status: NEW
          Severity: high
             Owner: acme@conectiva.com.br
         Submitter: alchemyx@uznam.net.pl


Distribution: PLD Linux 1.1 with 2.4.26 vanilla kernel
Hardware Environment: 2x Xeon 2.4 GHz, 1 GB of ram, 2x e1000 NICs
Software Environment: iproute2-2.4.7.ss020116
Problem Description:

I have some network traffic shaping rules used on a Linux box. For example I
have hundreds of them on eth1. I am using HTB in all cases (sometimes attaching
SFQ to HTB rules). Everything works fine, until I issue:

tc qdisc del dev eth1 root

Which causes a machine lockup. Sometimes it happens day after day, but sometimes
once a month. There are no traces in logs, no oopses, and so on. Machine just
freezes (you see login on your screen, but can't type anything, can't ping that
machine, ctrl-alt-del or sysrq doesn't work). Problem was on kernels from 2.4.21
up to 2.4.26. Haven't tried 2.4.27 and 2.6.x on that box yet.

Steps to reproduce:
Hard to tell really. You need to set up a script creating hunderds of HTB rules
and regenerating them every (let say) 15 minutes, issuing 'tc qdisc del dev
ethX' everytime.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
