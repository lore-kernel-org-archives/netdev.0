From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 40372] New: Driver pegasus freeze networking
 very often so one must reboot to get it to work again
Date: Fri, 26 Aug 2011 15:00:13 -0700
Message-ID: <20110826150013.197e390a.akpm@linux-foundation.org>
References: <bug-40372-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	Petko Manolov <petkan-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	csanyipal-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jmm-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <bug-40372-10286-3bo0kxnWaOQUvHkbgXJLS5sdmw4N0Rt+2LY78lusg7I@public.gmane.org/>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 31 Jul 2011 20:05:09 GMT
bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=40372
> 
>            Summary: Driver pegasus freeze networking very often so one
>                     must reboot to get it to work again
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: Linux 2.6.38-2-486 #1 Sun May 8 14:04:15 UTC 2011 i586
>                     GNU/Linux
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network-ztI5WcYan/vQLgFONoPN62D2FQJk+8+b@public.gmane.org
>         ReportedBy: csanyipal-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
>                 CC: jmm-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org
>         Regression: No
> 
> 
> Hi,
> 
> the driver pegasus freezes networking often so one must to reboot to get
> networking work again. 
> 
> At reboot the system hang.
> 
> At this point one must press the Reset button of the PC Box because 
> the system hangs forever. I can't see any messages on the console screen when I
> want to reboot at point when system freezes.
> 
> I'm interested to solve this problem.
> Bellow are the informations that I collect but I'm waiting for advices how to
> add more informations here too.
> 
> ** In the kern.log I can see followings:
> 
> Jul 31 18:25:22 cspdebsid kernel: [ 1033.112136] usb 1-1: new full speed USB
> device using ohci_hcd and address 2
> Jul 31 18:25:22 cspdebsid kernel: [ 1033.330106] usb 1-1: New USB device found,
> idVendor=07a6, idProduct=8515
> Jul 31 18:25:22 cspdebsid kernel: [ 1033.330138] usb 1-1: New USB device
> strings: Mfr=1, Product=2, SerialNumber=3
> Jul 31 18:25:22 cspdebsid kernel: [ 1033.330160] usb 1-1: Product: USB To LAN
> Converter
> Jul 31 18:25:22 cspdebsid kernel: [ 1033.330178] usb 1-1: Manufacturer: ADMtek
> Jul 31 18:25:22 cspdebsid kernel: [ 1033.330195] usb 1-1: SerialNumber: 0001
> Jul 31 18:25:26 cspdebsid kernel: [ 1037.203598] pegasus: v0.6.14 (2006/09/27),
> Pegasus/Pegasus II USB Ethernet driver
> Jul 31 18:25:26 cspdebsid kernel: [ 1037.238457] pegasus 1-1:1.0: setup Pegasus
> II specific registers
> Jul 31 18:25:26 cspdebsid kernel: [ 1037.407345] pegasus 1-1:1.0: eth0, ADMtek
> ADM8515 "Pegasus II" USB-2.0 Ethernet, 00:0
> 0:70:01:11:f1
> Jul 31 18:25:26 cspdebsid kernel: [ 1037.413433] usbcore: registered new
> interface driver pegasus
> Jul 31 18:25:30 cspdebsid kernel: [ 1041.036887] pegasus 1-1:1.0: eth0:
> update_eth_regs_async, status -22
> Jul 31 18:25:30 cspdebsid kernel: [ 1041.037045] pegasus 1-1:1.0: eth0:
> update_eth_regs_async, status -22
> Jul 31 18:25:30 cspdebsid kernel: [ 1041.037558] pegasus 1-1:1.0: eth0:
> update_eth_regs_async, status -22
> Jul 31 18:25:40 cspdebsid kernel: [ 1051.616109] eth0: no IPv6 routers present
> 
> ** Loaded modules:
> Module                  Size  Used by
> pegasus                17683  0 
> mii                    12562  1 pegasus
> act_police             12592  0 
> cls_flow               12970  0 
> cls_fw                 12775  0 
> cls_u32                12816  0 
> sch_tbf                12812  0 
> sch_prio               12971  0 
> sch_htb                17475  0 
> sch_hfsc               21835  0 
> sch_ingress            12648  0 
> sch_sfq                12910  0 
> xt_time                12419  0 
> xt_connlimit           12498  0 
> xt_realm               12391  0 
> iptable_raw            12476  0 
> xt_comment             12395  19 
> xt_recent              12862  0 
> xt_policy              12458  0 
> ipt_ULOG               12561  0 
> ipt_REJECT             12425  4 
> ipt_REDIRECT           12431  0 
> ipt_NETMAP             12425  0 
> ipt_MASQUERADE         12530  0 
> ipt_ECN                12416  0 
> ipt_ecn                12416  0 
> ipt_CLUSTERIP          12835  0 
> ipt_ah                 12413  0 
> ipt_addrtype           12473  3 
> nf_nat_tftp            12390  0 
> nf_nat_snmp_basic      16793  0 
> nf_nat_sip             12788  0 
> nf_nat_pptp            12506  0 
> nf_nat_proto_gre       12469  1 nf_nat_pptp
> nf_nat_irc             12414  0 
> nf_nat_h323            12719  0 
> nf_nat_ftp             12420  0 
> nf_nat_amanda          12392  0 
> ts_kmp                 12479  5 
> nf_conntrack_amanda    12405  1 nf_nat_amanda
> nf_conntrack_sane      12396  0
> nf_conntrack_tftp      12401  1 nf_nat_tftp
> nf_conntrack_sip       17500  1 nf_nat_sip
> nf_conntrack_proto_sctp    12734  0 
> nf_conntrack_pptp      12620  1 nf_nat_pptp
> nf_conntrack_proto_gre    12803  1 nf_conntrack_pptp
> nf_conntrack_netlink    22091  0 
> nf_conntrack_netbios_ns    12402  0 
> nf_conntrack_irc       12395  1 nf_nat_irc
> nf_conntrack_h323      37918  1 nf_nat_h323
> nf_conntrack_ftp       12508  1 nf_nat_ftp
> xt_TPROXY              12702  0 
> nf_tproxy_core         12380  1 xt_TPROXY,[permanent]
> ip6_tables             17069  1 xt_TPROXY
> nf_defrag_ipv6         12661  1 xt_TPROXY
> xt_tcpmss              12393  0 
> xt_pkttype             12395  0 
> xt_physdev             12428  0 
> xt_owner               12391  0 
> xt_NFQUEUE             12461  0 
> xt_NFLOG               12422  0 
> nfnetlink_log          12891  1 xt_NFLOG
> xt_multiport           12470  4 
> xt_mark                12413  1 
> xt_mac                 12387  0 
> xt_limit               12484  0 
> xt_length              12420  0 
> xt_iprange             12456  0 
> xt_helper              12459  0 
> xt_hashlimit           12948  0 
> xt_DSCP                12491  0 
> xt_dscp                12467  0 
> xt_dccp                12450  0 
> xt_conntrack           12535  8 
> xt_connmark            12565  0 
> xt_CLASSIFY            12397  0 
> ipt_LOG                12533  7 
> xt_tcpudp              12471  18 
> xt_state               12455  0 
> iptable_nat            12800  0 
> nf_nat                 17708  12
> ipt_REDIRECT,ipt_NETMAP,ipt_MASQUERADE,nf_nat_tftp,nf_nat_sip,nf_nat_pptp,nf_nat_proto_gre,nf_nat_irc,nf_nat_h323,nf_nat_ftp,nf_nat_amanda,iptable_nat
> nf_conntrack_ipv4      13649  11 iptable_nat,nf_nat
> nf_defrag_ipv4         12443  2 xt_TPROXY,nf_conntrack_ipv4
> nf_conntrack           42383  30
> xt_connlimit,ipt_MASQUERADE,ipt_CLUSTERIP,nf_nat_tftp,nf_nat_snmp_basic,nf_nat_sip,nf_nat_pptp,nf_nat_irc,nf_nat_h323,nf_nat_ftp,nf_nat_amanda,nf_conntrack_amanda,nf_conntrack_sane,nf_conntrack_tftp,nf_conntrack_sip,nf_conntrack_proto_sctp,nf_conntrack_pptp,nf_conntrack_proto_gre,nf_conntrack_netlink,nf_conntrack_netbios_ns,nf_conntrack_irc,nf_conntrack_h323,nf_conntrack_ftp,xt_helper,xt_conntrack,xt_connmark,xt_state,iptable_nat,nf_nat,nf_conntrack_ipv4
> iptable_mangle         12488  1 
> nfnetlink              12786  2 nf_conntrack_netlink,nfnetlink_log
> iptable_filter         12488  1 
> ip_tables              16998  4
> iptable_raw,iptable_nat,iptable_mangle,iptable_filter
> x_tables               17967  46
> xt_time,xt_connlimit,xt_realm,iptable_raw,xt_comment,xt_recent,xt_policy,ipt_ULOG,ipt_REJECT,ipt_REDIRECT,ipt_NETMAP,ipt_MASQUERADE,ipt_ECN,ipt_ecn,ipt_CLUSTERIP,ipt_ah,ipt_addrtype,xt_TPROXY,ip6_tables,xt_tcpmss,xt_pkttype,xt_physdev,xt_owner,xt_NFQUEUE,xt_NFLOG,xt_multiport,xt_mark,xt_mac,xt_limit,xt_length,xt_iprange,xt_helper,xt_hashlimit,xt_DSCP,xt_dscp,xt_dccp,xt_conntrack,xt_connmark,xt_CLASSIFY,ipt_LOG,xt_tcpudp,xt_state,iptable_nat,iptable_mangle,iptable_filter,ip_tables
> nfsd                  196026  2 
> exportfs               12506  1 nfsd
> nfs                   209548  0 
> lockd                  60854  2 nfsd,nfs
> fscache                31368  1 nfs
> nfs_acl                12463  2 nfsd,nfs
> auth_rpcgss            31708  2 nfsd,nfs
> sunrpc                132703  6 nfsd,nfs,lockd,nfs_acl,auth_rpcgss
> snd_opl3sa2            17489  1 
> snd_wss_lib            22401  1 snd_opl3sa2
> snd_pcm_oss            35824  0 
> snd_mixer_oss          17649  2 snd_pcm_oss
> snd_pcm                52718  2 snd_wss_lib,snd_pcm_oss
> snd_page_alloc         12841  2 snd_wss_lib,snd_pcm
> snd_opl3_lib           13141  1 snd_opl3sa2
> snd_hwdep              12906  1 snd_opl3_lib
> snd_mpu401_uart        13299  1 snd_opl3sa2
> snd_seq_midi           12744  0 
> snd_rawmidi            18311  2 snd_mpu401_uart,snd_seq_midi
> snd_seq_midi_event     13124  1 snd_seq_midi
> snd_seq                39027  2 snd_seq_midi,snd_seq_midi_event
> pcmcia                 32024  0 
> snd_timer              22133  4 snd_wss_lib,snd_pcm,snd_opl3_lib,snd_seq
> snd_seq_device         12995  4 snd_opl3_lib,snd_seq_midi,snd_rawmidi,snd_seq
> donauboe               16937  0 
> yenta_socket           22152  0 
> evdev                  13015  8
> snd                    38112  12
> snd_opl3sa2,snd_wss_lib,snd_pcm_oss,snd_mixer_oss,snd_pcm,snd_opl3_lib,snd_hwdep,snd_mpu401_uart,snd_rawmidi,snd_seq,snd_timer,snd_seq_device
> psmouse                50618  0 
> irda                   78083  1 donauboe
> pcmcia_rsrc            17314  1 yenta_socket
> pcmcia_core            17973  3 pcmcia,yenta_socket,pcmcia_rsrc
> serio_raw              12758  0 
> pcspkr                 12515  0 
> crc_ccitt              12331  2 donauboe,irda
> soundcore              12878  2 snd
> parport_pc             21895  0 
> toshiba_acpi           13159  0 
> parport                26994  1 parport_pc
> sparse_keymap          12680  1 toshiba_acpi
> battery                12957  0 
> rfkill                 18476  1 toshiba_acpi
> processor              22676  1 
> ac                     12552  0 
> power_supply           13283  2 battery,ac
> button                 12866  0 
> container              12525  0 
> ext3                   97893  1 
> jbd                    36657  1 ext3
> mbcache                12810  1 ext3
> sg                     21324  0 
> sd_mod                 34940  3 
> crc_t10dif             12332  1 sd_mod
> ata_generic            12439  0 
> pata_piccolo           12466  2 
> libata                131830  2 ata_generic,pata_piccolo
> ohci_hcd               21928  0 
> ehci_hcd               34862  0 
> usbcore                98954  4 pegasus,ohci_hcd,ehci_hcd
> scsi_mod              134369  3 sg,sd_mod,libata
> thermal                13058  0 
> fan                    12594  0 
> floppy                 47855  0 
> thermal_sys            17667  3 processor,fan,thermal
> nls_base               12649  1 usbcore
> 
> ** Network interface configuration:
> 
> # The loopback network interface
> auto lo
> iface lo inet loopback
> 
> # The primary network interface
> allow-hotplug eth0
> 
> NOTE!
> I'm using network-manager application to setup my networking.
> 
> ** Network status:
> *** IP interfaces and addresses:
> eth0      Link encap:Ethernet  HWaddr 00:00:70:01:11:f1  
>           inet addr:192.168.10.92  Bcast:192.168.10.255  Mask:255.255.255.0
>           inet6 addr: fe80::200:70ff:fe01:11f1/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:2340 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:2272 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000 
>           RX bytes:1102571 (1.0 MiB)  TX bytes:231106 (225.6 KiB)
> 
> irda0     Link encap:IrLAP  HWaddr 78:22:90:17  
>           UP RUNNING NOARP  MTU:2048  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:8 
>           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
> 
> lo        Link encap:Local Loopback  
>           inet addr:127.0.0.1  Mask:255.0.0.0
>           inet6 addr: ::1/128 Scope:Host
>           UP LOOPBACK RUNNING  MTU:16436  Metric:1
>           RX packets:153 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:153 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0 
>           RX bytes:22449 (21.9 KiB)  TX bytes:22449 (21.9 KiB)
> 
> ** PCI devices:
> 00:00.0 Host bridge: Toshiba America Info Systems CPU to PCI bridge (rev a2)
> 00:07.0 Communication controller: Agere Systems 56k WinModem (rev 01)
> 00:08.0 VGA compatible controller: S3 Inc. ViRGE/MX (rev 06)
> 00:0b.0 USB Controller: NEC Corporation USB (rev 02)
> 00:10.0 IDE interface: Toshiba America Info Systems Extended IDE Controller
> (rev 34)
> 00:11.0 Communication controller: Toshiba America Info Systems FIR Port Type-O
> (rev 23)
> 00:13.0 CardBus bridge: Toshiba America Info Systems ToPIC97 (rev 07)
> 00:13.1 CardBus bridge: Toshiba America Info Systems ToPIC97 (rev 07)
> 
> --
> Best Regards,
> Csanyi Pal

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
