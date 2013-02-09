From: Richard Hartmann <richih.mailinglist@gmail.com>
Subject: Re: drivers/net/wireless/iwlwifi/dvm/tx.c and arch/x86/kernel/apic/ipi.c:
 Kernel trace when roaming between different Access Points with the same ESSID
Date: Sat, 9 Feb 2013 20:57:36 +0100
Message-ID: <CAD77+gTFDbNopgJjMv+BGJCbueR-k8Uiyq41DfOeF_t1oJm7EA@mail.gmail.com>
References: <CAD77+gQFfNvz02=0FWDq+KUGk5QO_MywWw=NBMk6YaFGNQ4+kA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Johannes Berg <johannes.berg@intel.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com,
	hpa@zytor.com, x86@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAD77+gQFfNvz02=0FWDq+KUGk5QO_MywWw=NBMk6YaFGNQ4+kA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yet another one, this time during high USB i/o load.

Could this be a hardware issue as well?

Does it still make sense to send these reports to anyone?


[95553.449219] ------------[ cut here ]------------
[95553.449257] WARNING: at
/build/buildd-linux_3.7.1-1~experimental.1-i386-Au6THQ/linux-3.7.1/drivers/net/wireless/iwlwifi/dvm/tx.c:1189
iwlagn_rx_reply_tx+0x288/0x6e2 [iwldvm]()
[95553.449262] Hardware name: 4286CTO
[95553.449265] Modules linked in: nls_utf8 nls_cp437 vfat fat
mmc_block usb_storage parport_pc ppdev rfcomm lp parport bnep
cpufreq_userspace cpufreq_stats cpufreq_powersave cpufreq_conservative
uinput nfsd auth_rpcgss nfs_acl nfs lockd dns_resolver fscache sunrpc
ext4 jbd2 mbcache loop fuse snd_hda_codec_hdmi snd_hda_codec_conexant
arc4 coretemp iwldvm mac80211 kvm_intel snd_hda_intel thinkpad_acpi
snd_hda_codec nvram snd_hwdep snd_pcm snd_page_alloc kvm i915
drm_kms_helper crc32c_intel joydev drm i2c_algo_bit snd_seq btusb
bluetooth iTCO_wdt snd_seq_device snd_timer aesni_intel aes_i586 crc16
iwlwifi iTCO_vendor_support xts lrw i2c_i801 pcspkr snd gf128mul
i2c_core ablk_helper cryptd soundcore lpc_ich mfd_core cfg80211
psmouse serio_raw acpi_cpufreq mperf mei rfkill ac wmi battery tpm_tis
tpm evdev processor tpm_bios button video xfs sg sd_mod crc_t10dif
xhci_hcd ahci libahci libata microcode scsi_mod ehci_hcd sdhci_pci
sdhci mmc_core usbcore usb_common e1000e thermal thermal_sys
[95553.449427] Pid: 0, comm: swapper/0 Tainted: G        W
3.7-trunk-686-pae #1 Debian 3.7.1-1~experimental.1
[95553.449431] Call Trace:
[95553.449446]  [<c10310c5>] ? warn_slowpath_common+0x68/0x79
[95553.449464]  [<f87291e2>] ? iwlagn_rx_reply_tx+0x288/0x6e2 [iwldvm]
[95553.449472]  [<c10310e3>] ? warn_slowpath_null+0xd/0x10
[95553.449487]  [<f87291e2>] ? iwlagn_rx_reply_tx+0x288/0x6e2 [iwldvm]
[95553.449502]  [<f859008b>] ? check_event_type_and_length+0x37/0x4b [snd_seq]
[95553.449520]  [<f872e344>] ? iwl_rx_dispatch+0x57/0x63 [iwldvm]
[95553.449537]  [<f859fd14>] ? iwl_irq_tasklet+0x39c/0x698 [iwlwifi]
[95553.449546]  [<c1037457>] ? tasklet_action+0x62/0xa5
[95553.449552]  [<c103711b>] ? __do_softirq+0x90/0x192
[95553.449559]  [<c103708b>] ? perf_trace_irq_handler_entry+0xd7/0xd7
[95553.449563]  <IRQ>  [<c10372cb>] ? irq_exit+0x32/0x7d
[95553.449577]  [<c100d070>] ? do_IRQ+0x65/0x76
[95553.449586]  [<c12ed2f3>] ? common_interrupt+0x33/0x38
[95553.449593]  [<c10300d8>] ? copy_process.part.33+0x8a8/0xf0c
[95553.449602]  [<c11b1c03>] ? intel_idle+0xc4/0xec
[95553.449612]  [<c122ea2e>] ? cpuidle_enter+0xb/0xe
[95553.449619]  [<c122edb9>] ? cpuidle_enter_state+0x9/0x33
[95553.449626]  [<c122ee8e>] ? cpuidle_idle_call+0xab/0x146
[95553.449634]  [<c10114d7>] ? cpu_idle+0x88/0xac
[95553.449641]  [<c1464966>] ? start_kernel+0x334/0x339
[95553.449646] ---[ end trace e2ce8294be2c8dca ]---

-- 
Richard
