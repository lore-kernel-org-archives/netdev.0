From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8678] New: Kernel OOPSes when suspend/resume
Date: Tue, 26 Jun 2007 10:09:53 -0700
Message-ID: <20070626100953.a842b081.akpm@linux-foundation.org>
References: <bug-8678-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>, cijoml@volny.cz,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: netdev@vger.kernel.org, linux-pm@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58615 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751147AbXFZRKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2007 13:10:42 -0400
In-Reply-To: <bug-8678-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 26 Jun 2007 08:22:11 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8678
> 
>            Summary: Kernel OOPSes when suspend/resume
>            Product: Power Management
>            Version: 2.5
>      KernelVersion: 2.6.21.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Hibernation/Suspend
>         AssignedTo: power-management_other@kernel-bugs.osdl.org
>         ReportedBy: cijoml@volny.cz
> 
> 
> Most recent kernel where this bug did not occur:
> Distribution: Debian Etch
> Hardware Environment: Laptop Prestigio (Pentium M)
> Software Environment: 2.6.21.5, v4l-dvb-b03a5545f8e1
> Problem Description:
> 
> --------------
> Stopping tasks ... done.
> Shrinking memory... done (0 pages freed)
> Freed 0 kbytes in 0.02 seconds (0.00 MB/s)
> Suspending console(s)
> dvb_usb_dib0700 4-1:1.0: no suspend for driver dvb_usb_dib0700?
> eth2: Going into suspend...
> ACPI: PCI interrupt for device 0000:02:0c.0 disabled
> radeonfb (0000:01:00.0): suspending for event: 1...
> ACPI: PCI interrupt for device 0000:00:1f.6 disabled
> ACPI: PCI interrupt for device 0000:00:1f.5 disabled
> ACPI: PCI interrupt for device 0000:00:1d.7 disabled
> ACPI: PCI interrupt for device 0000:00:1d.2 disabled
> ACPI: PCI interrupt for device 0000:00:1d.1 disabled
> ACPI: PCI interrupt for device 0000:00:1d.0 disabled
> swsusp: critical section:
> swsusp: Need to copy 112337 pages
> Intel machine check architecture supported.
> Intel machine check reporting enabled on CPU#0.
> ACPI: PCI Interrupt 0000:00:1d.0[A] -> Link [LNKA] -> GSI 11 (level, low) ->
> IRQ 11
> PCI: Setting latency timer of device 0000:00:1d.0 to 64
> usb usb1: root hub lost power or was reset
> ACPI: PCI Interrupt 0000:00:1d.1[B] -> Link [LNKD] -> GSI 11 (level, low) ->
> IRQ 11
> PCI: Setting latency timer of device 0000:00:1d.1 to 64
> usb usb2: root hub lost power or was reset
> ACPI: PCI Interrupt 0000:00:1d.2[C] -> Link [LNKC] -> GSI 11 (level, low) ->
> IRQ 11
> PCI: Setting latency timer of device 0000:00:1d.2 to 64
> usb usb3: root hub lost power or was reset
> ACPI: PCI Interrupt 0000:00:1d.7[D] -> Link [LNKH] -> GSI 11 (level, low) ->
> IRQ 11
> PCI: Setting latency timer of device 0000:00:1d.7 to 64
> usb usb4: root hub lost power or was reset
> ehci_hcd 0000:00:1d.7: debug port 1
> PCI: cache line size of 32 is not supported by device 0000:00:1d.7
> PCI: Setting latency timer of device 0000:00:1e.0 to 64
> ACPI: PCI Interrupt 0000:00:1f.1[A] -> Link [LNKC] -> GSI 11 (level, low) ->
> IRQ 11
> PM: Writing back config space on device 0000:00:1f.5 at offset 1 (was 2900007,
> writing 2900003)
> ACPI: PCI Interrupt 0000:00:1f.5[B] -> Link [LNKB] -> GSI 9 (level, low) -> IRQ
> 9
> PCI: Setting latency timer of device 0000:00:1f.5 to 64
> PM: Writing back config space on device 0000:00:1f.6 at offset 1 (was 2900005,
> writing 2900001)
> ACPI: PCI Interrupt 0000:00:1f.6[B] -> Link [LNKB] -> GSI 9 (level, low) -> IRQ
> 9
> PCI: Setting latency timer of device 0000:00:1f.6 to 64
> radeonfb (0000:01:00.0): resuming from state: 1...
> ohci1394: fw-host0: OHCI-1394 1.1 (PCI): IRQ=[11]  MMIO=[ffdff800-ffdfffff] 
> Max Packet=[2048]  IR/IT contexts=[4/8]
> eth0: link down
> Yenta O2: res at 0x94/0xD4: 00/ea
> Yenta O2: enabling read prefetch/write burst
> eth2: Coming out of suspend...
> ACPI: PCI Interrupt 0000:02:0c.0[A] -> Link [LNKB] -> GSI 9 (level, low) -> IRQ
> 9
> pnp: Failed to activate device 00:03.
> pnp: Failed to activate device 00:04.
>  usbdev4.12_ep00: PM: resume from 0, parent 4-1 still 1
> dvb_usb_dib0700 4-1:1.0: PM: resume from 1, parent 4-1 still 1
> i2c_adapter i2c-5: PM: resume from 0, parent 4-1 still 1
>  usbdev4.12_ep01: PM: resume from 0, parent 4-1:1.0 still 1
>  usbdev4.12_ep81: PM: resume from 0, parent 4-1:1.0 still 1
>  usbdev4.12_ep82: PM: resume from 0, parent 4-1:1.0 still 1
>  usbdev4.12_ep83: PM: resume from 0, parent 4-1:1.0 still 1
>  usbdev4.12: PM: resume from 0, parent 4-1 still 1
>  usbdev1.8_ep00: PM: resume from 0, parent 1-2 still 1
> hci_usb 1-2:1.0: PM: resume from 1, parent 1-2 still 1
>  hci0: PM: resume from 0, parent 1-2:1.0 still 1
>  usbdev1.8_ep81: PM: resume from 0, parent 1-2:1.0 still 1
>  usbdev1.8_ep02: PM: resume from 0, parent 1-2:1.0 still 1
>  usbdev1.8_ep82: PM: resume from 0, parent 1-2:1.0 still 1
> hci_usb 1-2:1.1: PM: resume from 1, parent 1-2 still 1
>  usbdev1.8_ep03: PM: resume from 0, parent 1-2:1.1 still 1
>  usbdev1.8_ep83: PM: resume from 0, parent 1-2:1.1 still 1
>  usbdev1.8: PM: resume from 0, parent 1-2 still 1
> Restarting tasks ... done.
> __tx_submit: hci0 tx submit failed urb f22ca854 type 1 err -19
> usb 1-2: USB disconnect, address 8
> agpgart: Found an AGP 2.0 compliant device at 0000:00:00.0.
> agpgart: Putting AGP V2 device at 0000:00:00.0 into 1x mode
> agpgart: Putting AGP V2 device at 0000:01:00.0 into 1x mode
> [drm] Loading R300 Microcode
> BUG: unable to handle kernel NULL pointer dereference at virtual address
> 00000000
>  printing eip:
> c014787a
> *pde = 00000000
> Oops: 0000 [#1]
> PREEMPT
> Modules linked in: michael_mic arc4 ecb blkcipher ieee80211_crypt_tkip
> xt_TCPMSS xt_tcpmss xt_tcpudp iptable_mangle ip_tables x_table
> s ppp_deflate zlib_deflate bsd_comp ppp_async crc_ccitt ppp_generic slhc mt2060
> dvb_usb_dib0700 dib7000m dib7000p dvb_usb dvb_core di
> b3000mc dibx000_common bnep rfcomm hidp hid l2cap capability commoncap eeprom
> sr_mod sbp2 scsi_mod 8250_pci 8250 serial_core eth1394
> hci_usb bluetooth snd_intel8x0m snd_intel8x0 snd_ac97_codec snd_seq_oss
> ac97_bus snd_seq_midi_event snd_seq snd_seq_device snd_pcm_os
> s snd_mixer_oss ipw2200 8139too ieee80211 ieee80211_crypt snd_pcm snd_timer
> iTCO_wdt ehci_hcd mii ohci1394 ieee1394 rtc uhci_hcd snd
> snd_page_alloc ide_cd i2c_i801 pcspkr cdrom
> CPU:    0
> EIP:    0060:[<c014787a>]    Not tainted VLI
> EFLAGS: 00010203   (2.6.21 #4)
> EIP is at put_page+0x5/0xb2
> eax: 00000000   ebx: 00000000   ecx: c0317380   edx: f63f70c0
> esi: ea6e2680   edi: f784dd84   ebp: f784de48   esp: f784dd4c
> ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
> Process syslogd (pid: 3160, ti=f784c000 task=f7995070 task.ti=f784c000)
> Stack: 00000001 ea6e2680 f784dd84 c02aebed ea6e2680 f784df20 c02aea21 ea6e26b0
>        c02f58fb 00000036 000001ff f7ca36c0 f7dcfb00 ea6e2680 00000d1f 00000000
>        00000000 00000000 00000001 00000000 000001ff 0ac3ac80 00000036 c0317380
> Call Trace:
>  [<c02aebed>] skb_release_data+0x4e/0x80
>  [<c02aea21>] kfree_skbmem+0x8/0x61
>  [<c02f58fb>] unix_dgram_recvmsg+0x214/0x239
>  [<c02a9e24>] sock_recvmsg+0xec/0x107
>  [<c0128b23>] autoremove_wake_function+0x0/0x35
>  [<c0166775>] core_sys_select+0x1aa/0x2bc
>  [<c0160a26>] pipe_write+0x356/0x3ed
>  [<c015ae4d>] do_sync_readv_writev+0xc1/0xfe
>  [<c02aad15>] sys_recvfrom+0xd7/0x12b
>  [<c0128b23>] autoremove_wake_function+0x0/0x35
>  [<c02aada0>] sys_recv+0x37/0x3b
>  [<c02ab283>] sys_socketcall+0x19c/0x261
>  [<c0120dc5>] sigprocmask+0x94/0xb1
>  [<c0103cdc>] syscall_call+0x7/0xb
>  =======================
> Code: 42 c0 e8 66 fe ff ff 89 e0 25 00 e0 ff ff ff 48 14 8b 40 08 a8 08 74 05
> e9 18 0f 1b 00 c3 e8 b4 ff ff ff 31 c0 c3 57 56 53 89 c                        
>                                                3 <8b> 00 f6 c4 40 74 0a 89 d8
> 5b 5e 5f e9 e9 fb ff ff ff 4b 04 0f
> EIP: [<c014787a>] put_page+0x5/0xb2 SS:ESP 0068:f784dd4c

Good heavens.

Does it oops every time?  And does the oops trace always look like this?

> usb 4-1: USB disconnect, address 12
> dvb-usb: Leadtek Winfast DTV Dongle (STK7700P based) successfully deinitialized
> and disconnected.
> usb 4-1: new high speed USB device using ehci_hcd and address 14
> usb 4-1: configuration #1 chosen from 1 choice
> dvb-usb: found a 'Leadtek Winfast DTV Dongle (STK7700P based)' in cold state,
> will try to load a firmware
> dvb-usb: downloading firmware from file 'dvb-usb-dib0700-01.fw'
> dib0700: firmware started successfully.
> dvb-usb: found a 'Leadtek Winfast DTV Dongle (STK7700P based)' in warm state.
> i2c_adapter i2c-5: SMBus Quick command not supported, can't probe for chips
> dvb-usb: will pass the complete MPEG2 transport stream to the software demuxer.
> DVB: registering new adapter (Leadtek Winfast DTV Dongle (STK7700P based))
> i2c_adapter i2c-6: SMBus Quick command not supported, can't probe for chips
> DVB: registering frontend 0 (DiBcom 7000MA/MB/PA/PB/MC)...
> MT2060: successfully identified (IF1 = 1220)
> dvb-usb: Leadtek Winfast DTV Dongle (STK7700P based) successfully initialized
> and connected.
> usb 1-2: new full speed USB device using uhci_hcd and address 9
> usb 1-2: configuration #1 chosen from 1 choice
> 
> 
> ----------------
> Steps to reproduce:
> 
> suspend/resume
> 
> 
> -- 
> Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
