From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 3765] New: Network link down, when writting to
 sata disk AND network in use
Date: Wed, 17 Nov 2004 21:18:22 -0800
Message-ID: <20041117211822.243aa8bd.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugtracker@surasoft.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Well this is novel.  I'd be suspecting a hardware problem.  Are you sure
the power supply isn't overloaded, or in need of replacement?


Begin forwarded message:

Date: Wed, 17 Nov 2004 21:13:36 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 3765] New: Network link down, when writting to sata disk AND network in use


http://bugme.osdl.org/show_bug.cgi?id=3765

           Summary: Network link down, when writting to sata disk AND
                    network in use
    Kernel Version: linux-kernel 2.6.9
            Status: NEW
          Severity: high
             Owner: other_other@kernel-bugs.osdl.org
         Submitter: bugtracker@surasoft.com


Distribution: Gentoo

Hardware Environment: 
P4 2.66ghz
Motherboard: ASUS P4PE (with onboard lan)
Promise Sata150 TX4 PCI (sata expansion card)

Software Environment: 
Kernel 2.6.9
- onboard LAN: driver in use
- "Broadcom 4400 ethernet support" compiled into kernel

- Promise Sata150 TX4 PCI (sata expansion card)
- Driver "Promise SATA TX2/TX4 support" compiled into kernel
- 200GB Western Digital SATA drive attached to PCI sata card

Problem Description:
If data is being copied to the SATA drive (eg from another DISK which is on
motherboard IDE controller) AND I start a network data transfer where data is
goung through the Broadcom lan the following occurs (from kernel log)

Nov 18 11:43:10 synapse b44: eth0: Link is down.
Nov 18 11:43:15 synapse b44: eth0: Link is up at 100 Mbps, full duplex.
Nov 18 11:43:15 synapse b44: eth0: Flow control is on for TX and on for RX.
Nov 18 11:43:19 synapse b44: eth0: Link is down.
Nov 18 11:43:21 synapse b44: eth0: Link is up at 100 Mbps, full duplex. 

Link keeps going up and down, as long as there's data movment from the SATA
drive, and a network movement (network download doesn't have to be saving to the
 sata drive)

I've disabled APCI, problem persits.

Steps to reproduce:
1. copy data to Sata drive CONNECTED to PCI controller
2. Download file from network via onboard LAN, doesn't matter which drive you
save it
3. Onboards lan "link" goes up and down, causing disruption to network useage.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
