From: "Alex Upton" <AUpton@island.com>
Subject: 2.6.10 - "netdev=" kernel boot commands and the Intel e1000 nic
Date: Fri, 11 Mar 2005 09:00:50 -0500
Message-ID: <13A26154A563124B876A26F0EF0CE1ED032C9299@HFCCINFEXCH501.AMERICAS.CORP.LOCAL>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8bit
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello All,

For about 3.5 days now I've been trying to swap eth0 and eth1 devices
through use of the netdev kernel boot switch.

The scenario:

We have a system with onboard NICS and a PCI Intel e1000 Fiber NIC
installed. This particular system by default forces the NIC inside the
PCI slot to always default to eth0. We want to have ultimate control as
to which NIC is deemed worthy enough to become eth0. We are using an
entirely monolithic kernel via a PXE driven build and prefer not to
support use of modules.

Reading through the kernel-parameters.txt I found the "netdev=" command
which suggests the following usage:

  netdev=   [NET] Network devices parameters
            Format: <irq>,<io>,<mem_start>,<mem_end>,<name>
            Note that mem_start is often overloaded to mean
            something different and driver-specific.

We have tried the following methods based on this info and other peoples
examples found in google land without success.

netdev=21,0x2800,0xf6fa,0xf6fd,eth1
netdev=21,0x2800,0xf6fa0000,0xf6fd0000,eth1
netdev=21,0x2800,1,32,eth1
netdev=irq=21,io=0x2800,name=eth1

We have also tried to use "nameif" as a second approach, unfortunately
nameif seems to be limited to only having the capability to change any
logical Ethernet device name other than eth0.

We've even attempted use of the "pci=" commands with hopes of reversing
the PCI search order, and forced bios values, again without success.

If anyone has any suggestions or insight on how to work with netdev and
the e1000 properly it would be greatly appreciated!

Thanks very much
-Alex

Alex.upton@inetats.com




*****************************************************************
<<<Disclaimer>>>

In compliance with applicable rules and regulations, Instinet
reviews and archives incoming and outgoing email communications,
copies of which may be produced at the request of regulators.
This message is intended only for the personal and confidential
use of the recipients named above.  If the reader of this email
is not the intended recipient, you have received this email in
error and any review, dissemination, distribution or copying is
strictly prohibited. If you have received this email in error,
please notify the sender immediately by return email and
permanently delete the copy you received.  

Instinet accepts no liability for any content contained in the
email, or any errors or omissions arising as a result of email
transmission. Any opinions contained in this email constitute
the sender's best judgment at this time and are subject to change
without notice.   Instinet does not make recommendations of a
particular security and the information contained in this email
should not be considered as a recommendation, an offer or a
solicitation of an offer to buy and sell securities.

*****************************************************************
