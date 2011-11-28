From: Udo Steinberg <udo@hypervisor.org>
Subject: iwlagn failed resume from S3
Date: Mon, 28 Nov 2011 15:14:06 +0100
Message-ID: <20111128151406.51282c25@x220.fritz.box>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/LAST2wjIhA==0GSWBra__7o"; protocol="application/pgp-signature"
Cc: Linux Network Mailing List <netdev@vger.kernel.org>,
	linux-wireless@vger.kernel.org
To: "Guy, Wey-Yi" <wey-yi.w.guy@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/LAST2wjIhA==0GSWBra__7o
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi,

After coming out of Suspend-to-RAM with Linux-3.1.0, the Centrino Advanced-N
6205 WiFi failed to resume with the following warnings in dmesg. So far this
has happened just once and it's not easily reproducible.

Cheers,

	- Udo

iwlagn 0000:03:00.0: restoring config space at offset 0xf (was 0x100, writi=
ng 0x1ff)
iwlagn 0000:03:00.0: restoring config space at offset 0x4 (was 0x4, writing=
 0xf2500004)
iwlagn 0000:03:00.0: restoring config space at offset 0x3 (was 0x0, writing=
 0x10)
iwlagn 0000:03:00.0: L1 Disabled; Enabling L0S
iwlagn 0000:03:00.0: Radio type=3D0x1-0x2-0x0
------------[ cut here ]------------
WARNING: at drivers/net/wireless/iwlwifi/iwl-trans-tx-pcie.c:765 iwl_tx_cmd=
_complete+0xa4/0x335 [iwlagn]()
Hardware name: 4290W4H
wrong command queue 2 (should be 9), sequence 0x2FA readp=3D0 writep=3D0
Modules linked in: iwlagn
Pid: 0, comm: swapper Not tainted 3.1.0 #1
Call Trace:
 <IRQ>  [<ffffffff81036e2d>] ? warn_slowpath_common+0x78/0x8c
 [<ffffffff81036ee2>] ? warn_slowpath_fmt+0x45/0x4a
 [<ffffffffa0027199>] ? iwl_tx_cmd_complete+0xa4/0x335 [iwlagn]
 [<ffffffffa001c15c>] ? iwl_rx_dispatch+0x147/0x20f [iwlagn]
 [<ffffffffa00251d0>] ? iwl_irq_tasklet+0x7c9/0xb52 [iwlagn]
 [<ffffffffa0025fc3>] ? iwl_isr_ict+0x563/0x628 [iwlagn]
 [<ffffffff8103b439>] ? tasklet_action+0x67/0xa7
 [<ffffffff8103b95b>] ? __do_softirq+0x7f/0x106
 [<ffffffff813c10ec>] ? call_softirq+0x1c/0x26
 [<ffffffff8100351e>] ? do_softirq+0x31/0x67
 [<ffffffff8103bc0f>] ? irq_exit+0x44/0xb0
 [<ffffffff8100325f>] ? do_IRQ+0x94/0xad
 [<ffffffff813bf62b>] ? common_interrupt+0x6b/0x6b
 <EOI>  [<ffffffff8104fe71>] ? __hrtimer_start_range_ns+0x2c6/0x2d9
 [<ffffffff81190656>] ? intel_idle+0xcd/0xe9
 [<ffffffff81190632>] ? intel_idle+0xa9/0xe9
 [<ffffffff812cb231>] ? cpuidle_idle_call+0xa0/0xdb
 [<ffffffff810007b9>] ? cpu_idle+0x53/0x7c
 [<ffffffff816869fa>] ? start_kernel+0x2be/0x2c9
---[ end trace 0107c607401edcc1 ]---
iwl data: 00000000: 00 00 35 02 00 00 fa 02 00 00 34 02 00 00 fa 02  ..5...=
....4.....
iwl data: 00000010: 00 00 35 02 00 00 34 02 00 00 35 02 00 00 f7 02  ..5...=
4...5.....
iwlagn 0000:03:00.0: iwl_hcmd_queue_reclaim: Read index for DMA queue txq i=
d (9), index 209 is out of range [0-256] 0 0.
iwlagn 0000:03:00.0: iwl_hcmd_queue_reclaim: Read index for DMA queue txq i=
d (9), index 215 is out of range [0-256] 0 0.
iwlagn 0000:03:00.0: iwl_hcmd_queue_reclaim: Read index for DMA queue txq i=
d (9), index 221 is out of range [0-256] 0 0.
iwlagn 0000:03:00.0: iwl_hcmd_queue_reclaim: Read index for DMA queue txq i=
d (9), index 214 is out of range [0-256] 0 0.
------------[ cut here ]------------
WARNING: at drivers/net/wireless/iwlwifi/iwl-trans-tx-pcie.c:765 iwl_tx_cmd=
_complete+0xa4/0x335 [iwlagn]()
Hardware name: 4290W4H
wrong command queue 20 (should be 9), sequence 0x1447 readp=3D0 writep=3D0
Modules linked in: iwlagn
Pid: 0, comm: swapper Tainted: G        W   3.1.0 #1
Call Trace:
 <IRQ>  [<ffffffff81036e2d>] ? warn_slowpath_common+0x78/0x8c
 [<ffffffff81036ee2>] ? warn_slowpath_fmt+0x45/0x4a
 [<ffffffffa0027199>] ? iwl_tx_cmd_complete+0xa4/0x335 [iwlagn]
 [<ffffffffa001c15c>] ? iwl_rx_dispatch+0x147/0x20f [iwlagn]
 [<ffffffffa00251d0>] ? iwl_irq_tasklet+0x7c9/0xb52 [iwlagn]
 [<ffffffffa0025fc3>] ? iwl_isr_ict+0x563/0x628 [iwlagn]
 [<ffffffff8103b439>] ? tasklet_action+0x67/0xa7
 [<ffffffff8103b95b>] ? __do_softirq+0x7f/0x106
 [<ffffffff813c10ec>] ? call_softirq+0x1c/0x26
 [<ffffffff8100351e>] ? do_softirq+0x31/0x67
 [<ffffffff8103bc0f>] ? irq_exit+0x44/0xb0
 [<ffffffff8100325f>] ? do_IRQ+0x94/0xad
 [<ffffffff813bf62b>] ? common_interrupt+0x6b/0x6b
 <EOI>  [<ffffffff8104fe71>] ? __hrtimer_start_range_ns+0x2c6/0x2d9
 [<ffffffff81190656>] ? intel_idle+0xcd/0xe9
 [<ffffffff81190632>] ? intel_idle+0xa9/0xe9
 [<ffffffff812cb231>] ? cpuidle_idle_call+0xa0/0xdb
 [<ffffffff810007b9>] ? cpu_idle+0x53/0x7c
 [<ffffffff816869fa>] ? start_kernel+0x2be/0x2c9
---[ end trace 0107c607401edcc2 ]---
iwl data: 00000000: cc 0e ba 13 e6 5d 47 14 14 13 7c 6c 42 dc f5 1a  .....]=
G...|lB...
iwl data: 00000010: 5a f8 f3 ba 2f b8 6d 20 10 0e 10 b2 c0 38 e7 0b  Z.../.=
m .....8..
------------[ cut here ]------------
WARNING: at drivers/net/wireless/iwlwifi/iwl-trans-tx-pcie.c:765 iwl_tx_cmd=
_complete+0xa4/0x335 [iwlagn]()
Hardware name: 4290W4H
wrong command queue 0 (should be 9), sequence 0xE1 readp=3D0 writep=3D0
Modules linked in: iwlagn
Pid: 0, comm: swapper Tainted: G        W   3.1.0 #1
Call Trace:
 <IRQ>  [<ffffffff81036e2d>] ? warn_slowpath_common+0x78/0x8c
 [<ffffffff81036ee2>] ? warn_slowpath_fmt+0x45/0x4a
 [<ffffffffa0027199>] ? iwl_tx_cmd_complete+0xa4/0x335 [iwlagn]
 [<ffffffffa001e577>] ? iwl_rx_scan_complete_notif+0x163/0x1d3 [iwlagn]
 [<ffffffffa00251d0>] ? iwl_irq_tasklet+0x7c9/0xb52 [iwlagn]
 [<ffffffffa0025fc3>] ? iwl_isr_ict+0x563/0x628 [iwlagn]
 [<ffffffff8103b439>] ? tasklet_action+0x67/0xa7
 [<ffffffff8103b95b>] ? __do_softirq+0x7f/0x106
 [<ffffffff813c10ec>] ? call_softirq+0x1c/0x26
 [<ffffffff8100351e>] ? do_softirq+0x31/0x67
 [<ffffffff8103bc0f>] ? irq_exit+0x44/0xb0
 [<ffffffff8100325f>] ? do_IRQ+0x94/0xad
 [<ffffffff813bf62b>] ? common_interrupt+0x6b/0x6b
 <EOI>  [<ffffffff8104fe71>] ? __hrtimer_start_range_ns+0x2c6/0x2d9
 [<ffffffff81190656>] ? intel_idle+0xcd/0xe9
 [<ffffffff81190632>] ? intel_idle+0xa9/0xe9
 [<ffffffff812cb231>] ? cpuidle_idle_call+0xa0/0xdb
 [<ffffffff810007b9>] ? cpu_idle+0x53/0x7c
 [<ffffffff816869fa>] ? start_kernel+0x2be/0x2c9
---[ end trace 0107c607401edcc3 ]---
iwl data: 00000000: 35 18 04 00 84 c5 e1 00 f1 00 e0 00 58 00 4e 00  5.....=
......X.N.
iwl data: 00000010: 35 08 04 00 85 c5 e1 00 2a b0 e1 00 15 00 13 00  5.....=
..*.......
iwlagn 0000:03:00.0: iwl_hcmd_queue_reclaim: Read index for DMA queue txq i=
d (9), index 208 is out of range [0-256] 0 0.
iwlagn 0000:03:00.0: iwl_hcmd_queue_reclaim: Read index for DMA queue txq i=
d (9), index 232 is out of range [0-256] 0 0.
iwlagn 0000:03:00.0: iwl_hcmd_queue_reclaim: Read index for DMA queue txq i=
d (9), index 213 is out of range [0-256] 0 0.
iwlagn 0000:03:00.0: iwl_hcmd_queue_reclaim: Read index for DMA queue txq i=
d (9), index 210 is out of range [0-256] 0 0.
------------[ cut here ]------------
WARNING: at drivers/net/wireless/iwlwifi/iwl-trans-tx-pcie.c:765 iwl_tx_cmd=
_complete+0xa4/0x335 [iwlagn]()
Hardware name: 4290W4H
wrong command queue 0 (should be 9), sequence 0x61 readp=3D0 writep=3D0
Modules linked in: iwlagn
Pid: 0, comm: swapper Tainted: G        W   3.1.0 #1
Call Trace:
 <IRQ>  [<ffffffff81036e2d>] ? warn_slowpath_common+0x78/0x8c
 [<ffffffff81036ee2>] ? warn_slowpath_fmt+0x45/0x4a
 [<ffffffffa0027199>] ? iwl_tx_cmd_complete+0xa4/0x335 [iwlagn]
 [<ffffffffa001c15c>] ? iwl_rx_dispatch+0x147/0x20f [iwlagn]
 [<ffffffffa00251d0>] ? iwl_irq_tasklet+0x7c9/0xb52 [iwlagn]
 [<ffffffffa0025fc3>] ? iwl_isr_ict+0x563/0x628 [iwlagn]
 [<ffffffff8103b439>] ? tasklet_action+0x67/0xa7
 [<ffffffff8103b95b>] ? __do_softirq+0x7f/0x106
 [<ffffffff813c10ec>] ? call_softirq+0x1c/0x26
 [<ffffffff8100351e>] ? do_softirq+0x31/0x67
 [<ffffffff8103bc0f>] ? irq_exit+0x44/0xb0
 [<ffffffff8100325f>] ? do_IRQ+0x94/0xad
 [<ffffffff813bf62b>] ? common_interrupt+0x6b/0x6b
 <EOI>  [<ffffffff8104fe71>] ? __hrtimer_start_range_ns+0x2c6/0x2d9
 [<ffffffff81190656>] ? intel_idle+0xcd/0xe9
 [<ffffffff81190632>] ? intel_idle+0xa9/0xe9
 [<ffffffff812cb231>] ? cpuidle_idle_call+0xa0/0xdb
 [<ffffffff810007b9>] ? cpu_idle+0x53/0x7c
 [<ffffffff816869fa>] ? start_kernel+0x2be/0x2c9
---[ end trace 0107c607401edcc4 ]---
iwl data: 00000000: 35 18 04 00 47 10 61 00 45 10 61 00 0c 00 0c 00  5...G.=
a.E.a.....
iwl data: 00000010: 37 00 04 00 48 10 61 00 45 10 61 00 00 00 00 00  7...H.=
a.E.a.....
iwlagn 0000:03:00.0: iwl_hcmd_queue_reclaim: Read index for DMA queue txq i=
d (9), index 219 is out of range [0-256] 0 0.
iwlagn 0000:03:00.0: iwl_hcmd_queue_reclaim: Read index for DMA queue txq i=
d (9), index 220 is out of range [0-256] 0 0.
iwlagn 0000:03:00.0: iwl_hcmd_queue_reclaim: Read index for DMA queue txq i=
d (9), index 212 is out of range [0-256] 0 0.
iwlagn 0000:03:00.0: iwl_hcmd_queue_reclaim: Read index for DMA queue txq i=
d (9), index 230 is out of range [0-256] 0 0.
------------[ cut here ]------------
WARNING: at drivers/net/wireless/iwlwifi/iwl-trans-tx-pcie.c:765 iwl_tx_cmd=
_complete+0xa4/0x335 [iwlagn]()
Hardware name: 4290W4H
wrong command queue 0 (should be 9), sequence 0x0 readp=3D0 writep=3D0
Modules linked in: iwlagn
Pid: 0, comm: swapper Tainted: G        W   3.1.0 #1
Call Trace:
 <IRQ>  [<ffffffff81036e2d>] ? warn_slowpath_common+0x78/0x8c
 [<ffffffff81036ee2>] ? warn_slowpath_fmt+0x45/0x4a
 [<ffffffffa0027199>] ? iwl_tx_cmd_complete+0xa4/0x335 [iwlagn]
 [<ffffffffa001c15c>] ? iwl_rx_dispatch+0x147/0x20f [iwlagn]
 [<ffffffffa00251d0>] ? iwl_irq_tasklet+0x7c9/0xb52 [iwlagn]
 [<ffffffffa0025fc3>] ? iwl_isr_ict+0x563/0x628 [iwlagn]
 [<ffffffff8103b439>] ? tasklet_action+0x67/0xa7
 [<ffffffff8103b95b>] ? __do_softirq+0x7f/0x106
 [<ffffffff813c10ec>] ? call_softirq+0x1c/0x26
 [<ffffffff8100351e>] ? do_softirq+0x31/0x67
 [<ffffffff8103bc0f>] ? irq_exit+0x44/0xb0
 [<ffffffff8100325f>] ? do_IRQ+0x94/0xad
 [<ffffffff813bf62b>] ? common_interrupt+0x6b/0x6b
 <EOI>  [<ffffffff8104fe71>] ? __hrtimer_start_range_ns+0x2c6/0x2d9
 [<ffffffff81190656>] ? intel_idle+0xcd/0xe9
 [<ffffffff81190632>] ? intel_idle+0xa9/0xe9
 [<ffffffff812cb231>] ? cpuidle_idle_call+0xa0/0xdb
 [<ffffffff810007b9>] ? cpu_idle+0x53/0x7c
 [<ffffffff816869fa>] ? start_kernel+0x2be/0x2c9
---[ end trace 0107c607401edcc5 ]---
iwl data: 00000000: 00 00 00 00 00 00 00 00 00 00 00 00 fe 01 00 00  ......=
..........
iwl data: 00000010: b8 c0 0c 04 00 ea ff ff c8 d7 09 07 00 ea ff ff  ......=
..........
iwlagn 0000:03:00.0: iwl_hcmd_queue_reclaim: Read index for DMA queue txq i=
d (9), index 216 is out of range [0-256] 0 0.
iwlagn 0000:03:00.0: iwl_hcmd_queue_reclaim: Read index for DMA queue txq i=
d (9), index 224 is out of range [0-256] 0 0.
iwlagn 0000:03:00.0: iwl_hcmd_queue_reclaim: Read index for DMA queue txq i=
d (9), index 223 is out of range [0-256] 0 0.
------------[ cut here ]------------
WARNING: at drivers/net/wireless/iwlwifi/iwl-trans-tx-pcie.c:765 iwl_tx_cmd=
_complete+0xa4/0x335 [iwlagn]()
Hardware name: 4290W4H
wrong command queue 18 (should be 9), sequence 0x5259 readp=3D0 writep=3D0
Modules linked in: iwlagn
Pid: 0, comm: swapper Tainted: G        W   3.1.0 #1
Call Trace:
 <IRQ>  [<ffffffff81036e2d>] ? warn_slowpath_common+0x78/0x8c
 [<ffffffff81036ee2>] ? warn_slowpath_fmt+0x45/0x4a
 [<ffffffffa0027199>] ? iwl_tx_cmd_complete+0xa4/0x335 [iwlagn]
 [<ffffffffa001c15c>] ? iwl_rx_dispatch+0x147/0x20f [iwlagn]
 [<ffffffffa00251d0>] ? iwl_irq_tasklet+0x7c9/0xb52 [iwlagn]
 [<ffffffffa0025fc3>] ? iwl_isr_ict+0x563/0x628 [iwlagn]
 [<ffffffff8103b439>] ? tasklet_action+0x67/0xa7
 [<ffffffff8103b95b>] ? __do_softirq+0x7f/0x106
 [<ffffffff813c10ec>] ? call_softirq+0x1c/0x26
 [<ffffffff8100351e>] ? do_softirq+0x31/0x67
 [<ffffffff8103bc0f>] ? irq_exit+0x44/0xb0
 [<ffffffff8100325f>] ? do_IRQ+0x94/0xad
 [<ffffffff813bf62b>] ? common_interrupt+0x6b/0x6b
 <EOI>  [<ffffffff8104fe71>] ? __hrtimer_start_range_ns+0x2c6/0x2d9
 [<ffffffff81190656>] ? intel_idle+0xcd/0xe9
 [<ffffffff81190632>] ? intel_idle+0xa9/0xe9
 [<ffffffff812cb231>] ? cpuidle_idle_call+0xa0/0xdb
 [<ffffffff810007b9>] ? cpu_idle+0x53/0x7c
 [<ffffffff816869fa>] ? start_kernel+0x2be/0x2c9
---[ end trace 0107c607401edcc6 ]---
iwl data: 00000000: d0 26 c9 95 25 33 59 52 20 38 a2 2c 91 27 48 90  .&..%3=
YR 8.,.'H.
iwl data: 00000010: fb 08 36 49 c5 1a a6 ee 13 48 03 62 44 30 77 60  ..6I..=
...H.bD0w`
iwlagn 0000:03:00.0: Failed to start RT ucode: -110
iwlagn 0000:03:00.0: Unable to initialize device.
------------[ cut here ]------------
WARNING: at net/mac80211/util.c:1182 ieee80211_reconfig+0x110/0x407()
Hardware name: 4290W4H
Hardware became unavailable upon resume. This could be a software issue pri=
or to suspend or a hardware issue.
Modules linked in: iwlagn
Pid: 4801, comm: acpi_handler.sh Tainted: G        W   3.1.0 #1
Call Trace:
 [<ffffffff81036e2d>] ? warn_slowpath_common+0x78/0x8c
 [<ffffffff81379cbf>] ? wiphy_suspend+0x5f/0x5f
 [<ffffffff81036ee2>] ? warn_slowpath_fmt+0x45/0x4a
 [<ffffffff813a7c7e>] ? ieee80211_reconfig+0x110/0x407
 [<ffffffff81379cbf>] ? wiphy_suspend+0x5f/0x5f
 [<ffffffff81379d2b>] ? wiphy_resume+0x6c/0x7c
 [<ffffffff8123d6ed>] ? legacy_resume+0x1e/0x4e
 [<ffffffff8123db3a>] ? device_resume+0xb7/0x100
 [<ffffffff8123e16f>] ? dpm_resume+0xd7/0x182
 [<ffffffff8123e36c>] ? dpm_resume_end+0x8/0x10
 [<ffffffff81062179>] ? suspend_devices_and_enter+0x1b3/0x1ec
 [<ffffffff8106228a>] ? enter_state+0xd8/0x12b
 [<ffffffff810619aa>] ? state_store+0xaa/0xca
 [<ffffffff810f08e1>] ? sysfs_write_file+0xd3/0x10f
 [<ffffffff810ac20b>] ? vfs_write+0xaf/0x129
 [<ffffffff810ac45e>] ? sys_write+0x45/0x6e
 [<ffffffff813bfc7b>] ? system_call_fastpath+0x16/0x1b
---[ end trace 0107c607401edcc7 ]---
legacy_resume(): wiphy_resume+0x0/0x7c returns -110
PM: Device phy0 failed to resume: error -110
PM: resume of devices complete after 2777.958 msecs
PM: Finishing wakeup.
Restarting tasks ... done.
video LNXVIDEO:00: Restoring backlight state

--Sig_/LAST2wjIhA==0GSWBra__7o
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEARECAAYFAk7Tly4ACgkQnhRzXSM7nSnBoQCfRdSoQ9r7eMI3SFhkPk7PebPV
u8kAn3sbc8t6nzZUjkhjepsYPk8/7Fbv
=rtXY
-----END PGP SIGNATURE-----

--Sig_/LAST2wjIhA==0GSWBra__7o--
