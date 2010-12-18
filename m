From: Brian Neu <proclivity76@yahoo.com>
Subject: e1000e crash with 82574L  2.6.37-0.rc5
Date: Sat, 18 Dec 2010 10:12:38 -0800 (PST)
Message-ID: <128120.41188.qm@web39307.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web39307.mail.mud.yahoo.com ([66.94.238.174]:41080 "HELO
	web39307.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932084Ab0LRSTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Dec 2010 13:19:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is this a known bug?
Any fix out there?

[162536.704103] WARNING: at net/sched/sch_generic.c:258  
dev_watchdog+0x111/0x185()  [162536.704110] Hardware name: H8SGL  
[162536.704116] NETDEV WATCHDOG: eth0 (e1000e): transmit queue 0 timed out  
[162536.704122] Modules linked in: ip6table_filter ebtable_nat ebtables  
act_police cls_flow cls_fw cls_u32 sch_htb sch_hfsc sch_ingress sch_sfq bridge  
stp llc xt_time xt_connlimit xt_realm iptable_raw xt_comment xt_recent  
xt_policy ipt_ULOG ipt_REDIRECT ipt_NETMAP ipt_MASQUERADE ipt_ECN ipt_ecn  
ipt_CLUSTERIP ipt_ah ipt_addrtype nf_nat_tftp nf_nat_snmp_basic nf_nat_sip  
nf_nat_pptp nf_nat_proto_gre nf_nat_irc nf_nat_h323 nf_nat_ftp nf_nat_amanda  
ts_kmp nf_conntrack_amanda nf_conntrack_sane nf_conntrack_tftp nf_conntrack_sip  
nf_conntrack_proto_sctp nf_conntrack_pptp nf_conntrack_proto_gre  
nf_conntrack_netlink nf_conntrack_netbios_ns nf_conntrack_irc nf_conntrack_h323  
nf_conntrack_ftp xt_TPROXY nf_tproxy_core ip6_tables nf_defrag_ipv6 xt_tcpmss  
xt_pkttype xt_physdev xt_owner xt_NFQUEUE xt_NFLOG nfnetlink_log xt_multiport  
xt_mark xt_mac xt_limit xt_length xt_iprange xt_helper xt_hashlimit xt_DSCP  
xt_dscp xt_dccp xt_connmark xt_CLASSIFY ipt_LOG iptable_nat nf_nat  
iptable_mangle nfnetlink  fuse tun sunrpc cpufreq_ondemand powernow_k8 
freq_table mperf ipv6 kvm_amd kvm  uinput amd64_edac_mod edac_core e1000e 
edac_mce_amd i2c_piix4 i2c_core k10temp  ghes hed joydev microcode btrfs 
zlib_deflate libcrc32c raid1 pata_acpi  ata_generic sata_promise pata_atiixp 
sata_sil24 uas usb_storage [last unloaded:  scsi_wait_scan]  [162536.704368] 
Pid: 0, comm: kworker/0:0 Not tainted  2.6.37-0.rc5.git2.1.fc13.x86_64 #1  
[162536.704375] Call Trace:  [162536.704380]  <IRQ>  [<ffffffff81052e29>] 
warn_slowpath_common+0x85/0x9d  [162536.704406]  [<ffffffff81052ee4>] 
warn_slowpath_fmt+0x46/0x48  [162536.704418]  [<ffffffff81419f70>] 
dev_watchdog+0x111/0x185  [162536.704430]  [<ffffffff8105fdcf>] 
run_timer_softirq+0x246/0x33f  [162536.704441]  [<ffffffff8105fd29>] ? 
run_timer_softirq+0x1a0/0x33f  [162536.704452]  [<ffffffff81419e5f>] ? 
dev_watchdog+0x0/0x185  [162536.704463]  [<ffffffff81059746>] 
__do_softirq+0x101/0x20c  [162536.704474]  [<ffffffff81011aa6>] ? 
native_sched_clock+0x2d/0x5f  [162536.704484]  [<ffffffff8100bc1c>] 
call_softirq+0x1c/0x30  [162536.704493]  [<ffffffff8100d29f>] 
do_softirq+0x4b/0xa3  [162536.704502]  [<ffffffff81059480>] irq_exit+0x57/0x9b  
[162536.704514]  [<ffffffff814bf93c>] smp_apic_timer_interrupt+0x8d/0x9b  
[162536.704523]  [<ffffffff8100b6d3>] apic_timer_interrupt+0x13/0x20  
[162536.704529]  <EOI>  [<ffffffff81012686>] ? default_idle+0x3e/0x65  
[162536.704549]  [<ffffffff8102d159>] ? native_safe_halt+0xb/0xd  
[162536.704560]  [<ffffffff810816ee>] ? trace_hardirqs_on+0xd/0xf  
[162536.704571]  [<ffffffff8101268b>] default_idle+0x43/0x65  [162536.704581]  
[<ffffffff81009c81>] cpu_idle+0xbe/0x132  [162536.704592]  [<ffffffff814af9ea>] 
start_secondary+0x242/0x244

