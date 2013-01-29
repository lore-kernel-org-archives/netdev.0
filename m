From: Richard Hartmann <richih.mailinglist-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: drivers/net/wireless/iwlwifi/dvm/tx.c and arch/x86/kernel/apic/ipi.c:
 Kernel trace when roaming between different Access Points with the same ESSID
Date: Tue, 29 Jan 2013 22:09:45 +0100
Message-ID: <CAD77+gQFfNvz02=0FWDq+KUGk5QO_MywWw=NBMk6YaFGNQ4+kA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

And another one; same circumstances. But this time, I got two stack
traces right behind each other.

As I got two possibly related traces, I am sending to the maintainers
of arch/x86/kernel/apic/ipi.c as well.


[ 5777.806736] ------------[ cut here ]------------
[ 5777.806745] WARNING: at
/build/buildd-linux_3.7.1-1~experimental.1-i386-Au6THQ/linux-3.7.1/arch/x86/kernel/apic/ipi.c:109
default_send_IPI_mask_logical+0x23/0x7a()
[ 5777.806746] Hardware name: 4286CTO
[ 5777.806747] empty IPI mask
[ 5777.806748] Modules linked in: parport_pc ppdev lp parport rfcomm
bnep cpufreq_userspace cpufreq_stats cpufreq_powersave
cpufreq_conservative uinput nfsd auth_rpcgss nfs_acl nfs lockd
dns_resolver fscache sunrpc ext4 jbd2 mbcache loop fuse
snd_hda_codec_hdmi coretemp snd_hda_codec_conexant arc4 iwldvm
mac80211 kvm_intel kvm iwlwifi crc32c_intel snd_hda_intel aesni_intel
snd_hda_codec snd_hwdep snd_pcm snd_page_alloc aes_i586 btusb
thinkpad_acpi snd_seq joydev cfg80211 xts nvram bluetooth
snd_seq_device snd_timer i915 rfkill snd lrw drm_kms_helper drm
i2c_algo_bit ac crc16 battery gf128mul iTCO_wdt iTCO_vendor_support
ablk_helper acpi_cpufreq mperf button video pcspkr mei soundcore
lpc_ich cryptd mfd_core i2c_i801 processor evdev psmouse i2c_core
serio_raw wmi tpm_tis tpm tpm_bios xfs sg sd_mod crc_t10dif mmc_block
xhci_hcd microcode ahci libahci sdhci_pci libata sdhci mmc_core
scsi_mod ehci_hcd usbcore usb_common e1000e thermal thermal_sys
[ 5777.806798] Pid: 4314, comm: Chrome_CacheThr Not tainted
3.7-trunk-686-pae #1 Debian 3.7.1-1~experimental.1
[ 5777.806799] Call Trace:
[ 5777.806802]  [<c10310c5>] ? warn_slowpath_common+0x68/0x79
[ 5777.806805]  [<c10238ce>] ? default_send_IPI_mask_logical+0x23/0x7a
[ 5777.806808]  [<c103113e>] ? warn_slowpath_fmt+0x29/0x2d
[ 5777.806810]  [<c10238ce>] ? default_send_IPI_mask_logical+0x23/0x7a
[ 5777.806812]  [<c102263a>] ? native_send_call_func_ipi+0x42/0x45
[ 5777.806814]  [<c106be06>] ? smp_call_function_many+0x178/0x1a8
[ 5777.806817]  [<c102d1a5>] ? do_flush_tlb_all+0x2e/0x2e
[ 5777.806819]  [<c102d22a>] ? native_flush_tlb_others+0x22/0x26
[ 5777.806821]  [<c102d11f>] ? flush_tlb_others+0x9/0xf
[ 5777.806823]  [<c102d43e>] ? flush_tlb_page+0x5b/0x60
[ 5777.806825]  [<c102c54c>] ? ptep_set_access_flags+0x44/0x4b
[ 5777.806828]  [<c10bb4dc>] ? do_wp_page+0x2ff/0x69d
[ 5777.806831]  [<c10e0d65>] ? pipe_read+0x331/0x33f
[ 5777.806832]  [<c10bd17c>] ? handle_pte_fault+0x88a/0x903
[ 5777.806834]  [<c102936e>] ? arch_flush_lazy_mmu_mode+0x5/0x13
[ 5777.806836]  [<c10bd45f>] ? handle_mm_fault+0x1e5/0x1fb
[ 5777.806840]  [<c12eb330>] ? __do_page_fault+0x350/0x38a
[ 5777.806842]  [<c10dac18>] ? do_sync_write+0x89/0x89
[ 5777.806844]  [<c100fc2e>] ? read_tsc+0xa/0x28
[ 5777.806847]  [<c1061b8a>] ? timekeeping_get_ns.constprop.10+0x10/0x56
[ 5777.806849]  [<c1050bc1>] ? should_resched+0x5/0x1e
[ 5777.806851]  [<c12e80e6>] ? _cond_resched+0x5/0x18
[ 5777.806854]  [<c117bb1a>] ? copy_to_user+0x2b/0x48
[ 5777.806856]  [<c106c032>] ? generic_smp_call_function_interrupt+0xed/0x106
[ 5777.806858]  [<c12eb36a>] ? __do_page_fault+0x38a/0x38a
[ 5777.806860]  [<c12e90af>] ? error_code+0x67/0x6c
[ 5777.806863]  [<c12e0000>] ? set_cpu_sibling_map+0x22c/0x2e5
[ 5777.806867] ---[ end trace ab21f7f1719b3f0e ]---
[ 5824.597874] iwlwifi 0000:03:00.0: fail to flush all tx fifo queues
[ 5826.603337] iwlwifi 0000:03:00.0: fail to flush all tx fifo queues
[ 5826.621539] ------------[ cut here ]------------
[ 5826.621574] WARNING: at
/build/buildd-linux_3.7.1-1~experimental.1-i386-Au6THQ/linux-3.7.1/drivers/net/wireless/iwlwifi/dvm/tx.c:1189
iwlagn_rx_reply_tx+0x288/0x6e2 [iwldvm]()
[ 5826.621578] Hardware name: 4286CTO
[ 5826.621581] Modules linked in: parport_pc ppdev lp parport rfcomm
bnep cpufreq_userspace cpufreq_stats cpufreq_powersave
cpufreq_conservative uinput nfsd auth_rpcgss nfs_acl nfs lockd
dns_resolver fscache sunrpc ext4 jbd2 mbcache loop fuse
snd_hda_codec_hdmi coretemp snd_hda_codec_conexant arc4 iwldvm
mac80211 kvm_intel kvm iwlwifi crc32c_intel snd_hda_intel aesni_intel
snd_hda_codec snd_hwdep snd_pcm snd_page_alloc aes_i586 btusb
thinkpad_acpi snd_seq joydev cfg80211 xts nvram bluetooth
snd_seq_device snd_timer i915 rfkill snd lrw drm_kms_helper drm
i2c_algo_bit ac crc16 battery gf128mul iTCO_wdt iTCO_vendor_support
ablk_helper acpi_cpufreq mperf button video pcspkr mei soundcore
lpc_ich cryptd mfd_core i2c_i801 processor evdev psmouse i2c_core
serio_raw wmi tpm_tis tpm tpm_bios xfs sg sd_mod crc_t10dif mmc_block
xhci_hcd microcode ahci libahci sdhci_pci libata sdhci mmc_core
scsi_mod ehci_hcd usbcore usb_common e1000e thermal thermal_sys
[ 5826.621732] Pid: 0, comm: swapper/0 Tainted: G        W
3.7-trunk-686-pae #1 Debian 3.7.1-1~experimental.1
[ 5826.621737] Call Trace:
[ 5826.621750]  [<c10310c5>] ? warn_slowpath_common+0x68/0x79
[ 5826.621768]  [<f86e81e2>] ? iwlagn_rx_reply_tx+0x288/0x6e2 [iwldvm]
[ 5826.621776]  [<c10310e3>] ? warn_slowpath_null+0xd/0x10
[ 5826.621790]  [<f86e81e2>] ? iwlagn_rx_reply_tx+0x288/0x6e2 [iwldvm]
[ 5826.621808]  [<f86ed344>] ? iwl_rx_dispatch+0x57/0x63 [iwldvm]
[ 5826.621822]  [<f864ad14>] ? iwl_irq_tasklet+0x39c/0x698 [iwlwifi]
[ 5826.621833]  [<c12e0b0d>] ? setup_APIC_timer+0x33/0x5e
[ 5826.621841]  [<c1037457>] ? tasklet_action+0x62/0xa5
[ 5826.621847]  [<c103711b>] ? __do_softirq+0x90/0x192
[ 5826.621854]  [<c103708b>] ? perf_trace_irq_handler_entry+0xd7/0xd7
[ 5826.621857]  <IRQ>  [<c10372cb>] ? irq_exit+0x32/0x7d
[ 5826.621872]  [<c100d070>] ? do_IRQ+0x65/0x76
[ 5826.621880]  [<c12ed2f3>] ? common_interrupt+0x33/0x38
[ 5826.621888]  [<c10300d8>] ? copy_process.part.33+0x8a8/0xf0c
[ 5826.621895]  [<c11b1c03>] ? intel_idle+0xc4/0xec
[ 5826.621905]  [<c122ea2e>] ? cpuidle_enter+0xb/0xe
[ 5826.621912]  [<c122edb9>] ? cpuidle_enter_state+0x9/0x33
[ 5826.621920]  [<c122ee8e>] ? cpuidle_idle_call+0xab/0x146
[ 5826.621927]  [<c10114d7>] ? cpu_idle+0x88/0xac
[ 5826.621935]  [<c1464966>] ? start_kernel+0x334/0x339
[ 5826.621939] ---[ end trace ab21f7f1719b3f0f ]---
[ 5826.631527] cfg80211: Calling CRDA to update world regulatory domain
[ 5826.641195] cfg80211: World regulatory domain updated:
[ 5826.641204] cfg80211:   (start_freq - end_freq @ bandwidth),
(max_antenna_gain, max_eirp)
[ 5826.641210] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz),
(300 mBi, 2000 mBm)
[ 5826.641215] cfg80211:   (2457000 KHz - 2482000 KHz @ 20000 KHz),
(300 mBi, 2000 mBm)
[ 5826.641220] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz),
(300 mBi, 2000 mBm)
[ 5826.641224] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz),
(300 mBi, 2000 mBm)
[ 5826.641229] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz),
(300 mBi, 2000 mBm)
[ 5828.636680] iwlwifi 0000:03:00.0: fail to flush all tx fifo queues
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
