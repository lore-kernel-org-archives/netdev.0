From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13803] New: hso: Tx timed out.
Date: Thu, 23 Jul 2009 15:43:37 -0700
Message-ID: <20090723154337.709ca0cd.akpm@linux-foundation.org>
References: <bug-13803-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, Jan Dumon <j.dumon@option.com>,
	fabo@debian.org
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34381 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753940AbZGWWoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 18:44:16 -0400
In-Reply-To: <bug-13803-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

(argh at the wordwrapping - I'm trying to get bugzilla fixed but
appatently it's tricky).


On Mon, 20 Jul 2009 15:02:09 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13803
> 
>            Summary: hso: Tx timed out.
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.30
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: USB
>         AssignedTo: greg@kroah.com
>         ReportedBy: fabo@debian.org
>         Regression: No
> 
> 
> I've got the following issue using Option GlobeTrotter GTM382 (device id
> 0af0:7601) with 2.6.29 and 2.6.30 kernels:
> Jul 20 15:35:18 os kernel: [ 1722.322633] WARNING: at
> /tmp/buildd/linux-2.6-2.6.30/debian/build/source_i386_none/net/sched/sch_generic.c:226
> dev_watchdog+0xa8/0x135()
> Jul 20 15:35:18 os kernel: [ 1722.326745] Hardware name: No System Name
> Jul 20 15:35:18 os kernel: [ 1722.330797] NETDEV WATCHDOG: hso0 (hso): transmit
> timed out
> Jul 20 15:35:18 os kernel: [ 1722.333567] Modules linked in: nfsd nfs lockd
> fscache nfs_acl auth_rpcgss sunrpc hso rfkill snd_pcsp snd_pcm psmouse
> snd_timer via686a snd evdev serio_raw soundcore snd_page_alloc ipw2200
> i2c_viapro parport_pc i2c_core parport shpchp efficeon_agp libipw pci_hotplug
> lib80211 agpgart usb_storage uhci_hcd sd_mod crc_t10dif squashfs loop aufs
> exportfs ext3 jbd mbcache ide_gd_mod ata_generic libata scsi_mod ohci_hcd
> ehci_hcd usbcore e100 mii via82cxxx thermal_sys ide_pci_generic ide_core
> Jul 20 15:35:18 os kernel: [ 1722.442859] Pid: 0, comm: swapper Not tainted
> 2.6.30-itlabs.1-686 #1
> Jul 20 15:35:18 os kernel: [ 1722.444389] Call Trace:
> Jul 20 15:35:18 os kernel: [ 1722.446154]  [<c012703c>] ?
> warn_slowpath_common+0x5e/0x8a
> Jul 20 15:35:18 os kernel: [ 1722.447747]  [<c029efd0>] ?
> dev_watchdog+0x0/0x135
> Jul 20 15:35:18 os kernel: [ 1722.449308]  [<c012709a>] ?
> warn_slowpath_fmt+0x26/0x2a
> Jul 20 15:35:18 os kernel: [ 1722.451439]  [<c029f078>] ?
> dev_watchdog+0xa8/0x135
> Jul 20 15:35:18 os kernel: [ 1722.453260]  [<c0133da1>] ? insert_work+0x71/0x78
> Jul 20 15:35:18 os kernel: [ 1722.454854]  [<c01343b9>] ?
> delayed_work_timer_fn+0x0/0x28
> Jul 20 15:35:18 os kernel: [ 1722.456769]  [<c012e3f3>] ?
> run_timer_softirq+0x13d/0x19d
> Jul 20 15:35:18 os kernel: [ 1722.458617]  [<c029efd0>] ?
> dev_watchdog+0x0/0x135
> Jul 20 15:35:18 os kernel: [ 1722.460382]  [<c012b137>] ?
> __do_softirq+0x8e/0x135
> Jul 20 15:35:18 os kernel: [ 1722.461956]  [<c012b20c>] ? do_softirq+0x2e/0x38
> Jul 20 15:35:18 os kernel: [ 1722.463503]  [<c012b2ef>] ? irq_exit+0x26/0x53
> Jul 20 15:35:18 os kernel: [ 1722.465293]  [<c01049ea>] ? do_IRQ+0x65/0x76
> Jul 20 15:35:18 os kernel: [ 1722.467446]  [<c01036c9>] ?
> common_interrupt+0x29/0x30
> Jul 20 15:35:18 os kernel: [ 1722.470343]  [<c011642c>] ?
> native_safe_halt+0x2/0x3
> Jul 20 15:35:18 os kernel: [ 1722.472337]  [<c010895e>] ?
> default_idle+0x41/0x6a
> Jul 20 15:35:18 os kernel: [ 1722.473985]  [<c010239a>] ? cpu_idle+0x46/0x60
> Jul 20 15:35:18 os kernel: [ 1722.475527]  [<c044476d>] ?
> start_kernel+0x2c2/0x2c5
> Jul 20 15:35:18 os kernel: [ 1722.477061] ---[ end trace 489bf763e8487f0a ]---
> Jul 20 15:35:18 os kernel: [ 1722.478618] net hso0: Tx timed out.
> Jul 20 15:35:38 os kernel: [ 1742.321537] net hso0: Tx timed out.
> Jul 20 15:35:58 os kernel: [ 1762.325396] net hso0: Tx timed out.
> Jul 20 15:36:18 os kernel: [ 1782.329539] net hso0: Tx timed out.
> Jul 20 15:36:38 os kernel: [ 1802.332445] net hso0: Tx timed out.
> Jul 20 15:36:58 os kernel: [ 1822.336094] net hso0: Tx timed out.
> Jul 20 15:37:18 os kernel: [ 1842.339743] net hso0: Tx timed out.
> Jul 20 15:37:38 os kernel: [ 1862.343416] net hso0: Tx timed out.
> Jul 20 15:37:58 os kernel: [ 1882.347041] net hso0: Tx timed out.
> etc...


