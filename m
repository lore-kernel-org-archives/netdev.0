From: Paul Rolland (=?UTF-8?B?44Od44O844Or44O744Ot44Op44Oz?=)
	<rol@witbe.net>
Subject: WARNING: at net/ipv4/route.c:1677 ip_rt_bug+0x5a/0x70()
Date: Mon, 20 Jun 2011 10:35:12 +0200
Message-ID: <20110620103512.037752be@tux.DEF.witbe.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/vFHHwQsQ3gHG2sME.G=nQZB"; protocol="application/pgp-signature"
Cc: rol@witbe.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.witbe.net ([81.88.96.48]:43304 "EHLO smtp.witbe.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751204Ab1FTIsf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 04:48:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/vFHHwQsQ3gHG2sME.G=nQZB
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hello,

I'm getting a series of these warning when I start a 64bit Win7 inside
VirtualBox in a 64bit 3.0.0-rc3 linux.

This happens when I open the session, not during the boot process. Here is
a copy of the very first warning.

Jun 20 09:44:35 tux kernel: ip_rt_bug: 192.168.0.77 -> 255.255.255.255, ?

It appears the 192.168.0.77 is the IP address of the host machine :
eth0      Link encap:Ethernet  HWaddr 00:24:E8:DE:5A:7B =20
          inet addr:192.168.0.77  Bcast:192.168.0.255  Mask:255.255.255.0
          inet6 addr: xxxx:xxx:xxxx:0:224:e8ff:fede:5a7b/64 Scope:Global
          inet6 addr: fe80::224:e8ff:fede:5a7b/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:272814 errors:0 dropped:0 overruns:0 frame:0
          TX packets:55475 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000=20
          RX bytes:128123754 (122.1 MiB)  TX bytes:5560092 (5.3 MiB)
          Interrupt:48 Base address:0xa000=20

and the routing table contains :
[root@tux ipv4]# netstat -rn
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt If=
ace
0.0.0.0         192.168.0.15    0.0.0.0         UG        0 0          0 et=
h0
192.168.0.0     0.0.0.0         255.255.255.0   U         0 0          0 et=
h0

Here is the complete detail :

Jun 20 09:44:35 tux kernel: ------------[ cut here ]------------
Jun 20 09:44:35 tux kernel: WARNING: at net/ipv4/route.c:1677 ip_rt_bug+0x5=
a/0x70()
Jun 20 09:44:35 tux kernel: Hardware name: Vostro 1520
Jun 20 09:44:35 tux kernel: Modules linked in: tcp_lp fuse ipheth vfat fat =
vboxnetadp vboxnetflt vboxdrv coretemp hwmon cpufreq_ondemand acpi_cpufreq =
freq_table mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filt=
er ip6_tables ipv6 dm_crypt snd_hda_codec_idt snd_hda_intel snd_hda_codec s=
nd_hwdep snd_seq uvcvideo snd_seq_device snd_pcm snd_timer snd soundcore iw=
l3945 iwl_legacy mac80211 dell_laptop r8169 cfg80211 dcdbas mii iTCO_wdt iT=
CO_vendor_support snd_page_alloc rfkill i2c_i801 microcode mmc_block sdhci_=
pci sdhci mmc_core firewire_ohci firewire_core [last unloaded: scsi_wait_sc=
an]
Jun 20 09:44:35 tux kernel: Pid: 4848, comm: VirtualBox Not tainted 3.0.0-r=
c3 #2
Jun 20 09:44:35 tux kernel: Call Trace:
Jun 20 09:44:35 tux kernel: [<ffffffff8104c5aa>] warn_slowpath_common+0x7a/=
0xb0
Jun 20 09:44:35 tux kernel: [<ffffffff8104c5f5>] warn_slowpath_null+0x15/0x=
20
Jun 20 09:44:35 tux kernel: [<ffffffff814bc9aa>] ip_rt_bug+0x5a/0x70
Jun 20 09:44:35 tux kernel: [<ffffffff814c5a54>] ip_local_out+0x24/0x30
Jun 20 09:44:35 tux kernel: [<ffffffff814c5a69>] ip_send_skb+0x9/0x50
Jun 20 09:44:35 tux kernel: [<ffffffff814e8905>] udp_send_skb+0x115/0x3a0
Jun 20 09:44:35 tux kernel: [<ffffffff814c4f90>] ? ip_append_page+0x570/0x5=
70
Jun 20 09:44:35 tux kernel: [<ffffffff814ea218>] udp_sendmsg+0x338/0x940
Jun 20 09:44:35 tux kernel: [<ffffffff8110bd90>] ? __pollwait+0xf0/0xf0
Jun 20 09:44:35 tux kernel: [<ffffffff814f24e3>] inet_sendmsg+0x43/0xb0
Jun 20 09:44:35 tux kernel: [<ffffffff81051c02>] ? current_fs_time+0x22/0x30
Jun 20 09:44:35 tux kernel: [<ffffffff8110bd90>] ? __pollwait+0xf0/0xf0
Jun 20 09:44:35 tux kernel: [<ffffffff81475646>] sock_sendmsg+0x106/0x120
Jun 20 09:44:35 tux kernel: [<ffffffff814c76f0>] ? do_ip_setsockopt+0x80/0x=
d60
Jun 20 09:44:35 tux kernel: [<ffffffff815422bf>] ? _raw_spin_unlock_bh+0xf/=
0x20
Jun 20 09:44:35 tux kernel: [<ffffffff814eb94b>] ? udp_lib_get_port+0x20b/0=
x340
Jun 20 09:44:35 tux kernel: [<ffffffff8147516a>] ? move_addr_to_kernel+0x6a=
/0x70
Jun 20 09:44:35 tux kernel: [<ffffffff81475dc4>] sys_sendto+0x134/0x180
Jun 20 09:44:35 tux kernel: [<ffffffff814c84c5>] ? ip_setsockopt+0x45/0x90
Jun 20 09:44:35 tux kernel: [<ffffffff810f8058>] ? fd_install+0x38/0x70
Jun 20 09:44:35 tux kernel: [<ffffffff8109d3bc>] ? audit_syscall_entry+0x1b=
c/0x1f0
Jun 20 09:44:35 tux kernel: [<ffffffff81542bbb>] system_call_fastpath+0x16/=
0x1b
Jun 20 09:44:35 tux kernel: ---[ end trace daa5db172540fc0c ]---

Please note that davidm pointed to :
http://marc.info/?l=3Dlinux-netdev&m=3D130841949406760&w=3D2

I'm going to try this patch, and will report if it helps.

If I can provide additional help, feel free to ask, but please keep me
copied, as I'm not subscribed to netdev.

Regards,
Paul


--Sig_/vFHHwQsQ3gHG2sME.G=nQZB
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEARECAAYFAk3/BkAACgkQZP464AVDf+DpRwCdFPvHwZ+64bidUPwf3rHkiTKY
4C8AmgKzdqohk261x4YK4WD54MFVdH3E
=Q8bB
-----END PGP SIGNATURE-----

--Sig_/vFHHwQsQ3gHG2sME.G=nQZB--
