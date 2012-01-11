From: Bastien ROUCARIES <roucaries.bastien@gmail.com>
Subject: Fwd: Warning in wifi card
Date: Wed, 11 Jan 2012 11:04:39 +0100
Message-ID: <CAE2SPAaVtXWN+x8oaV2BkbLr6e700KizCc_39J2yp+XtWzFhXQ@mail.gmail.com>
References: <CAE2SPAbTDbGjuM6rNmjzw0X2fU_k431XkbwYuhvKtfXggOO=-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAE2SPAbTDbGjuM6rNmjzw0X2fU_k431XkbwYuhvKtfXggOO=-w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I get the following warning using 3.1 after going back to suspend to ra=
m.

Seems quite current a quick google search found
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/809777

Kernel failure message 1:
------------[ cut here ]------------
WARNING: at /home/blank/debian/kernel/release/linux-2.6/linux-2.6-3.1.6=
/debian/build/source_amd64_none/drivers/net/wireless/iwlwifi/iwl-core.c=
:1367
iwl_mac_remove_interface+0x39/0x5e [iwlagn]()
Hardware name: Dell System XPS L502X
Modules linked in: nls_utf8 nls_cp437 vfat fat pciehp pci_hotplug
mmc_block sdhci_pci sdhci mmc_core jmb38x_ms memstick dell_wmi
aesni_intel cryptd aes_x86_64 aes_generic ecb btusb ip6table_filter
ip6_tables iptable_filter ip_tables ebtable_nat ebtables x_tables cn
parport_pc ppdev lp parport acpi_cpufreq mperf cpufreq_powersave
cpufreq_conservative cpufreq_userspace bnep rfcomm cpufreq_stats
bluetooth binfmt_misc uinput fuse nfsd nfs lockd fscache auth_rpcgss
nfs_acl sunrpc coretemp loop dm_crypt kvm_intel kvm snd_hda_codec_hdmi
snd_hda_codec_realtek arc4 snd_hda_intel snd_hda_codec joydev iwlagn
uvcvideo videodev media snd_hwdep v4l2_compat_ioctl32 snd_pcm_oss
snd_mixer_oss snd_pcm snd_seq_midi snd_rawmidi snd_seq_midi_event
snd_seq nouveau ttm i915 mac80211 drm_kms_helper drm snd_timer
snd_seq_device i2c_algo_bit i2c_i801 i2c_core snd cfg80211 mxm_wmi
pcspkr battery ac sparse_keymap iTCO_wdt iTCO_vendor_support soundcore
wmi dell_laptop power_supply psmouse video evdev serio_raw dcdbas
button rfkill processor snd_page_alloc ext4 mbcache jbd2 crc16 btrfs
zlib_deflate crc32c libcrc32c dm_mod sr_mod sd_mod cdrom crc_t10dif
ahci libahci libata scsi_mod r8169 mii xhci_hcd ehci_hcd usbcore
thermal thermal_sys [last unloaded: dell_wmi]
Pid: 27387, comm: kworker/0:1 Tainted: G=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 W=C2=A0=C2=A0=C2=A0 3.1.0-1-amd64 #1
Call Trace:
=C2=A0[<ffffffff81045785>] ? warn_slowpath_common+0x78/0x8c
=C2=A0[<ffffffffa04c54f8>] ? iwl_mac_remove_interface+0x39/0x5e [iwlagn=
]
=C2=A0[<ffffffffa027dc01>] ? cfg80211_event_work+0x4/0x2c [cfg80211]
=C2=A0[<ffffffffa034f539>] ? ieee80211_do_stop+0x319/0x46a [mac80211]
=C2=A0[<ffffffff8104abe7>] ? _local_bh_enable_ip.isra.11+0x1e/0x88
=C2=A0[<ffffffffa027dc8b>] ? cfg80211_rfkill_set_block+0x62/0x62 [cfg80=
211]
=C2=A0[<ffffffffa034f69d>] ? ieee80211_stop+0x13/0x17 [mac80211]
=C2=A0[<ffffffff8126e437>] ? __dev_close_many+0x84/0xb0
=C2=A0[<ffffffff8126e532>] ? dev_close_many+0x88/0xee
=C2=A0[<ffffffff8103539b>] ? should_resched+0x5/0x23
=C2=A0[<ffffffff8127066f>] ? dev_close+0x37/0x46
=C2=A0[<ffffffffa027dc66>] ? cfg80211_rfkill_set_block+0x3d/0x62 [cfg80=
211]
=C2=A0[<ffffffff8105a74d>] ? process_one_work+0x163/0x284
=C2=A0[<ffffffff8105b715>] ? worker_thread+0xc2/0x145
=C2=A0[<ffffffff8105b653>] ? manage_workers.isra.23+0x15b/0x15b
=C2=A0[<ffffffff8105e5e5>] ? kthread+0x76/0x7e
=C2=A0[<ffffffff81334934>] ? kernel_thread_helper+0x4/0x10
=C2=A0[<ffffffff8105e56f>] ? kthread_worker_fn+0x139/0x139
=C2=A0[<ffffffff81334930>] ? gs_change+0x13/0x13
---[ end trace f03a55c4c1238b61 ]---


Bastien
