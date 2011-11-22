From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: Kernel v3.0.8 igb driver dies when pulling network cable
Date: Tue, 22 Nov 2011 10:36:28 +0100
Message-ID: <4ECB6D1C.8010208@profihost.ag>
References: <4ECA4362.2050307@profihost.ag> <4ECA884C.5010706@intel.com> <4ECA936E.8060301@profihost.ag> <4ECAD3D4.4070306@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stable Tree <stable@kernel.org>, stable@vger.kernel.org,
	Greg KH <gregkh@suse.de>, LKML <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Jesse Brandeburg <jesse.brandeburg@intel.com> Bruce Allan"
	<bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4ECAD3D4.4070306@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> It would be useful if you could try the latest driver from e1000.sf.net
> just to verify  if this is a bug in the upstream kernel or if it is also
> present in our e1000.sf.net.driver.  This way we can figure out if this
> is an issue where a patch wasn't pushed into the stable kernel or if it
> is an issue that still exists in our latest release.
>
> Also could you provide us with the part number you are currently using.
> If you could provide us with the device ID for the part via lspci we can
> start narrowing down the root cause for the issue as currently we don't
> have any information about what hardware you are experiencing this issue on.

Ok another note i missed last time. Ethernet and Server stays fully 
functional - it just prints the message and resets the adapter.

OK let's start with lspci:
a:00.0 Ethernet controller: Intel Corporation Device 10c9 (rev 01)
         Subsystem: Super Micro Computer Inc Device 10c9
         Flags: bus master, fast devsel, latency 0, IRQ 28
         Memory at fbe60000 (32-bit, non-prefetchable) [size=128K]
         Memory at fbe40000 (32-bit, non-prefetchable) [size=128K]
         I/O ports at e880 [size=32]
         Memory at fbe1c000 (32-bit, non-prefetchable) [size=16K]
         Expansion ROM at fbe20000 [disabled] [size=128K]
         Capabilities: [40] Power Management version 3
         Capabilities: [50] Message Signalled Interrupts: Mask+ 64bit+ 
Queue=0/0 Enable-
         Capabilities: [70] MSI-X: Enable+ Mask- TabSize=10
         Capabilities: [a0] Express Endpoint, MSI 00
         Capabilities: [100] Advanced Error Reporting <?>
         Capabilities: [140] Device Serial Number ce-5a-2b-ff-ff-90-25-00
         Capabilities: [150] #0e
         Capabilities: [160] #10
         Kernel driver in use: igb

0a:00.1 Ethernet controller: Intel Corporation Device 10c9 (rev 01)
         Subsystem: Super Micro Computer Inc Device 10c9
         Flags: bus master, fast devsel, latency 0, IRQ 40
         Memory at fbee0000 (32-bit, non-prefetchable) [size=128K]
         Memory at fbec0000 (32-bit, non-prefetchable) [size=128K]
         I/O ports at ec00 [size=32]
         Memory at fbe9c000 (32-bit, non-prefetchable) [size=16K]
         Expansion ROM at fbea0000 [disabled] [size=128K]
         Capabilities: [40] Power Management version 3
         Capabilities: [50] Message Signalled Interrupts: Mask+ 64bit+ 
Queue=0/0 Enable-
         Capabilities: [70] MSI-X: Enable+ Mask- TabSize=10
         Capabilities: [a0] Express Endpoint, MSI 00
         Capabilities: [100] Advanced Error Reporting <?>
         Capabilities: [140] Device Serial Number ce-5a-2b-ff-ff-90-25-00
         Capabilities: [150] #0e
         Capabilities: [160] #10
         Kernel driver in use: igb

Using the latest stable igb driver from e1000.sf.net works fine without 
any message.

Thanks,

Stefan
