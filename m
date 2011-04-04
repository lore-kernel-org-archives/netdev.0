From: dann frazier <dannf@dannf.org>
Subject: Re: shutdown oops in xt_compat_calc_jump
Date: Mon, 4 Apr 2011 15:17:15 -0600
Message-ID: <20110404211714.GB3720@dannf.org>
References: <20110404194856.GA3720@dannf.org>
 <4D9A23BC.4010505@trash.net>
 <1301949477.3021.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from complete.lackof.org ([198.49.126.79]:55135 "EHLO
	complete.lackof.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413Ab1DDVRQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 17:17:16 -0400
Content-Disposition: inline
In-Reply-To: <1301949477.3021.55.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 04, 2011 at 10:37:57PM +0200, Eric Dumazet wrote:
> Le lundi 04 avril 2011 =E0 22:02 +0200, Patrick McHardy a =E9crit :
> > CCed netfilter-devel.
> >=20
> > Am 04.04.2011 21:48, schrieb dann frazier:
> > > fyi, noticed this oops when shutting down a system running top of=
 git
> > > (@ 78fca1be)
> > >=20
> > > [ 1169.794644] cfg80211: Calling CRDA to update world regulatory =
domain
> > > [ 1170.490646] bluetoothd[2029]: segfault at f8ad9944 ip 00000000=
f77045e0 sp 00000000ffcb14e0 error 4 in bluetoothd[f76bf000+8b000]
> > > [ 1170.543817] BUG: unable to handle kernel paging request at 000=
00001dc1be9f8
> > > [ 1170.543875] IP: [<ffffffffa051e7b0>] xt_compat_calc_jump+0x25/=
0x6f [x_tables]
> > > [ 1170.543927] PGD 1215b3067 PUD 0=20
> > > [ 1170.543955] Oops: 0000 [#1] SMP=20
> > > [ 1170.543982] last sysfs file: /sys/module/bridge/initstate
> > > [ 1170.544017] CPU 3=20
> > > [ 1170.544031] Modules linked in: ebtable_broute ebtable_filter v=
fat msdos fat ext3 jbd ip6table_filter ip6_tables ebtable_nat ebtables =
ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_s=
tate nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_table=
s bridge stp llc acpi_cpufreq mperf cpufreq_powersave cpufreq_userspace=
 cpufreq_conservative cpufreq_stats binfmt_misc kvm(-) fuse ext2 loop s=
nd_hda_codec_hdmi snd_hda_codec_conexant arc4 ecb snd_usb_audio snd_usb=
midi_lib snd_seq_midi snd_seq_midi_event snd_hda_intel snd_hda_codec sn=
d_hwdep snd_pcm snd_rawmidi i915 drm_kms_helper thinkpad_acpi snd_seq i=
wlagn snd_timer snd_seq_device drm snd mac80211 psmouse btusb serio_raw=
 bluetooth evdev tpm_tis snd_page_alloc tpm i2c_i801 i2c_algo_bit cfg80=
211 battery soundcore nvram tpm_bios i2c_core rfkill wmi ac power_suppl=
y video button processor ext4 mbcache jbd2 crc16 sha256_generic aesni_i=
ntel cryptd aes_x86_64 aes_generic cbc dm_crypt dm_mod sd_mod crc_t10
>  di
> > f=20
> > >  usbhid
> > > hid usb_storage ahci libahci libata ehci_hcd scsi_mod usbcore e10=
00e thermal thermal_sys [last unloaded: kvm_intel]
> > > [ 1170.544836]=20
> > > [ 1170.544849] Pid: 4901, comm: ebtables Not tainted 2.6.39-rc1+ =
#9 LENOVO 2516CTO/2516CTO
> > > [ 1170.544902] RIP: 0010:[<ffffffffa051e7b0>]  [<ffffffffa051e7b0=
>] xt_compat_calc_jump+0x25/0x6f [x_tables]
> > > [ 1170.544958] RSP: 0018:ffff880121473cf8  EFLAGS: 00010217
> > > [ 1170.544989] RAX: 000000003b837d3f RBX: 0000000000000090 RCX: 0=
00000007706fa7f
> > > [ 1170.545029] RDX: 0000000000000000 RSI: 0000000000000090 RDI: 0=
00000003b837d3f
> > > [ 1170.545067] RBP: ffffc900111a3000 R08: 0000000000000000 R09: d=
ead000000200200
> > > [ 1170.545104] R10: dead000000100100 R11: 0000000000001311 R12: f=
fff880121473d88
> > > [ 1170.545147] R13: ffffc900111a6000 R14: ffffffff817de300 R15: 0=
000000000000000
> > > [ 1170.545185] FS:  0000000000000000(0000) GS:ffff880137d80000(00=
63) knlGS:00000000f761b6c0
> > > [ 1170.545227] CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
> > > [ 1170.545258] CR2: 00000001dc1be9f8 CR3: 0000000125868000 CR4: 0=
0000000000006e0
> > > [ 1170.545297] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0=
000000000000000
> > > [ 1170.545334] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0=
000000000000400
> > > [ 1170.545375] Process ebtables (pid: 4901, threadinfo ffff880121=
472000, task ffff8801322d1ac0)
> > > [ 1170.545418] Stack:
> > > [ 1170.545433]  0000000000000090 ffffffffa0576d46 f7007265746c696=
6 0000000000000054
> > > [ 1170.545479]  0000000000000000 0000000000000000 000000000000000=
e 0000000000000090
> > > [ 1170.545529]  0000000000000000 0000000008af2180 0000000008af21b=
0 0000000008af21e0
> > > [ 1170.545579] Call Trace:
> > > [ 1170.545600]  [<ffffffffa0576d46>] ? compat_do_replace+0x117/0x=
221 [ebtables]
> > > [ 1170.545639]  [<ffffffffa0577392>] ? compat_do_ebt_set_ctl+0x55=
/0xbb [ebtables]
> > > [ 1170.545688]  [<ffffffff810337e3>] ? need_resched+0x1a/0x23
> > > [ 1170.545723]  [<ffffffff810337f1>] ? should_resched+0x5/0x24
> > > [ 1170.545730]  [<ffffffff81314cc5>] ? _cond_resched+0x9/0x20
> > > [ 1170.545733]  [<ffffffff813152fe>] ? mutex_lock_interruptible+0=
x18/0x32
> > > [ 1170.545738]  [<ffffffff8128490b>] ? nf_sockopt_find.clone.1+0x=
da/0xec
> > > [ 1170.545742]  [<ffffffff81284996>] ? compat_nf_sockopt+0x79/0xa=
5
> > > [ 1170.545744]  [<ffffffff810337f1>] ? should_resched+0x5/0x24
> > > [ 1170.545747]  [<ffffffff812849f3>] ? compat_nf_setsockopt+0x1a/=
0x1f
> > > [ 1170.545751]  [<ffffffff8128fb35>] ? compat_ip_setsockopt+0x80/=
0xa0
> > > [ 1170.545756]  [<ffffffff812784a2>] ? compat_sys_setsockopt+0x1d=
5/0x204
> > > [ 1170.545759]  [<ffffffff810337f1>] ? should_resched+0x5/0x24
> > > [ 1170.545761]  [<ffffffff81314cc5>] ? _cond_resched+0x9/0x20
> > > [ 1170.545764]  [<ffffffff812788a5>] ? compat_sys_socketcall+0x14=
8/0x1a7
> > > [ 1170.545768]  [<ffffffff8131d2c0>] ? sysenter_dispatch+0x7/0x2e
> > > [ 1170.545769] Code: 5d 41 5e 41 5f c3 40 0f b6 ff 53 31 d2 48 6b=
 ff 70 48 03 3d 03 1b 00 00 8b 4f 6c 4c 8b 47 60 ff c9 eb 27 8d 04 11 d=
1 f8 48 63 f8=20
> > > [ 1170.545787] RIP  [<ffffffffa051e7b0>] xt_compat_calc_jump+0x25=
/0x6f [x_tables]
> > > [ 1170.545792]  RSP <ffff880121473cf8>
> > > [ 1170.545794] CR2: 00000001dc1be9f8
> > > [ 1170.654269] ---[ end trace d44667d90dcbd115 ]---
> > > [ 1170.662411] fuse exit
> > > Kernel logging (proc) stopped.
> > > --
>=20
>=20
> Hmm, commit 255d0dc34068a976550ce555e must have a problem for ebtable=
s ?
>=20
> Dann, could you give us what you do with ebtables ?

I don't do anything explicitly with ebtables, I just happen to have it
installed. The only place I know of that calls ebtables on shutdown is
the ebtables initscript itself:

dannf@fluid:~$ sudo rm /tmp/ebtables.log=20
dannf@fluid:~$ cat /sbin/ebtables
#!/bin/sh

echo "$*" >> /tmp/ebtables.log

/sbin/ebtables.real $*
dannf@fluid:~$ sudo /etc/init.d/ebtables stop
Clearing ebtables rulesets: filter nat broute done.
dannf@fluid:~$ sudo cat /tmp/ebtables.log=20
-t filter -L
-t filter -L
-t nat -L
-t broute -L
-t filter --init-table
-t nat --init-table
-t broute --init-table
