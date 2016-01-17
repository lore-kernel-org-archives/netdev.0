From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 110921] New: Kernel warning and sometimes network goes
 down for over 4300 times in 3 months
Date: Sun, 17 Jan 2016 10:36:47 -0800
Message-ID: <20160117103647.31d4802e@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35654 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810AbcAQSgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2016 13:36:40 -0500
Received: by mail-pf0-f170.google.com with SMTP id 65so145125454pff.2
        for <netdev@vger.kernel.org>; Sun, 17 Jan 2016 10:36:39 -0800 (PST)
Received: from xeon-e3 (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by smtp.gmail.com with ESMTPSA id e17sm28562403pfd.4.2016.01.17.10.36.39
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Jan 2016 10:36:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 17 Jan 2016 13:08:49 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 110921] New: Kernel warning and sometimes network goes down for over 4300 times in 3 months


https://urldefense.proofpoint.com/v2/url?u=https-3A__bugzilla.kernel.org_show-5Fbug.cgi-3Fid-3D110921&d=CwICaQ&c=IL_XqQWOjubgfqINi2jTzg&r=q_lvUiVm1uM6QEw9TPH-6jiV__hsrE6xXUAtATPE9x0&m=ztoNe0v1yHfbVmuuB5_mHk5ippoCFqky5Lf5SahYAwQ&s=mvA3wj0pwSHegsq_VewoP07WHH1Z3yInE1Qw6if5PYA&e= 

            Bug ID: 110921
           Summary: Kernel warning and sometimes network goes down for
                    over 4300 times in 3 months
           Product: Networking
           Version: 2.5
    Kernel Version: 4.3.3-300.fc23.x86_64, 4.2.5-1-ARCH, 4.1.15-1-lts
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: blocking
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: myly103@gmail.com
        Regression: No

I've tried to change the system, kernel version, ax88179-dkms driver from
Archlinux AUR, updating BIOS to the latest version, and tried both AX88179 and
Realtek USB network card, but this warning is still there. What worse is that
sometimes it just brings the whole networking down.

In the meanwhile the onboard Intel e1000e shows no problem and never
disconnects. (I'm not sure if it triggered the warning)

The following 3 warnings are fresh today under Fedora Server 23.

[Sun Jan 17 20:19:36 2016] ------------[ cut here ]------------
[Sun Jan 17 20:19:36 2016] WARNING: CPU: 3 PID: 0 at net/ipv4/tcp_output.c:1149
tcp_fragment+0x34b/0x360()
[Sun Jan 17 20:19:36 2016] Modules linked in: tun pppoe pppox iptable_raw
ipt_MASQUERADE nf_nat_masquerade_ipv4 xt_nat iptable_nat nf_conntrack_ipv4
nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack xt_limit xt_multiport xt_mark
xt_owner iptable_mangle ppp_generic slhc intel_rapl iosf_mbi
x86_pkg_temp_thermal coretemp kvm_intel kvm vfat fat crct10dif_pclmul
crc32_pclmul iTCO_wdt crc32c_intel iTCO_vendor_support snd_hda_codec_realtek
snd_hda_codec_hdmi snd_hda_codec_generic snd_hda_intel snd_hda_codec
snd_soc_rt5640 snd_soc_rl6231 snd_hda_core snd_soc_core snd_hwdep snd_compress
snd_pcm_dmaengine ac97_bus i2c_i801 joydev snd_pcm mei_me snd_timer lpc_ich snd
mei elan_i2c soundcore nuvoton_cir dw_dmac tpm_tis rc_core dw_dmac_core tpm_crb
i2c_designware_platform snd_soc_sst_acpi i2c_designware_core tpm nfsd
auth_rpcgss
[Sun Jan 17 20:19:36 2016]  nfs_acl lockd grace sunrpc tcp_hybla ax88179_178a
usbnet mii uas usb_storage i915 i2c_algo_bit drm_kms_helper e1000e drm ptp
pps_core sdhci_acpi sdhci mmc_core video fjes i2c_hid
[Sun Jan 17 20:19:36 2016] CPU: 3 PID: 0 Comm: swapper/3 Not tainted
4.3.3-300.fc23.x86_64 #1
[Sun Jan 17 20:19:36 2016] Hardware name:                  /D54250WYK, BIOS
WYLPT10H.86A.0041.2015.0720.1108 07/20/2015
[Sun Jan 17 20:19:36 2016]  0000000000000000 358889591dd6ab2f ffff88021fb83950
ffffffff813a626f
[Sun Jan 17 20:19:36 2016]  0000000000000000 ffff88021fb83988 ffffffff810a07c2
ffff880208dcb000
[Sun Jan 17 20:19:36 2016]  ffff8801fd7571c0 00000000000001d0 0000000000000000
0000000000000001
[Sun Jan 17 20:19:36 2016] Call Trace:
[Sun Jan 17 20:19:36 2016]  <IRQ>  [<ffffffff813a626f>] dump_stack+0x44/0x55
[Sun Jan 17 20:19:36 2016]  [<ffffffff810a07c2>] warn_slowpath_common+0x82/0xc0
[Sun Jan 17 20:19:36 2016]  [<ffffffff810a090a>] warn_slowpath_null+0x1a/0x20
[Sun Jan 17 20:19:36 2016]  [<ffffffff816c9c2b>] tcp_fragment+0x34b/0x360
[Sun Jan 17 20:19:36 2016]  [<ffffffff816bf66f>] tcp_mark_head_lost+0x14f/0x240
[Sun Jan 17 20:19:36 2016]  [<ffffffff816c03fc>]
tcp_update_scoreboard+0x4c/0x70
[Sun Jan 17 20:19:36 2016]  [<ffffffff816c40e0>]
tcp_fastretrans_alert+0x770/0xb40
[Sun Jan 17 20:19:36 2016]  [<ffffffff816c6405>] tcp_ack+0x995/0x12c0
[Sun Jan 17 20:19:36 2016]  [<ffffffff816c7246>]
tcp_rcv_established+0x1d6/0x780
[Sun Jan 17 20:19:36 2016]  [<ffffffff8174ff9c>] tcp_v6_do_rcv+0x1ac/0x5d0
[Sun Jan 17 20:19:36 2016]  [<ffffffff81750b51>] tcp_v6_rcv+0x791/0x980
[Sun Jan 17 20:19:36 2016]  [<ffffffff81569996>] ?
usb_hcd_submit_urb+0xa6/0xac0
[Sun Jan 17 20:19:36 2016]  [<ffffffff8120778e>] ?
__kmalloc_node_track_caller+0x22e/0x2d0
[Sun Jan 17 20:19:36 2016]  [<ffffffff8172782c>] ip6_input_finish+0x6c/0x430
[Sun Jan 17 20:19:36 2016]  [<ffffffff817280ff>] ip6_input+0x2f/0xa0
[Sun Jan 17 20:19:36 2016]  [<ffffffff81733e17>] ? ip6_dst_check+0xb7/0xd0
[Sun Jan 17 20:19:36 2016]  [<ffffffff8174ef52>] ?
tcp_v6_early_demux+0x112/0x170
[Sun Jan 17 20:19:36 2016]  [<ffffffff81727757>] ip6_rcv_finish+0x37/0xa0
[Sun Jan 17 20:19:36 2016]  [<ffffffff81727f11>] ipv6_rcv+0x321/0x4e0
[Sun Jan 17 20:19:36 2016]  [<ffffffff8166c021>]
__netif_receive_skb_core+0x721/0x9f0
[Sun Jan 17 20:19:36 2016]  [<ffffffff815683fb>] ?
usb_hcd_giveback_urb+0x3b/0xd0
[Sun Jan 17 20:19:36 2016]  [<ffffffff8166c308>] __netif_receive_skb+0x18/0x60
[Sun Jan 17 20:19:36 2016]  [<ffffffff8166d048>] process_backlog+0xa8/0x140
[Sun Jan 17 20:19:36 2016]  [<ffffffff8166c878>] net_rx_action+0x208/0x310
[Sun Jan 17 20:19:36 2016]  [<ffffffff810a510b>] __do_softirq+0xfb/0x290
[Sun Jan 17 20:19:36 2016]  [<ffffffff810a54a5>] irq_exit+0x105/0x110
[Sun Jan 17 20:19:36 2016]  [<ffffffff81784514>] do_IRQ+0x54/0xd0
[Sun Jan 17 20:19:36 2016]  [<ffffffff81782107>] common_interrupt+0x87/0x87
[Sun Jan 17 20:19:36 2016]  <EOI>  [<ffffffff8161f9c0>] ?
cpuidle_enter_state+0x130/0x270
[Sun Jan 17 20:19:36 2016]  [<ffffffff8161f99b>] ?
cpuidle_enter_state+0x10b/0x270
[Sun Jan 17 20:19:36 2016]  [<ffffffff8161fb37>] cpuidle_enter+0x17/0x20
[Sun Jan 17 20:19:36 2016]  [<ffffffff810e26b2>] call_cpuidle+0x32/0x60
[Sun Jan 17 20:19:36 2016]  [<ffffffff8161fb13>] ? cpuidle_select+0x13/0x20
[Sun Jan 17 20:19:36 2016]  [<ffffffff810e2946>] cpu_startup_entry+0x266/0x320
[Sun Jan 17 20:19:36 2016]  [<ffffffff8104d547>] start_secondary+0x157/0x190
[Sun Jan 17 20:19:36 2016] ---[ end trace 219e8b12c2fe736d ]---
[Sun Jan 17 20:19:36 2016] ------------[ cut here ]------------
[Sun Jan 17 20:19:36 2016] WARNING: CPU: 1 PID: 0 at net/ipv4/tcp_output.c:1149
tcp_fragment+0x34b/0x360()
[Sun Jan 17 20:19:36 2016] Modules linked in: tun pppoe pppox iptable_raw
ipt_MASQUERADE nf_nat_masquerade_ipv4 xt_nat iptable_nat nf_conntrack_ipv4
nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack xt_limit xt_multiport xt_mark
xt_owner iptable_mangle ppp_generic slhc intel_rapl iosf_mbi
x86_pkg_temp_thermal coretemp kvm_intel kvm vfat fat crct10dif_pclmul
crc32_pclmul iTCO_wdt crc32c_intel iTCO_vendor_support snd_hda_codec_realtek
snd_hda_codec_hdmi snd_hda_codec_generic snd_hda_intel snd_hda_codec
snd_soc_rt5640 snd_soc_rl6231 snd_hda_core snd_soc_core snd_hwdep snd_compress
snd_pcm_dmaengine ac97_bus i2c_i801 joydev snd_pcm mei_me snd_timer lpc_ich snd
mei elan_i2c soundcore nuvoton_cir dw_dmac tpm_tis rc_core dw_dmac_core tpm_crb
i2c_designware_platform snd_soc_sst_acpi i2c_designware_core tpm nfsd
auth_rpcgss
[Sun Jan 17 20:19:36 2016]  nfs_acl lockd grace sunrpc tcp_hybla ax88179_178a
usbnet mii uas usb_storage i915 i2c_algo_bit drm_kms_helper e1000e drm ptp
pps_core sdhci_acpi sdhci mmc_core video fjes i2c_hid
[Sun Jan 17 20:19:36 2016] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G        W   
   4.3.3-300.fc23.x86_64 #1
[Sun Jan 17 20:19:36 2016] Hardware name:                  /D54250WYK, BIOS
WYLPT10H.86A.0041.2015.0720.1108 07/20/2015
[Sun Jan 17 20:19:36 2016]  0000000000000000 1e999096910c80aa ffff88021fa83950
ffffffff813a626f
[Sun Jan 17 20:19:36 2016]  0000000000000000 ffff88021fa83988 ffffffff810a07c2
ffff880208dcb000
[Sun Jan 17 20:19:36 2016]  ffff8801fd7571c0 00000000000001d0 0000000000000000
0000000000000002
[Sun Jan 17 20:19:36 2016] Call Trace:
[Sun Jan 17 20:19:36 2016]  <IRQ>  [<ffffffff813a626f>] dump_stack+0x44/0x55
[Sun Jan 17 20:19:36 2016]  [<ffffffff810a07c2>] warn_slowpath_common+0x82/0xc0
[Sun Jan 17 20:19:36 2016]  [<ffffffff810a090a>] warn_slowpath_null+0x1a/0x20
[Sun Jan 17 20:19:36 2016]  [<ffffffff816c9c2b>] tcp_fragment+0x34b/0x360
[Sun Jan 17 20:19:36 2016]  [<ffffffff816bf66f>] tcp_mark_head_lost+0x14f/0x240
[Sun Jan 17 20:19:36 2016]  [<ffffffff816c03fc>]
tcp_update_scoreboard+0x4c/0x70
[Sun Jan 17 20:19:36 2016]  [<ffffffff816c40e0>]
tcp_fastretrans_alert+0x770/0xb40
[Sun Jan 17 20:19:36 2016]  [<ffffffff816c6405>] tcp_ack+0x995/0x12c0
[Sun Jan 17 20:19:36 2016]  [<ffffffff816c7246>]
tcp_rcv_established+0x1d6/0x780
[Sun Jan 17 20:19:36 2016]  [<ffffffff8174ff9c>] tcp_v6_do_rcv+0x1ac/0x5d0
[Sun Jan 17 20:19:36 2016]  [<ffffffff810e9200>] ?
queued_spin_lock_slowpath+0x160/0x170
[Sun Jan 17 20:19:36 2016]  [<ffffffff81750b51>] tcp_v6_rcv+0x791/0x980
[Sun Jan 17 20:19:36 2016]  [<ffffffff81569996>] ?
usb_hcd_submit_urb+0xa6/0xac0
[Sun Jan 17 20:19:36 2016]  [<ffffffff8120778e>] ?
__kmalloc_node_track_caller+0x22e/0x2d0
[Sun Jan 17 20:19:36 2016]  [<ffffffff8172782c>] ip6_input_finish+0x6c/0x430
[Sun Jan 17 20:19:36 2016]  [<ffffffff817280ff>] ip6_input+0x2f/0xa0
[Sun Jan 17 20:19:36 2016]  [<ffffffff81733e17>] ? ip6_dst_check+0xb7/0xd0
[Sun Jan 17 20:19:36 2016]  [<ffffffff8174ef52>] ?
tcp_v6_early_demux+0x112/0x170
[Sun Jan 17 20:19:36 2016]  [<ffffffff81727757>] ip6_rcv_finish+0x37/0xa0
[Sun Jan 17 20:19:36 2016]  [<ffffffff81727f11>] ipv6_rcv+0x321/0x4e0
[Sun Jan 17 20:19:36 2016]  [<ffffffff8166c021>]
__netif_receive_skb_core+0x721/0x9f0
[Sun Jan 17 20:19:36 2016]  [<ffffffff815683fb>] ?
usb_hcd_giveback_urb+0x3b/0xd0
[Sun Jan 17 20:19:36 2016]  [<ffffffff8166c308>] __netif_receive_skb+0x18/0x60
[Sun Jan 17 20:19:36 2016]  [<ffffffff8166d048>] process_backlog+0xa8/0x140
[Sun Jan 17 20:19:36 2016]  [<ffffffff8166c878>] net_rx_action+0x208/0x310
[Sun Jan 17 20:19:36 2016]  [<ffffffff810a510b>] __do_softirq+0xfb/0x290
[Sun Jan 17 20:19:36 2016]  [<ffffffff810a54a5>] irq_exit+0x105/0x110
[Sun Jan 17 20:19:36 2016]  [<ffffffff81784514>] do_IRQ+0x54/0xd0
[Sun Jan 17 20:19:36 2016]  [<ffffffff81782107>] common_interrupt+0x87/0x87
[Sun Jan 17 20:19:36 2016]  <EOI>  [<ffffffff8161f9c0>] ?
cpuidle_enter_state+0x130/0x270
[Sun Jan 17 20:19:36 2016]  [<ffffffff8161f99b>] ?
cpuidle_enter_state+0x10b/0x270
[Sun Jan 17 20:19:36 2016]  [<ffffffff8161fb37>] cpuidle_enter+0x17/0x20
[Sun Jan 17 20:19:36 2016]  [<ffffffff810e26b2>] call_cpuidle+0x32/0x60
[Sun Jan 17 20:19:36 2016]  [<ffffffff8161fb13>] ? cpuidle_select+0x13/0x20
[Sun Jan 17 20:19:36 2016]  [<ffffffff810e2946>] cpu_startup_entry+0x266/0x320
[Sun Jan 17 20:19:36 2016]  [<ffffffff8104d547>] start_secondary+0x157/0x190
[Sun Jan 17 20:19:36 2016] ---[ end trace 219e8b12c2fe736e ]---
[Sun Jan 17 20:19:56 2016] ------------[ cut here ]------------
[Sun Jan 17 20:19:56 2016] WARNING: CPU: 3 PID: 0 at net/ipv4/tcp_output.c:1149
tcp_fragment+0x34b/0x360()
[Sun Jan 17 20:19:56 2016] Modules linked in: tun pppoe pppox iptable_raw
ipt_MASQUERADE nf_nat_masquerade_ipv4 xt_nat iptable_nat nf_conntrack_ipv4
nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack xt_limit xt_multiport xt_mark
xt_owner iptable_mangle ppp_generic slhc intel_rapl iosf_mbi
x86_pkg_temp_thermal coretemp kvm_intel kvm vfat fat crct10dif_pclmul
crc32_pclmul iTCO_wdt crc32c_intel iTCO_vendor_support snd_hda_codec_realtek
snd_hda_codec_hdmi snd_hda_codec_generic snd_hda_intel snd_hda_codec
snd_soc_rt5640 snd_soc_rl6231 snd_hda_core snd_soc_core snd_hwdep snd_compress
snd_pcm_dmaengine ac97_bus i2c_i801 joydev snd_pcm mei_me snd_timer lpc_ich snd
mei elan_i2c soundcore nuvoton_cir dw_dmac tpm_tis rc_core dw_dmac_core tpm_crb
i2c_designware_platform snd_soc_sst_acpi i2c_designware_core tpm nfsd
auth_rpcgss
[Sun Jan 17 20:19:56 2016]  nfs_acl lockd grace sunrpc tcp_hybla ax88179_178a
usbnet mii uas usb_storage i915 i2c_algo_bit drm_kms_helper e1000e drm ptp
pps_core sdhci_acpi sdhci mmc_core video fjes i2c_hid
[Sun Jan 17 20:19:56 2016] CPU: 3 PID: 0 Comm: swapper/3 Tainted: G        W   
   4.3.3-300.fc23.x86_64 #1
[Sun Jan 17 20:19:56 2016] Hardware name:                  /D54250WYK, BIOS
WYLPT10H.86A.0041.2015.0720.1108 07/20/2015
[Sun Jan 17 20:19:56 2016]  0000000000000000 358889591dd6ab2f ffff88021fb83950
ffffffff813a626f
[Sun Jan 17 20:19:56 2016]  0000000000000000 ffff88021fb83988 ffffffff810a07c2
ffff880214483400
[Sun Jan 17 20:19:56 2016]  ffff8801fd7571c0 000000000000003a 0000000000000000
0000000000000001
[Sun Jan 17 20:19:56 2016] Call Trace:
[Sun Jan 17 20:19:56 2016]  <IRQ>  [<ffffffff813a626f>] dump_stack+0x44/0x55
[Sun Jan 17 20:19:56 2016]  [<ffffffff810a07c2>] warn_slowpath_common+0x82/0xc0
[Sun Jan 17 20:19:56 2016]  [<ffffffff810a090a>] warn_slowpath_null+0x1a/0x20
[Sun Jan 17 20:19:56 2016]  [<ffffffff816c9c2b>] tcp_fragment+0x34b/0x360
[Sun Jan 17 20:19:56 2016]  [<ffffffff816bf66f>] tcp_mark_head_lost+0x14f/0x240
[Sun Jan 17 20:19:56 2016]  [<ffffffff816c03fc>]
tcp_update_scoreboard+0x4c/0x70
[Sun Jan 17 20:19:56 2016]  [<ffffffff816c40e0>]
tcp_fastretrans_alert+0x770/0xb40
[Sun Jan 17 20:19:56 2016]  [<ffffffff816c6405>] tcp_ack+0x995/0x12c0
[Sun Jan 17 20:19:56 2016]  [<ffffffff816c7246>]
tcp_rcv_established+0x1d6/0x780
[Sun Jan 17 20:19:56 2016]  [<ffffffff8174ff9c>] tcp_v6_do_rcv+0x1ac/0x5d0
[Sun Jan 17 20:19:56 2016]  [<ffffffff81750b51>] tcp_v6_rcv+0x791/0x980
[Sun Jan 17 20:19:56 2016]  [<ffffffff81569996>] ?
usb_hcd_submit_urb+0xa6/0xac0
[Sun Jan 17 20:19:56 2016]  [<ffffffff8120778e>] ?
__kmalloc_node_track_caller+0x22e/0x2d0
[Sun Jan 17 20:19:56 2016]  [<ffffffff8172782c>] ip6_input_finish+0x6c/0x430
[Sun Jan 17 20:19:56 2016]  [<ffffffff817280ff>] ip6_input+0x2f/0xa0
[Sun Jan 17 20:19:56 2016]  [<ffffffff81733e17>] ? ip6_dst_check+0xb7/0xd0
[Sun Jan 17 20:19:56 2016]  [<ffffffff8174ef52>] ?
tcp_v6_early_demux+0x112/0x170
[Sun Jan 17 20:19:56 2016]  [<ffffffff81727757>] ip6_rcv_finish+0x37/0xa0
[Sun Jan 17 20:19:56 2016]  [<ffffffff81727f11>] ipv6_rcv+0x321/0x4e0
[Sun Jan 17 20:19:56 2016]  [<ffffffff8166c021>]
__netif_receive_skb_core+0x721/0x9f0
[Sun Jan 17 20:19:56 2016]  [<ffffffff815683fb>] ?
usb_hcd_giveback_urb+0x3b/0xd0
[Sun Jan 17 20:19:56 2016]  [<ffffffff8166c308>] __netif_receive_skb+0x18/0x60
[Sun Jan 17 20:19:56 2016]  [<ffffffff8166d048>] process_backlog+0xa8/0x140
[Sun Jan 17 20:19:56 2016]  [<ffffffff8166c878>] net_rx_action+0x208/0x310
[Sun Jan 17 20:19:56 2016]  [<ffffffff810a510b>] __do_softirq+0xfb/0x290
[Sun Jan 17 20:19:56 2016]  [<ffffffff810a54a5>] irq_exit+0x105/0x110
[Sun Jan 17 20:19:56 2016]  [<ffffffff81784514>] do_IRQ+0x54/0xd0
[Sun Jan 17 20:19:56 2016]  [<ffffffff81782107>] common_interrupt+0x87/0x87
[Sun Jan 17 20:19:56 2016]  <EOI>  [<ffffffff8161f9c0>] ?
cpuidle_enter_state+0x130/0x270
[Sun Jan 17 20:19:56 2016]  [<ffffffff8161f99b>] ?
cpuidle_enter_state+0x10b/0x270
[Sun Jan 17 20:19:56 2016]  [<ffffffff8161fb37>] cpuidle_enter+0x17/0x20
[Sun Jan 17 20:19:56 2016]  [<ffffffff810e26b2>] call_cpuidle+0x32/0x60
[Sun Jan 17 20:19:56 2016]  [<ffffffff8161fb13>] ? cpuidle_select+0x13/0x20
[Sun Jan 17 20:19:56 2016]  [<ffffffff810e2946>] cpu_startup_entry+0x266/0x320
[Sun Jan 17 20:19:56 2016]  [<ffffffff8104d547>] start_secondary+0x157/0x190
[Sun Jan 17 20:19:56 2016] ---[ end trace 219e8b12c2fe736f ]---

========================================================================
The following comes from Archlinux with mainline kernel and LTS kernel.

Nov 12 10:40:55 xxxx-Server kernel: ------------[ cut here ]------------
Nov 12 10:40:55 xxxx-Server kernel: WARNING: CPU: 2 PID: 0 at
net/ipv4/tcp_output.c:1155 tcp_fragment+0x339/0x350()
Nov 12 10:40:55 xxxx-Server kernel: Modules linked in: pppoe pppox
snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic tun xt_owner
iptable_mangle xt_limit ipt_REJECT nf_reject_ipv4 xt_multiport iptable_fi
Nov 12 10:40:55 xxxx-Server kernel:  ir_sharp_decoder mii ir_sanyo_decoder
ir_sony_decoder ir_jvc_decoder ir_rc5_decoder ir_rc6_decoder ir_nec_decoder
e1000e i2c_algo_bit snd_hda_codec lpc_ich snd_soc_core mei snd_hd
Nov 12 10:40:55 xxxx-Server kernel: CPU: 2 PID: 0 Comm: swapper/2 Tainted: G   
    W       4.2.5-1-ARCH #1
Nov 12 10:40:55 xxxx-Server kernel: Hardware name:                  /D54250WYK,
BIOS WYLPT10H.86A.0040.2015.0612.1400 06/12/2015
Nov 12 10:40:55 xxxx-Server kernel:  0000000000000000 cf3967526c8fb34a
ffff88021fb03868 ffffffff81570d0a
Nov 12 10:40:55 xxxx-Server kernel:  0000000000000000 0000000000000000
ffff88021fb038a8 ffffffff810748a6
Nov 12 10:40:55 xxxx-Server kernel:  ffff88021fb038f8 ffff8800cb753e00
ffff880210aec600 00000000000000ca
Nov 12 10:40:55 xxxx-Server kernel: Call Trace:
Nov 12 10:40:55 xxxx-Server kernel:  <IRQ>  [<ffffffff81570d0a>]
dump_stack+0x4c/0x6e
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff810748a6>]
warn_slowpath_common+0x86/0xc0
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff810749da>]
warn_slowpath_null+0x1a/0x20
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff814ca429>]
tcp_fragment+0x339/0x350
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff814c059f>]
tcp_mark_head_lost+0x14f/0x240
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff814c1efc>]
tcp_update_scoreboard+0x4c/0x70
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff814c3ec4>]
tcp_fastretrans_alert+0x754/0xb30
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff814c6e74>] tcp_ack+0x994/0x12c0
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffffa005b300>] ?
usb_hcd_end_port_resume+0x50/0x70 [usbcore]
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff814c7bd5>]
tcp_rcv_established+0x115/0x710
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff81543666>]
tcp_v6_do_rcv+0x2f6/0x600
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff8154540f>]
tcp_v6_rcv+0x8cf/0x9d0
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffffa005d6d6>] ?
usb_hcd_submit_urb+0xa6/0xa60 [usbcore]
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff81460e07>] ?
__alloc_skb+0x87/0x210
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff8151c0bb>]
ip6_input_finish+0x14b/0x460
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff8151c3e3>]
ip6_input.part.0+0x13/0x20
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff8151c8fd>] ip6_input+0x2d/0xa0
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff8152979e>] ?
ip6_dst_check+0x7e/0xa0
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff81545671>] ?
tcp_v6_early_demux+0x161/0x170
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff8151bf3e>]
ip6_rcv_finish+0x6e/0xa0
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff8151c731>] ipv6_rcv+0x341/0x4e0
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff8147077b>]
__netif_receive_skb_core+0x73b/0xa40
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffffa005bac3>] ?
usb_hcd_giveback_urb+0x43/0x140 [usbcore]
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff81472ff8>]
__netif_receive_skb+0x18/0x60
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff81474d84>]
process_backlog+0xb4/0x160
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff81474ba6>]
net_rx_action+0x216/0x340
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff8107864f>]
__do_softirq+0xcf/0x290
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff81078983>] irq_exit+0xa3/0xb0
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff81578d08>] do_IRQ+0x58/0xe0
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff81576dab>]
common_interrupt+0x6b/0x6b
Nov 12 10:40:55 xxxx-Server kernel:  <EOI>  [<ffffffff8142e4d4>] ?
cpuidle_enter_state+0x124/0x290
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff8142e4af>] ?
cpuidle_enter_state+0xff/0x290
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff8142e677>]
cpuidle_enter+0x17/0x20
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff810b4fe2>]
call_cpuidle+0x32/0x60
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff8142e653>] ?
cpuidle_select+0x13/0x20
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff810b52a4>]
cpu_startup_entry+0x294/0x370
Nov 12 10:40:55 xxxx-Server kernel:  [<ffffffff8104d1ba>]
start_secondary+0x18a/0x1c0
Nov 12 10:40:55 xxxx-Server kernel: ---[ end trace 59e406c615ec5507 ]---

Nov 12 10:40:56 xxxx-Server kernel: ------------[ cut here ]------------
Nov 12 10:40:56 xxxx-Server kernel: WARNING: CPU: 2 PID: 0 at
net/ipv4/tcp_output.c:1155 tcp_fragment+0x339/0x350()
Nov 12 10:40:56 xxxx-Server kernel: Modules linked in: pppoe pppox
snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic tun xt_owner
iptable_mangle xt_limit ipt_REJECT nf_reject_ipv4 xt_multiport iptable_fi
Nov 12 10:40:56 xxxx-Server kernel:  ir_sharp_decoder mii ir_sanyo_decoder
ir_sony_decoder ir_jvc_decoder ir_rc5_decoder ir_rc6_decoder ir_nec_decoder
e1000e i2c_algo_bit snd_hda_codec lpc_ich snd_soc_core mei snd_hd
Nov 12 10:40:56 xxxx-Server kernel: CPU: 2 PID: 0 Comm: swapper/2 Tainted: G   
    W       4.2.5-1-ARCH #1
Nov 12 10:40:56 xxxx-Server kernel: Hardware name:                  /D54250WYK,
BIOS WYLPT10H.86A.0040.2015.0612.1400 06/12/2015
Nov 12 10:40:56 xxxx-Server kernel:  0000000000000000 cf3967526c8fb34a
ffff88021fb03868 ffffffff81570d0a
Nov 12 10:40:56 xxxx-Server kernel:  0000000000000000 0000000000000000
ffff88021fb038a8 ffffffff810748a6
Nov 12 10:40:56 xxxx-Server kernel:  ffff88021fb038f8 ffff880037e3e800
ffff880210aec600 0000000000000065
Nov 12 10:40:56 xxxx-Server kernel: Call Trace:
Nov 12 10:40:56 xxxx-Server kernel:  <IRQ>  [<ffffffff81570d0a>]
dump_stack+0x4c/0x6e
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff810748a6>]
warn_slowpath_common+0x86/0xc0
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff810749da>]
warn_slowpath_null+0x1a/0x20
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff814ca429>]
tcp_fragment+0x339/0x350
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff814c059f>]
tcp_mark_head_lost+0x14f/0x240
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff814c1efc>]
tcp_update_scoreboard+0x4c/0x70
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff814c3ec4>]
tcp_fastretrans_alert+0x754/0xb30
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff814c6e74>] tcp_ack+0x994/0x12c0
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffffa005b300>] ?
usb_hcd_end_port_resume+0x50/0x70 [usbcore]
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff814c7bd5>]
tcp_rcv_established+0x115/0x710
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff81543666>]
tcp_v6_do_rcv+0x2f6/0x600
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff8154540f>]
tcp_v6_rcv+0x8cf/0x9d0
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffffa005d6d6>] ?
usb_hcd_submit_urb+0xa6/0xa60 [usbcore]
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff81460e07>] ?
__alloc_skb+0x87/0x210
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff8151c0bb>]
ip6_input_finish+0x14b/0x460
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff8151c3e3>]
ip6_input.part.0+0x13/0x20
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff8151c8fd>] ip6_input+0x2d/0xa0
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff8152979e>] ?
ip6_dst_check+0x7e/0xa0
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff81545671>] ?
tcp_v6_early_demux+0x161/0x170
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff8151bf3e>]
ip6_rcv_finish+0x6e/0xa0
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff8151c731>] ipv6_rcv+0x341/0x4e0
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff8147077b>]
__netif_receive_skb_core+0x73b/0xa40
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffffa005bac3>] ?
usb_hcd_giveback_urb+0x43/0x140 [usbcore]
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff81472ff8>]
__netif_receive_skb+0x18/0x60
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff81474d84>]
process_backlog+0xb4/0x160
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff81474ba6>]
net_rx_action+0x216/0x340
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff8107864f>]
__do_softirq+0xcf/0x290
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff81078983>] irq_exit+0xa3/0xb0
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff81578d08>] do_IRQ+0x58/0xe0
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff81576dab>]
common_interrupt+0x6b/0x6b
Nov 12 10:40:56 xxxx-Server kernel:  <EOI>  [<ffffffff810146ec>] ?
__switch_to+0x25c/0x4a0
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff8142e4d4>] ?
cpuidle_enter_state+0x124/0x290
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff8142e4af>] ?
cpuidle_enter_state+0xff/0x290
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff8142e677>]
cpuidle_enter+0x17/0x20
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff810b4fe2>]
call_cpuidle+0x32/0x60
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff8142e653>] ?
cpuidle_select+0x13/0x20
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff810b52a4>]
cpu_startup_entry+0x294/0x370
Nov 12 10:40:56 xxxx-Server kernel:  [<ffffffff8104d1ba>]
start_secondary+0x18a/0x1c0
Nov 12 10:40:56 xxxx-Server kernel: ---[ end trace 59e406c615ec5508 ]---

Nov 12 10:40:59 xxxx-Server kernel: ------------[ cut here ]------------
Nov 12 10:40:59 xxxx-Server kernel: WARNING: CPU: 2 PID: 0 at
net/ipv4/tcp_output.c:1155 tcp_fragment+0x339/0x350()
Nov 12 10:40:59 xxxx-Server kernel: Modules linked in: pppoe pppox
snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic tun xt_owner
iptable_mangle xt_limit ipt_REJECT nf_reject_ipv4 xt_multiport iptable_fi
Nov 12 10:40:59 xxxx-Server kernel:  ir_sharp_decoder mii ir_sanyo_decoder
ir_sony_decoder ir_jvc_decoder ir_rc5_decoder ir_rc6_decoder ir_nec_decoder
e1000e i2c_algo_bit snd_hda_codec lpc_ich snd_soc_core mei snd_hd
Nov 12 10:40:59 xxxx-Server kernel: CPU: 2 PID: 0 Comm: swapper/2 Tainted: G   
    W       4.2.5-1-ARCH #1
Nov 12 10:40:59 xxxx-Server kernel: Hardware name:                  /D54250WYK,
BIOS WYLPT10H.86A.0040.2015.0612.1400 06/12/2015
Nov 12 10:40:59 xxxx-Server kernel:  0000000000000000 cf3967526c8fb34a
ffff88021fb03868 ffffffff81570d0a
Nov 12 10:40:59 xxxx-Server kernel:  0000000000000000 0000000000000000
ffff88021fb038a8 ffffffff810748a6
Nov 12 10:40:59 xxxx-Server kernel:  ffff88021fb038f8 ffff880214da7000
ffff880210aec600 00000000000000ce
Nov 12 10:40:59 xxxx-Server kernel: Call Trace:
Nov 12 10:40:59 xxxx-Server kernel:  <IRQ>  [<ffffffff81570d0a>]
dump_stack+0x4c/0x6e
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff810748a6>]
warn_slowpath_common+0x86/0xc0
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff810749da>]
warn_slowpath_null+0x1a/0x20
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff814ca429>]
tcp_fragment+0x339/0x350
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff814c059f>]
tcp_mark_head_lost+0x14f/0x240
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff814c1efc>]
tcp_update_scoreboard+0x4c/0x70
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff814c3ec4>]
tcp_fastretrans_alert+0x754/0xb30
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff814c6e74>] tcp_ack+0x994/0x12c0
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffffa005b300>] ?
usb_hcd_end_port_resume+0x50/0x70 [usbcore]
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff814c7bd5>]
tcp_rcv_established+0x115/0x710
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff81543666>]
tcp_v6_do_rcv+0x2f6/0x600
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff8154540f>]
tcp_v6_rcv+0x8cf/0x9d0
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffffa005d6d6>] ?
usb_hcd_submit_urb+0xa6/0xa60 [usbcore]
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff81460e07>] ?
__alloc_skb+0x87/0x210
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff8151c0bb>]
ip6_input_finish+0x14b/0x460
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff8151c3e3>]
ip6_input.part.0+0x13/0x20
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff8151c8fd>] ip6_input+0x2d/0xa0
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff8152979e>] ?
ip6_dst_check+0x7e/0xa0
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff81545671>] ?
tcp_v6_early_demux+0x161/0x170
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff8151bf3e>]
ip6_rcv_finish+0x6e/0xa0
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff8151c731>] ipv6_rcv+0x341/0x4e0
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff8147077b>]
__netif_receive_skb_core+0x73b/0xa40
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffffa005bac3>] ?
usb_hcd_giveback_urb+0x43/0x140 [usbcore]
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff81472ff8>]
__netif_receive_skb+0x18/0x60
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff81474d84>]
process_backlog+0xb4/0x160
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff81474ba6>]
net_rx_action+0x216/0x340
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff8107864f>]
__do_softirq+0xcf/0x290
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff81078983>] irq_exit+0xa3/0xb0
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff81578d08>] do_IRQ+0x58/0xe0
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff81576dab>]
common_interrupt+0x6b/0x6b
Nov 12 10:40:59 xxxx-Server kernel:  <EOI>  [<ffffffff8142e4d4>] ?
cpuidle_enter_state+0x124/0x290
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff8142e4af>] ?
cpuidle_enter_state+0xff/0x290
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff8142e677>]
cpuidle_enter+0x17/0x20
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff810b4fe2>]
call_cpuidle+0x32/0x60
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff8142e653>] ?
cpuidle_select+0x13/0x20
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff810b52a4>]
cpu_startup_entry+0x294/0x370
Nov 12 10:40:59 xxxx-Server kernel:  [<ffffffff8104d1ba>]
start_secondary+0x18a/0x1c0
Nov 12 10:40:59 xxxx-Server kernel: ---[ end trace 59e406c615ec5509 ]---

Jan 13 06:51:38 xxxx-Server kernel: ------------[ cut here ]------------
Jan 13 06:51:38 xxxx-Server kernel: WARNING: CPU: 2 PID: 0 at
net/ipv4/tcp_output.c:1155 tcp_fragment+0x2d1/0x2f0()
Jan 13 06:51:38 xxxx-Server kernel: Modules linked in: pppoe pppox
snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic xt_owner
iptable_mangle xt_limit ipt_REJECT nf_reject_ipv4 xt_multiport iptable_filter
Jan 13 06:51:38 xxxx-Server kernel:  ir_sharp_decoder ir_sanyo_decoder
ir_jvc_decoder ir_sony_decoder pcspkr ir_rc6_decoder ir_rc5_decoder ptp
ir_nec_decoder mei_me i2c_i801 lpc_ich snd_compress pps_core snd_hda_core
Jan 13 06:51:38 xxxx-Server kernel: CPU: 2 PID: 0 Comm: swapper/2 Tainted: G   
    W       4.1.15-1-lts #1
Jan 13 06:51:38 xxxx-Server kernel: Hardware name:                  /D54250WYK,
BIOS WYLPT10H.86A.0040.2015.0612.1400 06/12/2015
Jan 13 06:51:38 xxxx-Server kernel:  0000000000000000 72735c07e87b0416
ffff88021fb038c8 ffffffff8157d9ba
Jan 13 06:51:38 xxxx-Server kernel:  0000000000000000 0000000000000000
ffff88021fb03908 ffffffff810760da
Jan 13 06:51:38 xxxx-Server kernel:  ffff880200000001 ffff88000195bc00
ffff880100fd0000 0000000000000039
Jan 13 06:51:38 xxxx-Server kernel: Call Trace:
Jan 13 06:51:38 xxxx-Server kernel:  <IRQ>  [<ffffffff8157d9ba>]
dump_stack+0x45/0x57
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff810760da>]
warn_slowpath_common+0x8a/0xc0
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff8107620a>]
warn_slowpath_null+0x1a/0x20
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff814d7f11>]
tcp_fragment+0x2d1/0x2f0
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff814cd82e>]
tcp_mark_head_lost+0x16e/0x280
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff814cf49d>]
tcp_update_scoreboard+0x4d/0x80
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff814d16ad>]
tcp_fastretrans_alert+0x7bd/0xc20
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff814d47b2>] tcp_ack+0x9a2/0x1240
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff814d54be>]
tcp_rcv_established+0x11e/0x750
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff81554b70>]
tcp_v6_do_rcv+0x210/0x620
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff81556ae8>]
tcp_v6_rcv+0x9e8/0xa40
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffffa005e146>] ?
usb_hcd_submit_urb+0xa6/0xab0 [usbcore]
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff8146bc77>] ?
__alloc_skb+0x87/0x210
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff8152bd19>]
ip6_input_finish+0x149/0x480
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff8152c58f>] ip6_input+0x2f/0x90
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff81538f67>] ?
ip6_dst_check+0x27/0x50
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff81556cb5>] ?
tcp_v6_early_demux+0x175/0x190
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff8152bb98>]
ip6_rcv_finish+0x78/0xb0
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff8152c370>] ipv6_rcv+0x320/0x510
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff8147af93>]
__netif_receive_skb_core+0x6b3/0xa10
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff8147da58>]
__netif_receive_skb+0x18/0x60
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff8147f8d2>]
process_backlog+0xb2/0x150
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff8147f6f2>]
net_rx_action+0x212/0x340
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff8107a043>]
__do_softirq+0x103/0x280
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff8107a33d>] irq_exit+0xad/0xb0
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff81585848>] do_IRQ+0x58/0xf0
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff8158382e>]
common_interrupt+0x6e/0x6e
Jan 13 06:51:38 xxxx-Server kernel:  <EOI>  [<ffffffff81438812>] ?
cpuidle_enter_state+0x92/0x200
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff814387e4>] ?
cpuidle_enter_state+0x64/0x200
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff814389b7>]
cpuidle_enter+0x17/0x20
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff810b8d3c>]
cpu_startup_entry+0x2ec/0x400
Jan 13 06:51:38 xxxx-Server kernel:  [<ffffffff8104d6fe>]
start_secondary+0x18e/0x1d0
Jan 13 06:51:38 xxxx-Server kernel: ---[ end trace 066cc5bbc15f21cf ]---

=============================================================================
And occasionally the whole network goes down and later appears the following:

Jan 16 05:43:59 xxxx-Server kernel: ------------[ cut here ]------------
Jan 16 05:43:59 xxxx-Server kernel: WARNING: CPU: 3 PID: 0 at
net/sched/sch_generic.c:303 dev_watchdog+0x252/0x260()
Jan 16 05:43:59 xxxx-Server kernel: NETDEV WATCHDOG: eth0 (r8152): transmit
queue 0 timed out
Jan 16 05:43:59 xxxx-Server kernel: Modules linked in: pppoe pppox
snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic iptable_raw
ipt_MASQUERADE nf_nat_masquerade_ipv4 xt_nat iptable_nat nf_conntrack_ipv4
Jan 16 05:43:59 xxxx-Server kernel:  snd_soc_rl6231 glue_helper ir_jvc_decoder
ir_rc6_decoder ir_rc5_decoder ablk_helper mei_me cryptd ptp snd_soc_core
i2c_i801 pps_core mei ir_nec_decoder tcp_hybla snd_hda_codec lpc
Jan 16 05:43:59 xxxx-Server kernel: CPU: 3 PID: 0 Comm: swapper/3 Not tainted
4.1.15-1-lts #1
Jan 16 05:43:59 xxxx-Server kernel: Hardware name:                  /D54250WYK,
BIOS WYLPT10H.86A.0040.2015.0612.1400 06/12/2015
Jan 16 05:43:59 xxxx-Server kernel:  0000000000000000 beb90f47a4c3d8aa
ffff88021fb83d58 ffffffff8157d9ba
Jan 16 05:43:59 xxxx-Server kernel:  0000000000000000 ffff88021fb83db0
ffff88021fb83d98 ffffffff810760da
Jan 16 05:43:59 xxxx-Server kernel:  0000000000016240 0000000000000000
ffff880214a24000 0000000000000003
Jan 16 05:43:59 xxxx-Server kernel: Call Trace:
Jan 16 05:43:59 xxxx-Server kernel:  <IRQ>  [<ffffffff8157d9ba>]
dump_stack+0x45/0x57
Jan 16 05:43:59 xxxx-Server kernel:  [<ffffffff810760da>]
warn_slowpath_common+0x8a/0xc0
Jan 16 05:43:59 xxxx-Server kernel:  [<ffffffff81076165>]
warn_slowpath_fmt+0x55/0x70
Jan 16 05:43:59 xxxx-Server kernel:  [<ffffffff814a2d52>]
dev_watchdog+0x252/0x260
Jan 16 05:43:59 xxxx-Server kernel:  [<ffffffff814a2b00>] ?
qdisc_rcu_free+0x40/0x40
Jan 16 05:43:59 xxxx-Server kernel:  [<ffffffff810df539>]
call_timer_fn+0x39/0x110
Jan 16 05:43:59 xxxx-Server kernel:  [<ffffffff814a2b00>] ?
qdisc_rcu_free+0x40/0x40
Jan 16 05:43:59 xxxx-Server kernel:  [<ffffffff810dfb59>]
run_timer_softirq+0x249/0x300
Jan 16 05:43:59 xxxx-Server kernel:  [<ffffffff8107a043>]
__do_softirq+0x103/0x280
Jan 16 05:43:59 xxxx-Server kernel:  [<ffffffff8107a33d>] irq_exit+0xad/0xb0
Jan 16 05:43:59 xxxx-Server kernel:  [<ffffffff81585926>]
smp_apic_timer_interrupt+0x46/0x60
Jan 16 05:43:59 xxxx-Server kernel:  [<ffffffff81583b3e>]
apic_timer_interrupt+0x6e/0x80
Jan 16 05:43:59 xxxx-Server kernel:  <EOI>  [<ffffffff8101d9ed>] ?
native_sched_clock+0x2d/0x90
Jan 16 05:43:59 xxxx-Server kernel:  [<ffffffff81438812>] ?
cpuidle_enter_state+0x92/0x200
Jan 16 05:43:59 xxxx-Server kernel:  [<ffffffff814387e4>] ?
cpuidle_enter_state+0x64/0x200
Jan 16 05:43:59 xxxx-Server kernel:  [<ffffffff814389b7>]
cpuidle_enter+0x17/0x20
Jan 16 05:43:59 xxxx-Server kernel:  [<ffffffff810b8d3c>]
cpu_startup_entry+0x2ec/0x400
Jan 16 05:43:59 xxxx-Server kernel:  [<ffffffff8104d6fe>]
start_secondary+0x18e/0x1d0
Jan 16 05:43:59 xxxx-Server kernel: ---[ end trace 38ac91c079ac54ea ]---

-- 
You are receiving this mail because:
You are the assignee for the bug.
