From: jamal <hadi@cyberus.ca>
Subject: Re: 2.6.10 - "netdev=" kernel boot commands and the Intel e1000 nic
Date: 11 Mar 2005 09:12:46 -0500
Message-ID: <1110550365.2130.28.camel@jzny.localdomain>
References: <13A26154A563124B876A26F0EF0CE1ED032C9299@HFCCINFEXCH501.AMERICAS.CORP.LOCAL>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Alex Upton <AUpton@island.com>
In-Reply-To: <13A26154A563124B876A26F0EF0CE1ED032C9299@HFCCINFEXCH501.AMERICAS.CORP.LOCAL>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


you may need to open a bug report against nameif.
btw, too long a disclaimer.

cheers,
jamal

On Fri, 2005-03-11 at 09:00, Alex Upton wrote:
> Hello All,
> 
> For about 3.5 days now I've been trying to swap eth0 and eth1 devices
> through use of the netdev kernel boot switch.
> 
> The scenario:
> 
> We have a system with onboard NICS and a PCI Intel e1000 Fiber NIC
> installed. This particular system by default forces the NIC inside the
> PCI slot to always default to eth0. We want to have ultimate control as
> to which NIC is deemed worthy enough to become eth0. We are using an
> entirely monolithic kernel via a PXE driven build and prefer not to
> support use of modules.
> 
> Reading through the kernel-parameters.txt I found the "netdev=" command
> which suggests the following usage:
> 
>   netdev=   [NET] Network devices parameters
>             Format: <irq>,<io>,<mem_start>,<mem_end>,<name>
>             Note that mem_start is often overloaded to mean
>             something different and driver-specific.
> 
> We have tried the following methods based on this info and other peoples
> examples found in google land without success.
> 
> netdev=21,0x2800,0xf6fa,0xf6fd,eth1
> netdev=21,0x2800,0xf6fa0000,0xf6fd0000,eth1
> netdev=21,0x2800,1,32,eth1
> netdev=irq=21,io=0x2800,name=eth1
> 
> We have also tried to use "nameif" as a second approach, unfortunately
> nameif seems to be limited to only having the capability to change any
> logical Ethernet device name other than eth0.
> 
> We've even attempted use of the "pci=" commands with hopes of reversing
> the PCI search order, and forced bios values, again without success.
> 
> If anyone has any suggestions or insight on how to work with netdev and
> the e1000 properly it would be greatly appreciated!
> 
> Thanks very much
> -Alex
> 
> Alex.upton@inetats.com
> 
