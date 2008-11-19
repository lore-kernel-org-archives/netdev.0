From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: next-20081117: kernel freezes with netconsole enabled
Date: Wed, 19 Nov 2008 21:26:53 +0300
Message-ID: <20081119182653.GA24538@ioremap.net>
References: <20081119175740.GE12456@orion> <20081119182112.GA23891@ioremap.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="BOKacYhQ+x31HxR3"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, mpm@selenic.com, satyam.sharma@gmail.com
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081119182112.GA23891@ioremap.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Attached full log from different machine.

On Wed, Nov 19, 2008 at 09:21:12PM +0300, Evgeniy Polyakov (zbr@ioremap.net) wrote:
> Hi.
> 
> On Wed, Nov 19, 2008 at 08:57:40PM +0300, Alexander Beregalov (a.beregalov@gmail.com) wrote:
> > It is x86_64 SMP
> 
> I have it at 32bit.
> 
> > The kernel freezes while transferring kernel log through netconsole,
> > SysRq does not work at that moment.
> 
> Do not know if it related or not, but I have similar problem,
> kernel is very much tainted by POHMELFS code though.
> 
> Attached picture of the end of the dump.

-- 
	Evgeniy Polyakov

--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="mars_kern_poh.log"

------------[ cut here ]------------
WARNING: at kernel/softirq.c:138 local_bh_enable+0x6c/0x90()
Modules linked in: pohmelfs cn netconsole acpi_cpufreq kvm_intel kvm nfsd auth_rpcgss exportfs nfs lockd sunrpc twofish twofish_common serpent blowfish aes_i586 aes_generic xcbc sha256_generic crypto_null af_key dm_snapshot dm_mirror dm_region_hash dm_log coretemp w83627ehf hwmon_vid joydev sg usbhid gspca_spca561 gspca_main snd_hda_intel snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd ata_piix pata_jmicron ahci i2c_i801 soundcore r8169 snd_page_alloc mii ehci_hcd uhci_hcd usbcore [last unloaded: pcspkr]
Pid: 219, comm: pdflush Not tainted 2.6.28-rc5.1b-00261-g8173027-dirty #7
Call Trace:
 [<c012606f>] warn_on_slowpath+0x5f/0x90
BUG: unable to handle kernel NULL pointer dereference at 00000093
IP: [<c011d3be>] update_curr+0x6e/0xc0
*pdpt = 00000000342ca001 *pde = 0000000000000000 
Oops: 0000 [#1] SMP 
last sysfs file: /sys/devices/system/cpu/cpu1/cache/index2/shared_cpu_map
Modules linked in: pohmelfs cn netconsole acpi_cpufreq kvm_intel kvm nfsd auth_rpcgss exportfs nfs lockd sunrpc twofish twofish_common serpent blowfish aes_i586 aes_generic xcbc sha256_generic crypto_null af_key dm_snapshot dm_mirror dm_region_hash dm_log coretemp w83627ehf hwmon_vid joydev sg usbhid gspca_spca561 gspca_main snd_hda_intel snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd ata_piix pata_jmicron ahci i2c_i801 soundcore r8169 snd_page_alloc mii ehci_hcd uhci_hcd usbcore [last unloaded: pcspkr]

Pid: 219, comm: pdflush Not tainted (2.6.28-rc5.1b-00261-g8173027-dirty #7) System Product Name
EIP: 0060:[<c011d3be>] EFLAGS: 00010086 CPU: 1
EIP is at update_curr+0x6e/0xc0
EAX: ffffffff EBX: cccccccc ECX: 7ffffffe EDX: cccccccc
ESI: cccccccd EDI: 00000000 EBP: c04929fc ESP: f74f4dd0
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process pdflush (pid: 219, ti=f74f4000 task=f7505130 task.ti=f74f5000)
Stack:
 cccccccc cccccccc cccccccd c04929fc f750515c 00000010 c401e9c0 c0122fed
 c035fec0 00000400 c01239ef f7505130 00000001 00000001 00000000 f7505130
 c401b500 c012f74a 00000001 b3a0ed51 0000003d c0143707 00000000 00000086
Call Trace:
 [<c0122fed>] task_tick_fair+0x2d/0x70
 [<c01239ef>] scheduler_tick+0x8f/0x190
 [<c012f74a>] update_process_times+0x4a/0x60
 [<c0143707>] tick_nohz_handler+0x77/0xe0
 [<c0113933>] smp_apic_timer_interrupt+0x53/0x90
 [<c0103f30>] apic_timer_interrupt+0x28/0x30
 [<c0126b2b>] vprintk+0x13b/0x310
 [<c012679e>] release_console_sem+0x19e/0x1d0
 [<c013c9c1>] up+0x11/0x40
 [<c0126d1b>] printk+0x1b/0x20
 [<c0105bba>] printk_address+0x2a/0x30
 [<c012606f>] warn_on_slowpath+0x5f/0x90
 [<c012606f>] warn_on_slowpath+0x5f/0x90
 [<c0105d9f>] dump_trace+0x4f/0x100
 [<c0105e9b>] show_trace_log_lvl+0x4b/0x60
 [<c01063f8>] show_trace+0x18/0x20
 [<c01064bd>] dump_stack+0x6d/0x80
 [<c012606f>] warn_on_slowpath+0x5f/0x90
 [<c01090e8>] nommu_map_single+0x38/0x80
 [<c01090b0>] nommu_map_single+0x0/0x80
 [<f82935eb>] rtl8169_start_xmit+0x1db/0x3b0 [r8169]
Code: 3b 00 04 00 00 75 53 01 43 30 89 e8 11 53 34 e8 f9 f2 ff ff 8b 04 24 8b 54 24 04 89 43 20 8b 83 74 02 00 00 89 53 24 85 c0 74 1b <8b> 90 94 00 00 00 85 d2 74 11 f7 d2 64 a1 04 e0 48 c0 8b 04 82 
EIP: [<c011d3be>] update_curr+0x6e/0xc0 SS:ESP 0068:f74f4dd0
Kernel panic - not syncing: Fatal exception in interrupt
------------[ cut here ]------------
WARNING: at kernel/smp.c:333 smp_call_function_mask+0x1b5/0x1c0()
Modules linked in: pohmelfs cn netconsole acpi_cpufreq kvm_intel kvm nfsd auth_rpcgss exportfs nfs lockd sunrpc twofish twofish_common serpent blowfish aes_i586 aes_generic xcbc sha256_generic crypto_null af_key dm_snapshot dm_mirror dm_region_hash dm_log coretemp w83627ehf hwmon_vid joydev sg usbhid gspca_spca561 gspca_main snd_hda_intel snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd ata_piix pata_jmicron ahci i2c_i801 soundcore r8169 snd_page_alloc mii ehci_hcd uhci_hcd usbcore [last unloaded: pcspkr]
Pid: 219, comm: pdflush Tainted: G      D    2.6.28-rc5.1b-00261-g8173027-dirty #7
Call Trace:
 [<c012606f>] warn_on_slowpath+0x5f/0x90
 [<f82935eb>] rtl8169_start_xmit+0x1db/0x3b0 [r8169]
 [<c02ff01c>] find_skb+0x3c/0x80
 [<f87420ac>] write_msg+0x8c/0xc0 [netconsole]
 [<f8742020>] write_msg+0x0/0xc0 [netconsole]
 [<c01262a3>] __call_console_drivers+0x53/0x60
 [<c013c9c1>] up+0x11/0x40
 [<c012679e>] release_console_sem+0x19e/0x1d0
 [<c0146af5>] smp_call_function_mask+0x1b5/0x1c0
 [<c01124c0>] stop_this_cpu+0x0/0x40
 [<c0126d1b>] printk+0x1b/0x20
 [<c010600e>] show_registers+0x7e/0x1c0
 [<c0146b14>] smp_call_function+0x14/0x20
 [<c011254e>] native_smp_send_stop+0x1e/0x30
 [<c01260fe>] panic+0x4e/0xf0
 [<c0105c7d>] oops_end+0x7d/0x90
 [<c0118376>] do_page_fault+0x4f6/0x860
 [<c012606f>] warn_on_slowpath+0x5f/0x90
 [<c0117e80>] do_page_fault+0x0/0x860
 [<c0357672>] error_code+0x72/0x78
 [<c011d3be>] update_curr+0x6e/0xc0
 [<c0122fed>] task_tick_fair+0x2d/0x70
 [<c01239ef>] scheduler_tick+0x8f/0x190
 [<c012f74a>] update_process_times+0x4a/0x60
 [<c0143707>] tick_nohz_handler+0x77/0xe0
 [<c0113933>] smp_apic_timer_interrupt+0x53/0x90
 [<c0103f30>] apic_timer_interrupt+0x28/0x30
 [<c0126b2b>] vprintk+0x13b/0x310
 [<c012679e>] release_console_sem+0x19e/0x1d0
 [<c013c9c1>] up+0x11/0x40
 [<c0126d1b>] printk+0x1b/0x20
 [<c0105bba>] printk_address+0x2a/0x30
 [<c012606f>] warn_on_slowpath+0x5f/0x90
 [<c012606f>] warn_on_slowpath+0x5f/0x90
 [<c0105d9f>] dump_trace+0x4f/0x100
 [<c0105e9b>] show_trace_log_lvl+0x4b/0x60
 [<c01063f8>] show_trace+0x18/0x20
 [<c01064bd>] dump_stack+0x6d/0x80
 [<c012606f>] warn_on_slowpath+0x5f/0x90
 [<c01090e8>] nommu_map_single+0x38/0x80
 [<c01090b0>] nommu_map_single+0x0/0x80
 [<f82935eb>] rtl8169_start_xmit+0x1db/0x3b0 [r8169]
---[ end trace 81c8f69a4224ff41 ]---
------------[ cut here ]------------
WARNING: at kernel/smp.c:220 smp_call_function_single+0xb7/0xc0()
Modules linked in: pohmelfs cn netconsole acpi_cpufreq kvm_intel kvm nfsd auth_rpcgss exportfs nfs lockd sunrpc twofish twofish_common serpent blowfish aes_i586 aes_generic xcbc sha256_generic crypto_null af_key dm_snapshot dm_mirror dm_region_hash dm_log coretemp w83627ehf hwmon_vid joydev sg usbhid gspca_spca561 gspca_main snd_hda_intel snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd ata_piix pata_jmicron ahci i2c_i801 soundcore r8169 snd_page_alloc mii ehci_hcd uhci_hcd usbcore [last unloaded: pcspkr]
Pid: 219, comm: pdflush Tainted: G      D W  2.6.28-rc5.1b-00261-g8173027-dirty #7
Call Trace:
 [<c012606f>] warn_on_slowpath+0x5f/0x90
 [<f82935eb>] rtl8169_start_xmit+0x1db/0x3b0 [r8169]
 [<c02ff01c>] find_skb+0x3c/0x80
 [<f87420ac>] write_msg+0x8c/0xc0 [netconsole]
 [<f8742020>] write_msg+0x0/0xc0 [netconsole]
 [<c0146937>] smp_call_function_single+0xb7/0xc0
 [<c012679e>] release_console_sem+0x19e/0x1d0
 [<c0146a9a>] smp_call_function_mask+0x15a/0x1c0
 [<c01124c0>] stop_this_cpu+0x0/0x40
 [<c0126d1b>] printk+0x1b/0x20
 [<c010600e>] show_registers+0x7e/0x1c0
 [<c0146b14>] smp_call_function+0x14/0x20
 [<c011254e>] native_smp_send_stop+0x1e/0x30
 [<c01260fe>] panic+0x4e/0xf0
 [<c0105c7d>] oops_end+0x7d/0x90
 [<c0118376>] do_page_fault+0x4f6/0x860
 [<c012606f>] warn_on_slowpath+0x5f/0x90
 [<c0117e80>] do_page_fault+0x0/0x860
 [<c0357672>] error_code+0x72/0x78
 [<c011d3be>] update_curr+0x6e/0xc0
 [<c0122fed>] task_tick_fair+0x2d/0x70
 [<c01239ef>] scheduler_tick+0x8f/0x190
 [<c012f74a>] update_process_times+0x4a/0x60
 [<c0143707>] tick_nohz_handler+0x77/0xe0
 [<c0113933>] smp_apic_timer_interrupt+0x53/0x90
 [<c0103f30>] apic_timer_interrupt+0x28/0x30
 [<c0126b2b>] vprintk+0x13b/0x310
 [<c012679e>] release_console_sem+0x19e/0x1d0
 [<c013c9c1>] up+0x11/0x40
 [<c0126d1b>] printk+0x1b/0x20
 [<c0105bba>] printk_address+0x2a/0x30
 [<c012606f>] warn_on_slowpath+0x5f/0x90
 [<c012606f>] warn_on_slowpath+0x5f/0x90
 [<c0105d9f>] dump_trace+0x4f/0x100
 [<c0105e9b>] show_trace_log_lvl+0x4b/0x60
 [<c01063f8>] show_trace+0x18/0x20
 [<c01064bd>] dump_stack+0x6d/0x80
 [<c012606f>] warn_on_slowpath+0x5f/0x90
 [<c01090e8>] nommu_map_single+0x38/0x80
 [<c01090b0>] nommu_map_single+0x0/0x80
 [<f82935eb>] rtl8169_start_xmit+0x1db/0x3b0 [r8169]
---[ end trace 81c8f69a4224ff41 ]---

--BOKacYhQ+x31HxR3--
