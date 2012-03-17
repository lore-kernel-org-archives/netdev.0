From: Chris Boot <bootc@bootc.net>
Subject: Re: e1000e interface hang on 82574L
Date: Sat, 17 Mar 2012 17:54:19 +0000
Message-ID: <4F64CFCB.7060702@bootc.net>
References: <4EFA4024.5000909@bootc.net>
	<FCF3184D-CE4F-471C-B66C-0F671795FD3C@bootc.net>
	<9BBC4E0CF881AA4299206E2E1412B626017762@ORSMSX102.amr.corp.intel.com>
	<4F048861.8070501@bootc.net> <4F12B42C.9030803@bootc.net>
	<9BBC4E0CF881AA4299206E2E1412B62621F0B1@ORSMSX102.amr.corp.intel.com>
	<4F144A76.3050703@bootc.net> <4F64B4E2.20208@bootc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
To: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4F64B4E2.20208@bootc.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 17/03/2012 15:59, Chris Boot wrote:
> On 16/01/2012 16:04, Chris Boot wrote:
>> On 16/01/2012 15:56, Wyborny, Carolyn wrote:
>>>
>>>> -----Original Message-----
>>>> From: Chris Boot [mailto:bootc@bootc.net]
>>>> Sent: Sunday, January 15, 2012 3:11 AM
>>>> To: Wyborny, Carolyn
>>>> Cc: netdev; lkml; e1000-devel@lists.sourceforge.net
>>>> Subject: Re: e1000e interface hang on 82574L
>>>>
>>>> On 04/01/2012 17:12, Chris Boot wrote:
>>>>> On 03/01/2012 00:02, Wyborny, Carolyn wrote:
>>>>>>
>>>>>>> -----Original Message-----
>>>>>>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>>>> owner@vger.kernel.org]
>>>>>>> On Behalf Of Chris Boot
>>>>>>> Sent: Saturday, December 31, 2011 1:32 AM
>>>>>>> To: netdev; lkml; e1000-devel@lists.sourceforge.net
>>>>>>> Subject: Re: e1000e interface hang on 82574L
>>>>>>>
>>>>>>> On 27 Dec 2011, at 22:01, Chris Boot wrote:
>>>>>>>
>>>>>>>> Hi folks,
>>>>>>>>
>>>>>>>> Another networking issue I've run into, this time with e1000e
>>>> (Intel
>>>>>>> Corporation 82574L Gigabit). My new VM cluster appears to drop a NIC
>>>> -
>>>>>>> the port stops responding within Linux and shows the link as being
>>>> down
>>>>>>> with ethtool. My ISP says 'Ports running Half Duplex or reduced
>>>> speed'
>>>>>>> on the port.
>>>>>>>> When the port stops working I see this in dmesg:
>>>>>>>>
>>>>>>>> [35481.659629] ------------[ cut here ]------------
>>>>>>>> [35481.667837] WARNING: at net/sched/sch_generic.c:255
>>>>>>> dev_watchdog+0xe9/0x148()
>>>>>>>> [35481.676370] Hardware name: X9SCL/X9SCM
>>>>>>>> [35481.684793] NETDEV WATCHDOG: eth2 (e1000e): transmit queue 0
>>>> timed
>>>>>>> out
>>>>>>>> [35481.684795] Modules linked in: hmac sha256_generic dlm configfs
>>>>>>> ebtable_nat ebtables acpi_cpufreq mperf cpufreq_stats
>>>>>>> cpufreq_conservative cpufreq_userspace cpufreq_powersave microcode
>>>>>>> xt_NOTRACK ip_set_hash_net act_police cls_basic cls_flow cls_fw
>>>> cls_u32
>>>>>>> sch_tbf sch_prio sch_htb sch_hfsc sch_ingress sch_sfq xt_connlimit
>>>>>>> xt_realm xt_addrtype ip_set_hash_ip iptable_raw xt_comment xt_recent
>>>>>>> ipt_ULOG ipt_REJECT ipt_REDIRECT ipt_NETMAP ipt_MASQUERADE ipt_ECN
>>>>>>> ipt_ecn ipt_CLUSTERIP ipt_ah nf_nat_tftp nf_nat_snmp_basic
>>>>>>> nf_conntrack_snmp nf_nat_sip nf_nat_pptp nf_nat_proto_gre nf_nat_irc
>>>>>>> nf_nat_h323 nf_nat_ftp ip6_queue nf_nat_amanda xt_set ip_set
>>>>>>> nf_conntrack_tftp nf_conntrack_sip nf_conntrack_sane
>>>>>>> nf_conntrack_proto_udplite nf_conntrack_proto_sctp nf_conntrack_pptp
>>>>>>> nf_conntrack_proto_gre nf_conntrack_netlink nf_conntrack_netbios_ns
>>>>>>> nf_conntrack_broadcast nf_conntrack_irc nf_conntrack_h323
>>>>>>> nf_conntrack_ftp ts_kmp nf_conntrack_amanda xt_TPROXY xt_NFLOG
>>>>>>> nfnetlink_log nf_tproxy_core xt_time xt_TCPMSS xt_tcpmss xt_sctp
>>>>>>> xt_policy xt_pkttype xt_physdev xt_owner xt_NFQUEUE xt_multiport
>>>> xt_mark
>>>>>>> xt_mac xt_limit xt_length xt_iprange xt_helper xt_hashlimit xt_DSCP
>>>>>>> xt_dscp xt_dccp xt_connmark xt_CLASSIFY xt_AUDIT ip6t_LOG
>>>> ip6t_REJECT
>>>>>>> nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack ip6table_raw ipt_LOG
>>>>>>> xt_tcpudp ip6table_mangle xt_state iptable_nat nf_nat
>>>> nf_conntrack_ipv4
>>>>>>> nf_defrag_ipv4 nf_conntrack iptable_mangle nfnetlink iptable_filter
>>>>>>> ip_tables ip6table_filter ip6_tables x_tables bridge stp bonding
>>>>>>> w83627ehf hwmon_vid coretemp sha1_ssse3 sha1_generic crc32c_intel
>>>>>>> aesni_intel cryptd aes_x86_64 aes_generic ipmi_poweroff ipmi_devintf
>>>>>>> ipmi_si ipmi_msghandler vhost_net macvtap macvlan tun drbd lru_cache
>>>> cn
>>>>>>> loop kvm_intel kvm snd_pcm snd_timer snd iTCO_wdt soundcore psmouse
>>>>>>> snd_page_alloc i2c_i801 i2c_core cdc_acm iTCO_vendor_support joydev
>>>>>>> evdev serio_raw processor button pcspkr thermal_sys ext4 mbcache
>>>> jbd2
>>>>>>> crc16 dm_mod raid1 md_mod sd_mod crc_t10dif usb_storage uas usbhid
>>>> hid
>>>>>>> ahci libahci libata igb ehci_hcd scsi_mod usbcore e1000e dca
>>>> usb_common
>>>>>>> [last unloaded: scsi_wait_scan]
>>>>>>>> [35481.685740] Pid: 0, comm: swapper/4 Not tainted 3.2.0-rc6+ #4
>>>>>>>> [35481.685744] Call Trace:
>>>>>>>> [35481.685746]<IRQ>   [<ffffffff810467ed>] ?
>>>>>>> warn_slowpath_common+0x78/0x8c
>>>>>>>> [35481.685849] [<ffffffff81046899>] ? warn_slowpath_fmt+0x45/0x4a
>>>>>>>> [35481.685875] [<ffffffff810aeaa0>] ?
>>>>>>> perf_event_task_tick+0x166/0x1ab
>>>>>>>> [35481.686018] [<ffffffff81294219>] ? netif_tx_lock+0x40/0x72
>>>>>>>> [35481.686090] [<ffffffff8129437a>] ? dev_watchdog+0xe9/0x148
>>>>>>>> [35481.686136] [<ffffffff81051e58>] ? run_timer_softirq+0x19a/0x261
>>>>>>>> [35481.686176] [<ffffffff81294291>] ? netif_tx_unlock+0x46/0x46
>>>>>>>> [35481.686215] [<ffffffff810659bb>] ? timekeeping_get_ns+0xd/0x2a
>>>>>>>> [35481.686286] [<ffffffff8104bdd4>] ? __do_softirq+0xb9/0x177
>>>>>>>> [35481.686365] [<ffffffff81341d6c>] ? call_softirq+0x1c/0x30
>>>>>>>> [35481.686530] [<ffffffff8100f841>] ? do_softirq+0x3c/0x7b
>>>>>>>> [35481.686580] [<ffffffff8104c03c>] ? irq_exit+0x3c/0x9a
>>>>>>>> [35481.686742] [<ffffffff81023e58>] ?
>>>>>>> smp_apic_timer_interrupt+0x74/0x82
>>>>>>>> [35481.686820] [<ffffffff813405de>] ?
>>>> apic_timer_interrupt+0x6e/0x80
>>>>>>>> [35481.686826]<EOI>   [<ffffffff811ddf49>] ? intel_idle+0xea/0x119
>>>>>>>> [35481.686991] [<ffffffff811ddf28>] ? intel_idle+0xc9/0x119
>>>>>>>> [35481.687051] [<ffffffff8125dce3>] ? cpuidle_idle_call+0xec/0x179
>>>>>>>> [35481.687089] [<ffffffff8100d255>] ? cpu_idle+0xa1/0xe8
>>>>>>>> [35481.687143] [<ffffffff810706ee>] ?
>>>> arch_local_irq_restore+0x2/0x8
>>>>>>>> [35481.687189] [<ffffffff8132d191>] ? start_secondary+0x1d5/0x1db
>>>>>>>> [35481.687234] ---[ end trace 01e9907674757948 ]---
>>>>>>>> [35481.687817] e1000e 0000:05:00.0: eth2: Reset adapter
>>>>>>>>
>>>>>>>> To try to regain connectivity I bring down the bond and the
>>>> interface
>>>>>>> (eth2), then unload e1000e. Upon loading the module again:
>>>>>>>> [36021.888962] e1000e: Intel(R) PRO/1000 Network Driver - 1.5.1-k
>>>>>>>> [36021.900258] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
>>>>>>>> [36021.911446] e1000e 0000:00:19.0: PCI INT A ->   GSI 20 (level,
>>>> low) -
>>>>>>>> IRQ 20
>>>>>>>> [36021.923204] e1000e 0000:00:19.0: setting latency timer to 64
>>>>>>>> [36021.923372] e1000e 0000:00:19.0: irq 45 for MSI/MSI-X
>>>>>>>> [36022.202737] e1000e 0000:00:19.0: eth2: (PCI
>>>> Express:2.5GT/s:Width
>>>>>>> x1) 00:25:90:56:ac:75
>>>>>>>> [36022.214480] e1000e 0000:00:19.0: eth3: Intel(R) PRO/1000 Network
>>>>>>> Connection
>>>>>>>> [36022.227506] e1000e 0000:00:19.0: eth3: MAC: 10, PHY: 11, PBA No:
>>>>>>> FFFFFF-0FF
>>>>>>>> [36022.239789] e1000e 0000:05:00.0: Disabling ASPM L0s
>>>>>>>> [36022.239805] e1000e 0000:05:00.0: enabling device (0000 ->   0002)
>>>>>>>> [36022.239829] e1000e 0000:05:00.0: PCI INT A ->   GSI 16 (level,
>>>> low) -
>>>>>>>> IRQ 16
>>>>>>>> [36022.239921] e1000e 0000:05:00.0: setting latency timer to 64
>>>>>>>> [36022.240963] e1000e 0000:05:00.0: irq 64 for MSI/MSI-X
>>>>>>>> [36022.240995] e1000e 0000:05:00.0: irq 65 for MSI/MSI-X
>>>>>>>> [36022.241028] e1000e 0000:05:00.0: irq 66 for MSI/MSI-X
>>>>>>>> [36022.241596] e1000e 0000:05:00.0: PCI INT A disabled
>>>>>>>> [36022.241606] e1000e: probe of 0000:05:00.0 failed with error -2
>>>>>>>> [36022.304706] udevd[3634]: renamed network interface eth2 to eth3
>>>>>>>>
>>>>>>>> I then don't get an eth2 interface. Only a reboot brings the
>>>> interface
>>>>>>> back. This has happened twice so far on this server in the past
>>>> week,
>>>>>>> both times using v3.2-rc7-3-g4962516.
>>>>>>>> lspci -vnn shows:
>>>>>>>>
>>>>>>>> 05:00.0 Ethernet controller [0200]: Intel Corporation 82574L
>>>> Gigabit
>>>>>>> Network Connection [8086:10d3]
>>>>>>>> Subsystem: Super Micro Computer Inc Device [15d9:0000]
>>>>>>>> Flags: bus master, fast devsel, latency 0, IRQ 16
>>>>>>>> Memory at fbd00000 (32-bit, non-prefetchable) [size=128K]
>>>>>>>> I/O ports at e000 [size=32]
>>>>>>>> Memory at fbd20000 (32-bit, non-prefetchable) [size=16K]
>>>>>>>> Capabilities: [c8] Power Management version 2
>>>>>>>> Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
>>>>>>>> Capabilities: [e0] Express Endpoint, MSI 00
>>>>>>>> Capabilities: [a0] MSI-X: Enable+ Count=5 Masked-
>>>>>>>> Capabilities: [100] Advanced Error Reporting
>>>>>>>> Capabilities: [140] Device Serial Number 00-25-90-ff-ff-56-ac-
>>>>>>> 74
>>>>>>>> Kernel driver in use: e1000e
>>>>>>> I've just had this happen on my other (identical) server with a
>>>> nearly
>>>>>>> identical trace. Is there anything I can do do avoid this at all or
>>>> at
>>>>>>> least help narrow down the problem?
>>>>>>>
>>>>>>> Cheers,
>>>>>>> Chris
>>>>>>>
>>>>>>> -- 
>>>>>>> Chris Boot
>>>>>>> bootc@bootc.net
>>>>>>>
>>>>>>> -- 
>>>>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>>>>>> Hello,
>>>>>>
>>>>>> Sorry for the delay in responding. We have seen some hang issues
>>>> using
>>>>>> MSI-X on 82574 parts. Can you try reloading the driver the IntMode
>>>>>> module parameter. IntMode=1 (you'll need a setting for each device in
>>>>>> the system so two adapters would be IntMode=1,1) See if that changes
>>>>>> the symptom you are seeing with this part. That setting will make
>>>> sure
>>>>>> the adapter uses MSI interrupts instead of MSI-X.
>>>>> Carolyn,
>>>>>
>>>>> I'll give this a go next time I reproduce it. I built a new kernel
>>>> with
>>>>> more debugging and so far it hasn't yet triggered again...
>>>> Upgrading to a more recent 3.2-rc snapshot seems to have cured the
>>>> problem - I haven't had an interface stop responding since. Must have
>>>> been some seemingly unrelated patch that I can't seem to locate.
>>>>
>>>> Cheers,
>>>> Chris
>>>>
>>>> -- 
>>>> Chris Boot
>>>> bootc@bootc.net
>>> Thanks for letting me know Chris.  For my own edification, are you
>>> still configured with MSI-X?
>> Carolyn,
>>
>> I have made no changes to my configuration to change the interrupt
>> format. I see the following in dmesg at boot:
>>
>> [    3.276819] e1000e: Intel(R) PRO/1000 Network Driver - 1.5.1-k
>> [    3.288193] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
>>
>> [    3.299842] e1000e 0000:00:19.0: PCI INT A ->  GSI 20 (level, low)
>> ->  IRQ 20
>> [    3.299909] e1000e 0000:00:19.0: setting latency timer to 64
>> [    3.352929] e1000e 0000:00:19.0: irq 45 for MSI/MSI-X
>> [    3.710080] e1000e 0000:00:19.0: eth2: (PCI Express:2.5GT/s:Width
>> x1) 00:25:90:56:ac:75
>> [    3.710082] e1000e 0000:00:19.0: eth2: Intel(R) PRO/1000 Network
>> Connection
>> [    3.710670] e1000e 0000:00:19.0: eth2: MAC: 10, PHY: 11, PBA No:
>> FFFFFF-0FF
>>
>> [    3.710678] e1000e 0000:05:00.0: Disabling ASPM L0s
>> [    3.710850] e1000e 0000:05:00.0: PCI INT A ->  GSI 16 (level, low)
>> ->  IRQ 16
>> [    3.710951] e1000e 0000:05:00.0: setting latency timer to 64
>> [    3.712757] e1000e 0000:05:00.0: irq 64 for MSI/MSI-X
>> [    3.712787] e1000e 0000:05:00.0: irq 65 for MSI/MSI-X
>> [    3.712805] e1000e 0000:05:00.0: irq 66 for MSI/MSI-X
>> [    3.830364] e1000e 0000:05:00.0: eth3: (PCI Express:2.5GT/s:Width
>> x1) 00:25:90:56:ac:74
>> [    3.830366] e1000e 0000:05:00.0: eth3: Intel(R) PRO/1000 Network
>> Connection
>> [    3.830510] e1000e 0000:05:00.0: eth3: MAC: 3, PHY: 8, PBA No:
>> FFFFFF-0FF
>>
>> /proc/interrupts shows:
>>
>>   45:     615958          0          0          0          0          0
>>           0          0  IR-PCI-MSI-edge      eth3
>>   64:   65126106          0          0          0          0          0
>>           0          0  IR-PCI-MSI-edge      eth2-rx-0
>>   65:   52700392          0          0          0          0          0
>>           0          0  IR-PCI-MSI-edge      eth2-tx-0
>>   66:          2          0          0          0          0          0
>>           0          0  IR-PCI-MSI-edge      eth2
> Carolyn,
>
> I've just had the opportunity to upgrade to a 3.2.9 kernel on these
> systems and have made sure e1000e is loaded with IntMode=1,1. One of the
> servers was only up 5.5 hours before the NIC has crashed/stopped working
> again.
>
> Here is the latest dmesg after the failure:
>
> [    3.254553] e1000e: Intel(R) PRO/1000 Network Driver - 1.5.1-k
> [    3.265852] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
> [    3.266034] e1000e 0000:00:19.0: PCI INT A ->  GSI 20 (level, low) ->
> IRQ 20
> [    3.266067] e1000e 0000:00:19.0: setting latency timer to 64
> [    3.266460] e1000e 0000:00:19.0: (unregistered net_device): Interrupt
> Mode set to 1
> [    3.266800] e1000e 0000:00:19.0: irq 45 for MSI/MSI-X
> [    3.611840] e1000e 0000:00:19.0: eth2: (PCI Express:2.5GT/s:Width x1)
> 00:25:90:56:ac:75
> [    3.611855] e1000e 0000:00:19.0: eth2: Intel(R) PRO/1000 Network
> Connection
> [    3.612303] e1000e 0000:00:19.0: eth2: MAC: 10, PHY: 11, PBA No:
> FFFFFF-0FF
> [    3.612350] e1000e 0000:05:00.0: Disabling ASPM L0s
> [    3.612594] e1000e 0000:05:00.0: PCI INT A ->  GSI 16 (level, low) ->
> IRQ 16
> [    3.612812] e1000e 0000:05:00.0: setting latency timer to 64
> [    3.613582] e1000e 0000:05:00.0: (unregistered net_device): Interrupt
> Mode set to 1
> [    3.614156] e1000e 0000:05:00.0: irq 64 for MSI/MSI-X
> [    3.734442] e1000e 0000:05:00.0: eth3: (PCI Express:2.5GT/s:Width x1)
> 00:25:90:56:ac:74
> [    3.734465] e1000e 0000:05:00.0: eth3: Intel(R) PRO/1000 Network
> Connection
> [    3.734689] e1000e 0000:05:00.0: eth3: MAC: 3, PHY: 8, PBA No: FFFFFF-0FF
> [   13.799848] e1000e 0000:05:00.0: irq 64 for MSI/MSI-X
> [   13.855646] e1000e 0000:05:00.0: irq 64 for MSI/MSI-X
> [   14.031739] e1000e 0000:00:19.0: irq 45 for MSI/MSI-X
> [   14.087566] e1000e 0000:00:19.0: irq 45 for MSI/MSI-X
> [   16.112504] e1000e: eth2 NIC Link is Up 100 Mbps Full Duplex, Flow
> Control: None
> [   16.124129] e1000e 0000:05:00.0: eth2: 10/100 speed: disabling TSO
>
> And here is the output just as it hangs:
>
> [19745.327241] ------------[ cut here ]------------
> [19745.334501] WARNING: at
> /build/buildd-linux-2.6_3.2.9-1-amd64-KTPapN/linux-2.6-3.2.9/debian/build/source_amd64_none/net/sched/sch_generic.c:255
> dev_watchdog+0xe9/0x148()
> [19745.350441] Hardware name: X9SCL/X9SCM
> [19745.358859] NETDEV WATCHDOG: eth2 (e1000e): transmit queue 0 timed out
> [19745.367287] Modules linked in: hmac sha256_generic dlm configfs
> ebtable_nat ebtables acpi_cpufreq mperf cpufreq_stats
> cpufreq_conservative cpufreq_userspace cpufreq_powersave microcode
> ip6_queue xt_TCPMSS xt_sctp ip6t_LOG ip6t_REJECT nf_conntrack_ipv6
> ip6table_raw ip6table_mangle ip6table_filter xt_NOTRACK ip_set_hash_net
> act_police cls_basic cls_flow cls_fw cls_u32 sch_tbf sch_prio sch_htb
> sch_hfsc sch_ingress sch_sfq xt_statistic xt_CT xt_time xt_connlimit
> xt_realm xt_addrtype ip_set_hash_ip iptable_raw xt_comment xt_recent
> xt_policy ipt_ULOG ipt_REJECT ipt_REDIRECT ipt_NETMAP ipt_MASQUERADE
> ipt_ECN ipt_ecn ipt_CLUSTERIP ipt_ah xt_set ip_set nf_nat_tftp
> nf_nat_snmp_basic nf_conntrack_snmp nf_nat_sip nf_nat_pptp
> nf_nat_proto_gre nf_nat_irc nf_nat_h323 nf_nat_ftp nf_nat_amanda ts_kmp
> nf_conntrack_amanda nf_conntrack_sane nf_conntrack_tftp nf_conntrack_sip
> nf_conntrack_proto_udplite nf_conntrack_proto_sctp nf_conntrack_pptp
> nf_conntrack_proto_gre nf_conntrack_netlink nf_conntrack_netbios_ns
> nf_conntrack_broadcast nf_conntrack_irc nf_conntrack_h323
> nf_conntrack_ftp xt_TPROXY nf_tproxy_core ip6_tables nf_defrag_ipv6
> xt_tcpmss xt_pkttype xt_physdev xt_owner xt_NFQUEUE xt_NFLOG
> nfnetlink_log xt_multiport xt_mark xt_mac xt_limit xt_length xt_iprange
> xt_helper xt_hashlimit xt_DSCP xt_dscp xt_dccp xt_conntrack xt_connmark
> xt_CLASSIFY xt_AUDIT ipt_LOG xt_tcpudp xt_state iptable_nat nf_nat
> nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack iptable_mangle nfnetlink
> iptable_filter ip_tables x_tables kvm_intel kvm bridge stp bonding
> w83627ehf hwmon_vid coretemp sha1_ssse3 sha1_generic crc32c_intel
> aesni_intel cryptd aes_x86_64 aes_generic ipmi_poweroff ipmi_devintf
> ipmi_si ipmi_msghandler vhost_net macvtap macvlan tun drbd lru_cache cn
> loop snd_pcm snd_timer snd soundcore snd_page_alloc iTCO_wdt i2c_i801
> psmouse cdc_acm processor i2c_core iTCO_vendor_support serio_raw pcspkr
> thermal_sys button evdev joydev ext4 mbcache jbd2 crc16 dm_mod raid1
> md_mod sd_mod crc_t10dif usb_storage uas usbhid hid ahci libahci libata
> ehci_hcd usbcore igb scsi_mod e1000e usb_common dca [last unloaded:
> scsi_wait_scan]
> [19745.502559] Pid: 0, comm: swapper/0 Not tainted 3.2.0-2-amd64 #1
> [19745.502561] Call Trace:
> [19745.502562]<IRQ>   [<ffffffff81046879>] ? warn_slowpath_common+0x78/0x8c
> [19745.502570]  [<ffffffff81046925>] ? warn_slowpath_fmt+0x45/0x4a
> [19745.502574]  [<ffffffff8129aa11>] ? netif_tx_lock+0x40/0x72
> [19745.502588]  [<ffffffff8129ab72>] ? dev_watchdog+0xe9/0x148
> [19745.502601]  [<ffffffff81051f38>] ? run_timer_softirq+0x19a/0x261
> [19745.502603]  [<ffffffff8129aa89>] ? netif_tx_unlock+0x46/0x46
> [19745.502606]  [<ffffffff81065a73>] ? timekeeping_get_ns+0xd/0x2a
> [19745.502609]  [<ffffffff8104be98>] ? __do_softirq+0xb9/0x177
> [19745.502612]  [<ffffffff8134892c>] ? call_softirq+0x1c/0x30
> [19745.502615]  [<ffffffff8100f8e5>] ? do_softirq+0x3c/0x7b
> [19745.502617]  [<ffffffff8104c100>] ? irq_exit+0x3c/0x9a
> [19745.502621]  [<ffffffff81023f18>] ? smp_apic_timer_interrupt+0x74/0x82
> [19745.502624]  [<ffffffff8134719e>] ? apic_timer_interrupt+0x6e/0x80
> [19745.502625]<EOI>   [<ffffffff81070761>] ? arch_local_irq_save+0x11/0x17
> [19745.502631]  [<ffffffff811e45d9>] ? intel_idle+0xea/0x119
> [19745.502633]  [<ffffffff811e45b8>] ? intel_idle+0xc9/0x119
> [19745.502637]  [<ffffffff812643f7>] ? cpuidle_idle_call+0xec/0x179
> [19745.502639]  [<ffffffff8100d248>] ? cpu_idle+0xa5/0xf2
> [19745.502641]  [<ffffffff816aab3d>] ? start_kernel+0x3bd/0x3c8
> [19745.502643]  [<ffffffff816aa140>] ? early_idt_handlers+0x140/0x140
> [19745.502645]  [<ffffffff816aa3c4>] ? x86_64_start_kernel+0x104/0x111
> [19745.502646] ---[ end trace 10e791a6f31603fa ]---
> [19745.503125] e1000e 0000:05:00.0: eth2: Reset adapter
>
> Once again, rmmod e1000e followed by modprobe e1000e does not fix the
> problem:
>
> [20508.158919] e1000e 0000:05:00.0: PCI INT A disabled
> [20508.194927] e1000e 0000:00:19.0: PCI INT A disabled
> [20511.119765] e1000e: Intel(R) PRO/1000 Network Driver - 1.5.1-k
> [20511.130711] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
> [20511.141206] e1000e 0000:00:19.0: PCI INT A ->  GSI 20 (level, low) ->
> IRQ 20
> [20511.151797] e1000e 0000:00:19.0: setting latency timer to 64
> [20511.151921] e1000e 0000:00:19.0: (unregistered net_device): Interrupt
> Mode set to 1
> [20511.162853] e1000e 0000:00:19.0: irq 45 for MSI/MSI-X
> [20511.528436] e1000e 0000:00:19.0: eth2: (PCI Express:2.5GT/s:Width x1)
> 00:25:90:56:ac:75
> [20511.539261] e1000e 0000:00:19.0: eth3: Intel(R) PRO/1000 Network
> Connection
> [20511.550066] e1000e 0000:00:19.0: eth3: MAC: 10, PHY: 11, PBA No:
> FFFFFF-0FF
> [20511.561027] e1000e 0000:05:00.0: Disabling ASPM L0s
> [20511.571883] e1000e 0000:05:00.0: enabling device (0000 ->  0002)
> [20511.575224] udevd[5449]: renamed network interface eth2 to eth3
> [20511.594234] e1000e 0000:05:00.0: PCI INT A ->  GSI 16 (level, low) ->
> IRQ 16
> [20511.605703] e1000e 0000:05:00.0: setting latency timer to 64
> [20511.605871] e1000e 0000:05:00.0: (unregistered net_device): Interrupt
> Mode set to 1
> [20511.617706] e1000e 0000:05:00.0: irq 64 for MSI/MSI-X
> [20511.617828] e1000e 0000:05:00.0: PCI INT A disabled
> [20511.629565] e1000e: probe of 0000:05:00.0 failed with error -2
>
> Please let me know if/how I can debug this further.

As further information, I have a machine with the same NIC and chipset 
(Intel S1200BTL motherboard) but with quite different lspci -vvv 
outputs. Both are pasted below.

First, from the working S1200BTL:

03:00.0 Ethernet controller: Intel Corporation 82574L Gigabit Network 
Connection
         Subsystem: Intel Corporation Device 3578
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr+ Stepping- SERR+ FastB2B- DisINTx+
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0, Cache Line Size: 64 bytes
         Interrupt: pin A routed to IRQ 16
         Region 0: Memory at c1300000 (32-bit, non-prefetchable) [size=128K]
         Region 2: I/O ports at 2000 [size=32]
         Region 3: Memory at c1320000 (32-bit, non-prefetchable) [size=16K]
         Capabilities: [c8] Power Management version 2
                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
         Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
                 Address: 0000000000000000  Data: 0000
         Capabilities: [e0] Express (v1) Endpoint, MSI 00
                 DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s 
<512ns, L1 <64us
                         ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                 DevCtl: Report errors: Correctable+ Non-Fatal+ Fatal+ 
Unsupported+
                         RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                         MaxPayload 128 bytes, MaxReadReq 512 bytes
                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- 
AuxPwr+ TransPend-
                 LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, 
Latency L0 <128ns, L1 <64us
                         ClockPM- Surprise- LLActRep- BwNot-
                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- 
CommClk+
                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ 
DLActive- BWMgmt- ABWMgmt-
         Capabilities: [a0] MSI-X: Enable+ Count=5 Masked-
                 Vector table: BAR=3 offset=00000000
                 PBA: BAR=3 offset=00002000
         Capabilities: [100 v1] Advanced Error Reporting
                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
                 UESvrt: DLP+ SDES- TLP+ FCP+ CmpltTO+ CmpltAbrt+ 
UnxCmplt+ RxOF+ MalfTLP+ ECRC- UnsupReq+ ACSViol-
                 CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- 
NonFatalErr-
                 CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- 
NonFatalErr+
                 AERCap: First Error Pointer: 00, GenCap- CGenEn- 
ChkCap- ChkEn-
         Capabilities: [140 v1] Device Serial Number 00-1e-67-ff-ff-14-69-f4
         Kernel driver in use: e1000e

And from the Supermicro server, where the NIC hangs:

05:00.0 Ethernet controller: Intel Corporation 82574L Gigabit Network 
Connection
         Subsystem: Super Micro Computer Inc Device 0000
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR- FastB2B- DisINTx+
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0, Cache Line Size: 64 bytes
         Interrupt: pin A routed to IRQ 65
         Region 0: Memory at fbd00000 (32-bit, non-prefetchable) [size=128K]
         Region 2: I/O ports at e000 [size=32]
         Region 3: Memory at fbd20000 (32-bit, non-prefetchable) [size=16K]
         Capabilities: [c8] Power Management version 2
                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
         Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
                 Address: 00000000fee00858  Data: 0000
         Capabilities: [e0] Express (v1) Endpoint, MSI 00
                 DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s 
<512ns, L1 <64us
                         ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                 DevCtl: Report errors: Correctable+ Non-Fatal+ Fatal+ 
Unsupported+
                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
                         MaxPayload 128 bytes, MaxReadReq 512 bytes
                 DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ 
AuxPwr+ TransPend-
                 LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, 
Latency L0 <128ns, L1 <64us
                         ClockPM- Surprise- LLActRep- BwNot-
                 LnkCtl: ASPM L1 Enabled; RCB 64 bytes Disabled- 
Retrain- CommClk+
                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ 
DLActive- BWMgmt- ABWMgmt-
         Capabilities: [a0] MSI-X: Enable- Count=5 Masked-
                 Vector table: BAR=3 offset=00000000
                 PBA: BAR=3 offset=00002000
         Capabilities: [100 v1] Advanced Error Reporting
                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                 UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                 CESta:  RxErr+ BadTLP+ BadDLLP+ Rollover- Timeout- 
NonFatalErr+
                 CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- 
NonFatalErr+
                 AERCap: First Error Pointer: 14, GenCap- CGenEn- 
ChkCap- ChkEn-
         Capabilities: [140 v1] Device Serial Number 00-25-90-ff-ff-56-ac-74
         Kernel driver in use: e1000e

Most notably it appears as though MSI-X is not enabled on the 
Supermicro, and ASPM L1 is. There appears to be no difference on the 
Supermicro as to the MSI-X status when booting with IntMode=1,1 compared 
to without it.

Thanks,
Chris


------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
