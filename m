From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4566] New: B44 Randomly driver starts sending
 garbage and stops receiving
Date: Sat, 30 Apr 2005 14:23:34 -0700
Message-ID: <20050430142334.4fa8745d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bonbons67@internet.lu
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Sat, 30 Apr 2005 14:04:14 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4566] New: B44 Randomly driver starts sending garbage and stops receiving


http://bugme.osdl.org/show_bug.cgi?id=4566

           Summary: B44 Randomly driver starts sending garbage and stops
                    receiving
    Kernel Version: 2.6.11
            Status: NEW
          Severity: high
             Owner: jgarzik@pobox.com
         Submitter: bonbons67@internet.lu


Distribution: Gentoo 
Hardware Environment: Acer TM66x 
    0000:02:02.0 Class 0200: 14e4:4401 (rev 01)  
        Subsystem: 1025:0035  
        Flags: bus master, fast devsel, latency 64, IRQ 10  
        Memory at e0204000 (32-bit, non-prefetchable)  
        Capabilities: [40] Power Management version 2  
    Ethernet controller: Broadcom Corporation BCM4401 100Base-T (rev 01)  
        Subsystem: Acer Incorporated [ALI]: Unknown device 0035  
        Flags: bus master, fast devsel, latency 64, IRQ 10  
        Memory at e0204000 (32-bit, non-prefetchable)  
        Capabilities: [40] Power Management version 2  
Software Environment: GCC 3.3.5-20050130  
Problem Description:  
After some time of normal network communication, suddenly incoming traffic   
stops to be received and only outgoing traffic remains.  
Looking at the traffic sent from another machine in the network with tcpdump I   
get following output (repeating at a high rate): 
22:33:01.018523 00:40:05:43:5e:fe > 01:80:c2:00:00:01, ethertype Unknown 
(0x8808), length 60: 
    0x0000: 0001 ffff 0000 0000 0000 0000 0000 0000 
    0x0010: 0000 0000 0000 0000 0000 0000 0000 0000 
    0x0020: 0000 0000 0000 0000 0000 0000 0000 
dmesg does not produce any useful output about this. 
 
ifconfig eth0 down 
ifconfig eth0 up 
Restores the communications and stops the garbage traffic. 
 
 
Steps to reproduce: 
Happens randomly, some days very often some days not at all 
 
 
I have not yet tried to disable ACPI (as suggesed in bug #3050)

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
