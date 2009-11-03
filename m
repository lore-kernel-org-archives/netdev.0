From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14450] New: [2.6.31] Network interfaces are
 dead with 2.6.31 (iwlagn and sky2)
Date: Tue, 3 Nov 2009 15:21:46 -0800
Message-ID: <20091103152146.5785195a.akpm@linux-foundation.org>
References: <bug-14450-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	linux-wireless@vger.kernel.org
To: orion.linbug@gmail.com
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <bug-14450-10286@http.bugzilla.kernel.org/>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 21 Oct 2009 07:30:12 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14450
> 
>            Summary: [2.6.31] Network interfaces are dead with 2.6.31
>                     (iwlagn and sky2)
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.31

Rafael, this is a 2.6.30->2.6.31 regression.


>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: orion.linbug@gmail.com
>         Regression: Yes
> 
> 
> My wireless and ethernet networks are dead with the kernel 2.6.31. All work
> very fine with the 2.6.30 and older. I have a Toshiba laptop wich uses the
> iwlagn module for wireless and the sky2 for ethernet. I have tested with
> acpi=off in the grub kernel line but it freezes the system on boot...
> ifconfig gets only the lo interface. ifconfig eth0 or wlan0 up gets something
> like "the interface doesn't exist".
> 
> lspci shows:
> 00:00.0 Host bridge: Intel Corporation Mobile 4 Series Chipset Memory
> Controller Hub (rev 07)                                                         
> 00:01.0 PCI bridge: Intel Corporation Mobile 4 Series Chipset PCI Express
> Graphics Port (rev 07)                                                          
> 00:1a.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI
> Controller #4 (rev 03)                                                          
> 00:1a.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI
> Controller #5 (rev 03)                                                          
> 00:1a.2 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI
> Controller #6 (rev 03)
> 00:1a.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2 EHCI
> Controller #2 (rev 03)
> 00:1b.0 Audio device: Intel Corporation 82801I (ICH9 Family) HD Audio
> Controller (rev 03)
> 00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 1
> (rev 03)
> 00:1c.1 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 2
> (rev 03)
> 00:1c.3 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 4
> (rev 03)
> 00:1d.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI
> Controller #1 (rev 03)
> 00:1d.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI
> Controller #2 (rev 03)
> 00:1d.2 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI
> Controller #3 (rev 03)
> 00:1d.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2 EHCI
> Controller #1 (rev 03)
> 00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev 93)
> 00:1f.0 ISA bridge: Intel Corporation ICH9M LPC Interface Controller (rev 03)
> 00:1f.2 SATA controller: Intel Corporation ICH9M/M-E SATA AHCI Controller (rev
> 03)
> 00:1f.3 SMBus: Intel Corporation 82801I (ICH9 Family) SMBus Controller (rev 03)
> 01:00.0 VGA compatible controller: ATI Technologies Inc M92 [Mobility Radeon HD
> 4500 Series]
> 01:00.1 Audio device: ATI Technologies Inc R700 Audio Device [Radeon HD 4000
> Series]
> 02:00.0 Network controller: Intel Corporation Wireless WiFi Link 5100
> 03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8040T PCI-E Fast
> Ethernet Controller (rev 12)
> 0a:01.0 FireWire (IEEE 1394): O2 Micro, Inc. Firewire (IEEE 1394) (rev 02)
> 0a:01.2 SD Host controller: O2 Micro, Inc. Integrated MMC/SD Controller (rev
> 02)
> 0a:01.3 Mass storage controller: O2 Micro, Inc. Integrated MS/xD Controller
> (rev 01)
> 
> Dmesg shows errors on sky2 and iwlagn driver:
> iwlagn: Intel(R) Wireless WiFi Link AGN driver for Linux, 1.3.27ks2009-10-13
> 17:57:36
> iwlagn: Copyright(c) 2003-2009 Intel Corporation2009-10-13 17:57:36
> iwlagn 0000:02:00.0: enabling device (0000 -> 0002)2009-10-13 17:57:36    
> iwlagn 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 162009-10-13
> 17:57:36
> iwlagn 0000:02:00.0: Detected Intel Wireless WiFi Link 5100AGN
> REV=0xFFFFFFFF2009-10-13 17:57:36
> Clocksource tsc unstable (delta = -212055894 ns)2009-10-13 17:57:36
> iwlagn 0000:02:00.0: Failed, HW not ready2009-10-13 17:57:36
> iwlagn 0000:02:00.0: PCI INT A disabled2009-10-13 17:57:36
> 
> sky2 driver version 1.232009-10-13 17:50:48
> sky2 0000:03:00.0: enabling device (0000 -> 0003)2009-10-13 17:50:48
> sky2 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 172009-10-13
> 17:50:48
> sky2 0000:03:00.0: PCI INT A disabled2009-10-13 17:50:48
> sky2: probe of 0000:03:00.0 failed with error -952009-10-13 17:50:48

Given that both the wired and wireless interfaces failed, I'd assume
that something went wrong at the bus level.  Perhaps due to an ACPI
change.

Could the sky2, iwlagn and ACPI developers please take a look, offer an
opinion as to where we should be looking?

Thanks.

