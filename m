From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#583935: linux-image-2.6.32-5-amd64: kernel trace in
 net/ipv4/tcp_input.c:2540 tcp_ack
Date: Tue, 01 Jun 2010 02:45:53 +0100
Message-ID: <1275356753.2870.13.camel@localhost>
References: <20100531175508.13357.50413.reportbug@champaran.hq.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-lCL1fv7YrWee2A19YAkP"
Cc: netdev <netdev@vger.kernel.org>
To: Ritesh Raj Sarraf <rrs@debian.org>, 583935@bugs.debian.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57415 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752638Ab0FABq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 21:46:27 -0400
In-Reply-To: <20100531175508.13357.50413.reportbug@champaran.hq.netapp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-lCL1fv7YrWee2A19YAkP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2010-05-31 at 23:25 +0530, Ritesh Raj Sarraf wrote:
> Package: linux-2.6
> Version: 2.6.32-14
> Severity: normal
> Tags: squeeze
>=20
> I haven't noticed a stability issue as such but saw this kernel trace
> logged into dmesg.

I'm forwarding this to the 'netdev' list to see if the upstream
developers can debug it.

Debian kernel version 2.6.32-14 is closely based on stable kernel
2.6.32.14.

Ben.

> -- Package-specific info:
> ** Version:
> Linux version 2.6.32-5-amd64 (Debian 2.6.32-14) (ben@decadent.org.uk) (gc=
c version 4.3.5 (Debian 4.3.5-1) ) #1 SMP Sun May 30 17:20:42 UTC 2010
>=20
> ** Command line:
> BOOT_IMAGE=3D/vmlinuz-2.6.32-5-amd64 root=3D/dev/mapper/LocalDisk-ROOT ro=
 quiet security=3Dtomoyo splash
>=20
> ** Tainted: W (512)
>  * Taint on warning.
>=20
> ** Kernel log:
> [   28.406886] iwlagn 0000:03:00.0: firmware: requesting iwlwifi-5000-2.u=
code
> [   28.548635] iwlagn 0000:03:00.0: loaded firmware version 8.24.2.12
> [   28.692813] Registered led device: iwl-phy0::radio
> [   28.692830] Registered led device: iwl-phy0::assoc
> [   28.692847] Registered led device: iwl-phy0::RX
> [   28.692863] Registered led device: iwl-phy0::TX
> [   28.705588] ADDRCONF(NETDEV_UP): wlan0: link is not ready
> [   28.977787] ip_tables: (C) 2000-2006 Netfilter Core Team
> [   29.974096] CPU0 attaching NULL sched-domain.
> [   29.974107] CPU1 attaching NULL sched-domain.
> [   30.000216] CPU0 attaching sched-domain:
> [   30.000225]  domain 0: span 0-1 level MC
> [   30.000231]   groups: 0 1
> [   30.000243] CPU1 attaching sched-domain:
> [   30.000248]  domain 0: span 0-1 level MC
> [   30.000253]   groups: 1 0
> [   30.752068] CE: hpet increasing min_delta_ns to 15000 nsec
> [   34.129035] e1000e 0000:00:19.0: irq 28 for MSI/MSI-X
> [   34.184125] e1000e 0000:00:19.0: irq 28 for MSI/MSI-X
> [   34.185657] ADDRCONF(NETDEV_UP): eth0: link is not ready
> [   40.052965] Registered led device: iwl-phy0::radio
> [   40.053013] Registered led device: iwl-phy0::assoc
> [   40.053057] Registered led device: iwl-phy0::RX
> [   40.053099] Registered led device: iwl-phy0::TX
> [   40.062505] ADDRCONF(NETDEV_UP): wlan0: link is not ready
> [   40.456244] e1000e 0000:00:19.0: irq 28 for MSI/MSI-X
> [   40.512218] e1000e 0000:00:19.0: irq 28 for MSI/MSI-X
> [   40.513753] ADDRCONF(NETDEV_UP): eth0: link is not ready
> [   40.820920] Registered led device: iwl-phy0::radio
> [   40.820972] Registered led device: iwl-phy0::assoc
> [   40.821016] Registered led device: iwl-phy0::RX
> [   40.821067] Registered led device: iwl-phy0::TX
> [   40.838420] ADDRCONF(NETDEV_UP): wlan0: link is not ready
> [   46.301012] wlan0: direct probe to AP 00:16:b6:a5:e7:1c (try 1)
> [   46.303662] wlan0: direct probe responded
> [   46.303669] wlan0: authenticate with AP 00:16:b6:a5:e7:1c (try 1)
> [   46.305533] wlan0: authenticated
> [   46.305566] wlan0: associate with AP 00:16:b6:a5:e7:1c (try 1)
> [   46.308078] wlan0: RX AssocResp from 00:16:b6:a5:e7:1c (capab=3D0x411 =
status=3D0 aid=3D2)
> [   46.308084] wlan0: associated
> [   46.322057] ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
> [   46.393592] padlock: VIA PadLock not detected.
> [   50.772185] tun: Universal TUN/TAP device driver, 1.6
> [   50.772191] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
> [   50.775190] tun0: Disabled Privacy Extensions
> [   57.217677] CPU0 attaching NULL sched-domain.
> [   57.217681] CPU1 attaching NULL sched-domain.
> [   57.240126] CPU0 attaching sched-domain:
> [   57.240130]  domain 0: span 0-1 level MC
> [   57.240133]   groups: 0 1
> [   57.240139] CPU1 attaching sched-domain:
> [   57.240141]  domain 0: span 0-1 level MC
> [   57.240144]   groups: 1 0
> [   85.004087] hrtimer: interrupt took 544273 ns
> [   86.926725] TOMOYO-WARNING: Domain '<kernel> /etc/init.d/kdm /sbin/sta=
rt-stop-daemon /usr/bin/kdm /etc/kde4/kdm/Xsession /bin/bash /usr/bin/ssh-a=
gent /usr/bin/gpg-agent /usr/bin/dbus-launch /usr/bin/startkde /usr/lib/kde=
4/libexec/start_kdeinit_wrapper /usr/lib/kde4/libexec/start_kdeinit /usr/bi=
n/kdeinit4 /usr/bin/plasma-desktop' has so many ACLs to hold. Stopped learn=
ing mode.
> [  174.886226] padlock: VIA PadLock Hash Engine not detected.
> [  364.553852] TOMOYO-WARNING: Domain '<kernel> /etc/init.d/kdm /sbin/sta=
rt-stop-daemon /usr/bin/kdm /etc/kde4/kdm/Xsession /bin/bash /usr/bin/ssh-a=
gent /usr/bin/gpg-agent /usr/bin/dbus-launch /usr/bin/startkde /usr/lib/kde=
4/libexec/start_kdeinit_wrapper /usr/lib/kde4/libexec/start_kdeinit /usr/bi=
n/kdeinit4 /usr/bin/kontact' has so many ACLs to hold. Stopped learning mod=
e.
> [ 1107.492423] EXT4-fs (dm-2): mounted filesystem with ordered data mode
> [ 2099.365512] TOMOYO-WARNING: Domain '<kernel> /etc/init.d/kdm /sbin/sta=
rt-stop-daemon /usr/bin/kdm /etc/kde4/kdm/Xsession /bin/bash /usr/bin/ssh-a=
gent /usr/bin/gpg-agent /usr/bin/dbus-launch /usr/bin/startkde /usr/lib/kde=
4/libexec/start_kdeinit_wrapper /usr/lib/kde4/libexec/start_kdeinit /usr/bi=
n/kdeinit4 /usr/bin/konsole /bin/bash /usr/bin/sudo /usr/bin/aptitude /usr/=
bin/dpkg' has so many ACLs to hold. Stopped learning mode.
> [ 3497.934021] TOMOYO-WARNING: Domain '<kernel> /etc/init.d/kdm /sbin/sta=
rt-stop-daemon /usr/bin/kdm /etc/kde4/kdm/Xsession /bin/bash /usr/bin/ssh-a=
gent /usr/bin/gpg-agent /usr/bin/dbus-launch /usr/bin/startkde /usr/lib/kde=
4/libexec/start_kdeinit_wrapper /usr/lib/kde4/libexec/start_kdeinit /usr/bi=
n/kdeinit4 /usr/bin/ktorrent' has so many ACLs to hold. Stopped learning mo=
de.
> [ 6794.222126] TOMOYO-WARNING: Domain '<kernel> /etc/init.d/kdm /sbin/sta=
rt-stop-daemon /usr/bin/kdm /etc/kde4/kdm/Xsession /bin/bash /usr/bin/ssh-a=
gent /usr/bin/gpg-agent /usr/bin/dbus-launch /usr/bin/startkde /usr/lib/kde=
4/libexec/start_kdeinit_wrapper /usr/lib/kde4/libexec/start_kdeinit /usr/bi=
n/kdeinit4 /usr/bin/krunner /usr/lib/kde4/libexec/kscreenlocker /usr/bin/pl=
asma-overlay' has so many ACLs to hold. Stopped learning mode.
> [ 7716.171410] ------------[ cut here ]------------
> [ 7716.171420] WARNING: at /build/buildd-linux-2.6_2.6.32-14-amd64-yRQD2k=
/linux-2.6-2.6.32/debian/build/source_amd64_none/net/ipv4/tcp_input.c:2540 =
tcp_ack+0x160e/0x1952()
> [ 7716.171424] Hardware name: 6475KH8
> [ 7716.171426] Modules linked in: sha256_generic cbc tun aes_x86_64 aes_g=
eneric xt_state iptable_filter ip_tables nf_conntrack_ipv4 nf_defrag_ipv4 n=
f_conntrack_tftp nf_conntrack_proto_dccp nf_conntrack_pptp xt_conntrack x_t=
ables nf_conntrack_ftp nf_conntrack_sane ts_kmp nf_conntrack_amanda nf_conn=
track_h323 nf_conntrack_proto_gre nf_conntrack_sip nf_conntrack_proto_sctp =
nf_conntrack_irc nf_conntrack_proto_udplite nf_conntrack_netlink nfnetlink =
nf_conntrack_netbios_ns nf_conntrack_ipv6 nf_conntrack ppdev lp parport sco=
 bridge stp bnep rfcomm l2cap acpi_cpufreq cpufreq_stats cpufreq_userspace =
cpufreq_conservative cpufreq_powersave hdaps thinkpad_ec kvm_intel kvm uinp=
ut binfmt_misc fuse ext3 jbd loop firewire_sbp2 dm_crypt snd_hda_codec_cone=
xant snd_hda_intel snd_hda_codec arc4 snd_pcsp snd_hwdep ecb snd_pcm_oss i9=
15 snd_mixer_oss drm_kms_helper uvcvideo videodev snd_pcm v4l1_compat btusb=
 joydev bluetooth iwlagn pcmcia snd_timer v4l2_compat_ioctl32 drm iwlcore i=
2c_algo_bit snd t
>  hinkpad_acpi yenta_socket i2c_i801 tpm_tis soundcore tpm nvram led_class=
 video snd_page_alloc tpm_bios i2c_core mac80211 cfg80211 wmi rfkill rsrc_n=
onstatic output pcmcia_core evdev ac serio_raw psmouse button battery proce=
ssor ext4 mbcache jbd2 crc16 dm_mod sg sd_mod sr_mod crc_t10dif cdrom uhci_=
hcd firewire_ohci firewire_core crc_itu_t ahci ehci_hcd libata e1000e scsi_=
mod usbcore nls_base thermal thermal_sys [last unloaded: scsi_wait_scan]
> [ 7716.171547] Pid: 0, comm: swapper Not tainted 2.6.32-5-amd64 #1
> [ 7716.171549] Call Trace:
> [ 7716.171551]  <IRQ>  [<ffffffff81283705>] ? tcp_ack+0x160e/0x1952
> [ 7716.171559]  [<ffffffff81283705>] ? tcp_ack+0x160e/0x1952
> [ 7716.171564]  [<ffffffff8104dc48>] ? warn_slowpath_common+0x77/0xa3
> [ 7716.171569]  [<ffffffff81283705>] ? tcp_ack+0x160e/0x1952
> [ 7716.171573]  [<ffffffff81284166>] ? tcp_rcv_established+0xc9/0x6d9
> [ 7716.171578]  [<ffffffff8128b6ef>] ? tcp_v4_do_rcv+0x1bb/0x376
> [ 7716.171583]  [<ffffffff8126ef89>] ? ip_route_input+0x6b/0xcbf
> [ 7716.171587]  [<ffffffff8128bd0f>] ? tcp_v4_rcv+0x465/0x6b6
> [ 7716.171592]  [<ffffffff81271216>] ? ip_local_deliver_finish+0x0/0x1e9
> [ 7716.171596]  [<ffffffff81271216>] ? ip_local_deliver_finish+0x0/0x1e9
> [ 7716.171600]  [<ffffffff8127135c>] ? ip_local_deliver_finish+0x146/0x1e=
9
> [ 7716.171605]  [<ffffffff81270eab>] ? ip_rcv_finish+0x373/0x38d
> [ 7716.171609]  [<ffffffff81271165>] ? ip_rcv+0x2a0/0x2ed
> [ 7716.171614]  [<ffffffff8124d55e>] ? process_backlog+0x81/0xb4
> [ 7716.171618]  [<ffffffff8124db37>] ? net_rx_action+0xae/0x1c9
> [ 7716.171623]  [<ffffffff810539d6>] ? __do_softirq+0xdd/0x19f
> [ 7716.171634]  [<ffffffffa02b533d>] ? iwl_isr_ict+0x179/0x200 [iwlcore]
> [ 7716.171639]  [<ffffffff81011cac>] ? call_softirq+0x1c/0x30
> [ 7716.171643]  [<ffffffff81013903>] ? do_softirq+0x3f/0x7c
> [ 7716.171647]  [<ffffffff81053845>] ? irq_exit+0x36/0x76
> [ 7716.171651]  [<ffffffff81012ffa>] ? do_IRQ+0xa0/0xb6
> [ 7716.171655]  [<ffffffff810114d3>] ? ret_from_intr+0x0/0x11
> [ 7716.171657]  <EOI>  [<ffffffffa0201647>] ? acpi_idle_enter_simple+0x11=
6/0x148 [processor]
> [ 7716.171677]  [<ffffffffa0201647>] ? acpi_idle_enter_simple+0x116/0x148=
 [processor]
> [ 7716.171682]  [<ffffffffa0201640>] ? acpi_idle_enter_simple+0x10f/0x148=
 [processor]
> [ 7716.171686]  [<ffffffff81237e46>] ? cpuidle_idle_call+0x94/0xee
> [ 7716.171690]  [<ffffffff8100feb1>] ? cpu_idle+0xa2/0xda
> [ 7716.171693]  [<ffffffff814ec140>] ? early_idt_handler+0x0/0x71
> [ 7716.171696]  [<ffffffff814eccd1>] ? start_kernel+0x3dc/0x3e8
> [ 7716.171699]  [<ffffffff814ec3b7>] ? x86_64_start_kernel+0xf9/0x106
> [ 7716.171701] ---[ end trace d930a229f048f9d9 ]---
> [10602.944028] TCP: Peer 151.81.183.141:30126/44441 unexpectedly shrunk w=
indow 773717473:773723425 (repaired)
> [10657.848015] TCP: Peer 151.81.183.141:30126/44441 unexpectedly shrunk w=
indow 773717473:773723425 (repaired)
>=20
> ** Model information
> sys_vendor: LENOVO
> product_name: 6475KH8
> product_version: ThinkPad T400
> chassis_vendor: LENOVO
> chassis_version: Not Available
> bios_vendor: LENOVO
> bios_version: 7UET79WW (3.09 )
> board_vendor: LENOVO
> board_name: 6475KH8
> board_version: Not Available
>=20
> ** Loaded modules:
> Module                  Size  Used by
> sha256_generic          8692  2=20
> cbc                     2539  1=20
> tun                    10828  0=20
> aes_x86_64              7340  5=20
> aes_generic            25714  1 aes_x86_64
> xt_state                1303  16=20
> iptable_filter          2258  1=20
> ip_tables              13899  1 iptable_filter
> nf_conntrack_ipv4       9833  16=20
> nf_defrag_ipv4          1139  1 nf_conntrack_ipv4
> nf_conntrack_tftp       3321  0=20
> nf_conntrack_proto_dccp     6466  0=20
> nf_conntrack_pptp       3801  0=20
> xt_conntrack            2407  0=20
> x_tables               12845  3 xt_state,ip_tables,xt_conntrack
> nf_conntrack_ftp        5537  0=20
> nf_conntrack_sane       3620  0=20
> ts_kmp                  1623  5=20
> nf_conntrack_amanda     2197  0=20
> nf_conntrack_h323      36992  0=20
> nf_conntrack_proto_gre     3579  1 nf_conntrack_pptp
> nf_conntrack_sip       13546  0=20
> nf_conntrack_proto_sctp     6238  0=20
> nf_conntrack_irc        3347  0=20
> nf_conntrack_proto_udplite     2623  0=20
> nf_conntrack_netlink    13128  0=20
> nfnetlink               2398  1 nf_conntrack_netlink
> nf_conntrack_netbios_ns     1282  0=20
> nf_conntrack_ipv6      10467  0=20
> nf_conntrack           46551  18 xt_state,nf_conntrack_ipv4,nf_conntrack_=
tftp,nf_conntrack_proto_dccp,nf_conntrack_pptp,xt_conntrack,nf_conntrack_ft=
p,nf_conntrack_sane,nf_conntrack_amanda,nf_conntrack_h323,nf_conntrack_prot=
o_gre,nf_conntrack_sip,nf_conntrack_proto_sctp,nf_conntrack_irc,nf_conntrac=
k_proto_udplite,nf_conntrack_netlink,nf_conntrack_netbios_ns,nf_conntrack_i=
pv6
> ppdev                   5030  0=20
> lp                      7462  0=20
> parport                27954  2 ppdev,lp
> sco                     7209  2=20
> bridge                 39598  0=20
> stp                     1440  1 bridge
> bnep                    9427  2=20
> rfcomm                 29581  6=20
> l2cap                  24736  16 bnep,rfcomm
> acpi_cpufreq            5555  0=20
> cpufreq_stats           2659  0=20
> cpufreq_userspace       1992  0=20
> cpufreq_conservative     5162  0=20
> cpufreq_powersave        902  0=20
> hdaps                   7765  1=20
> thinkpad_ec             3694  1 hdaps
> kvm_intel              38050  0=20
> kvm                   213544  1 kvm_intel
> uinput                  6376  1=20
> binfmt_misc             6431  1=20
> fuse                   50190  1=20
> ext3                  106518  1=20
> jbd                    37085  1 ext3
> loop                   11783  0=20
> firewire_sbp2          11514  0=20
> dm_crypt               10507  1=20
> snd_hda_codec_conexant    21869  1=20
> snd_hda_intel          19907  3=20
> snd_hda_codec          54244  2 snd_hda_codec_conexant,snd_hda_intel
> arc4                    1274  2=20
> snd_pcsp                6579  2=20
> snd_hwdep               5380  1 snd_hda_codec
> ecb                     1841  2=20
> snd_pcm_oss            32591  0=20
> i915                  252896  2=20
> snd_mixer_oss          12606  1 snd_pcm_oss
> drm_kms_helper         20065  1 i915
> uvcvideo               51743  0=20
> videodev               29993  1 uvcvideo
> snd_pcm                60471  4 snd_hda_intel,snd_hda_codec,snd_pcsp,snd_=
pcm_oss
> v4l1_compat            11442  2 uvcvideo,videodev
> btusb                   9785  2=20
> joydev                  8411  0=20
> bluetooth              41827  9 sco,bnep,rfcomm,l2cap,btusb
> iwlagn                 71756  0=20
> pcmcia                 19474  0=20
> snd_timer              15582  1 snd_pcm
> v4l2_compat_ioctl32     8538  1 videodev
> drm                   142551  3 i915,drm_kms_helper
> iwlcore                77442  1 iwlagn
> i2c_algo_bit            4225  1 i915
> snd                    46446  19 snd_hda_codec_conexant,snd_hda_intel,snd=
_hda_codec,snd_pcsp,snd_hwdep,snd_pcm_oss,snd_mixer_oss,snd_pcm,snd_timer
> thinkpad_acpi          50103  0=20
> yenta_socket           19115  1=20
> i2c_i801                7830  0=20
> tpm_tis                 7336  0=20
> soundcore               4598  1 snd
> tpm                     9917  1 tpm_tis
> nvram                   5061  1 thinkpad_acpi
> led_class               2433  2 iwlcore,thinkpad_acpi
> video                  17445  1 i915
> snd_page_alloc          6249  2 snd_hda_intel,snd_pcm
> tpm_bios                4521  1 tpm
> i2c_core               15712  6 i915,drm_kms_helper,videodev,drm,i2c_algo=
_bit,i2c_i801
> mac80211              136844  2 iwlagn,iwlcore
> cfg80211              101432  3 iwlagn,iwlcore,mac80211
> wmi                     4323  0=20
> rfkill                 13044  4 bluetooth,thinkpad_acpi,cfg80211
> rsrc_nonstatic          7294  1 yenta_socket
> output                  1692  1 video
> pcmcia_core            24118  3 pcmcia,yenta_socket,rsrc_nonstatic
> evdev                   7352  28=20
> ac                      2192  0=20
> serio_raw               3752  0=20
> psmouse                49777  0=20
> button                  4650  1 i915
> battery                 4998  0=20
> processor              30231  3 acpi_cpufreq
> ext4                  285611  2=20
> mbcache                 5050  2 ext3,ext4
> jbd2                   66919  1 ext4
> crc16                   1319  2 l2cap,ext4
> dm_mod                 53754  9 dm_crypt
> sg                     18744  0=20
> sd_mod                 29777  4=20
> sr_mod                 12602  0=20
> crc_t10dif              1276  1 sd_mod
> cdrom                  29415  1 sr_mod
> uhci_hcd               18521  0=20
> firewire_ohci          19468  0=20
> firewire_core          36736  2 firewire_sbp2,firewire_ohci
> crc_itu_t               1307  1 firewire_core
> ahci                   32358  3=20
> ehci_hcd               31039  0=20
> libata                133520  1 ahci
> e1000e                109967  0=20
> scsi_mod              122117  5 firewire_sbp2,sg,sd_mod,sr_mod,libata
> usbcore               121959  5 uvcvideo,btusb,uhci_hcd,ehci_hcd
> nls_base                6361  1 usbcore
> thermal                11674  0=20
> thermal_sys            11942  3 video,processor,thermal
>=20
> ** Network interface configuration:
>=20
> auto lo
> iface lo inet loopback
>=20
> iface eth0dhcp inet dhcp
>=20
>=20
> iface dsl-provider inet ppp
> pre-up /sbin/ifconfig eth0 up # line maintained by pppoeconf
> provider dsl-provider
>=20
> iface wlan0blr inet dhcp
>         wpa-ssid rrs
> wpa-psk *******************************
>=20
> iface wlan0netapp inet dhcp
> 	wpa-ssid netapp
>=20
> ** Network status:
> *** IP interfaces and addresses:
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN=20
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>     inet 127.0.0.1/8 scope host lo
>     inet6 ::1/128 scope host=20
>        valid_lft forever preferred_lft forever
> 2: eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast st=
ate DOWN qlen 1000
>     link/ether 00:22:68:1b:af:4a brd ff:ff:ff:ff:ff:ff
> 3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP ql=
en 1000
>     link/ether 00:26:c6:72:07:9a brd ff:ff:ff:ff:ff:ff
>     inet 192.168.2.101/24 brd 192.168.2.255 scope global wlan0
>     inet6 fe80::226:c6ff:fe72:79a/64 scope link=20
>        valid_lft forever preferred_lft forever
> 4: pan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN=20
>     link/ether 52:02:e9:0e:27:d2 brd ff:ff:ff:ff:ff:ff
>=20
> *** Device statistics:
> Inter-|   Receive                                                |  Trans=
mit
>  face |bytes    packets errs drop fifo frame compressed multicast|bytes  =
  packets errs drop fifo colls carrier compressed
>     lo:42635507   41327    0    0    0     0          0         0 4263550=
7   41327    0    0    0     0       0          0
>   eth0:       0       0    0    0    0     0          0         0        =
0       0    0    0    0     0       0          0
>  wlan0:1032619756 1390916    0    0    0     0          0         0 75243=
3881 1882435    0    0    0     0       0          0
>   pan0:       0       0    0    0    0     0          0         0        =
0       0    0    0    0     0       0          0
>=20
> *** Protocol statistics:
> Ip:
>     1449157 total packets received
>     0 forwarded
>     0 incoming packets discarded
>     1444671 incoming packets delivered
>     1938464 requests sent out
>     109 outgoing packets dropped
>     15 dropped because of missing route
>     2 reassemblies required
>     1 packets reassembled ok
>     5 fragments failed
> Icmp:
>     3120 ICMP messages received
>     0 input ICMP message failed.
>     ICMP input histogram:
>         destination unreachable: 3015
>         timeout in transit: 105
>     2318 ICMP messages sent
>     0 ICMP messages failed
>     ICMP output histogram:
>         destination unreachable: 2318
> IcmpMsg:
>         InType3: 3015
>         InType11: 105
>         OutType3: 2318
> Tcp:
>     80024 active connections openings
>     23 passive connection openings
>     14172 failed connection attempts
>     1039 connection resets received
>     47 connections established
>     1372879 segments received
>     1620413 segments send out
>     212825 segments retransmited
>     0 bad segments received.
>     7303 resets sent
> Udp:
>     66389 packets received
>     2313 packets to unknown port received.
>     0 packet receive errors
>     103244 packets sent
> UdpLite:
> TcpExt:
>     531 packets pruned from receive queue because of socket buffer overru=
n
>     34 ICMP packets dropped because they were out-of-window
>     1 ICMP packets dropped because socket was locked
>     1790 TCP sockets finished time wait in fast timer
>     1265 time wait sockets recycled by time stamp
>     172 packets rejects in established connections because of timestamp
>     26690 delayed acks sent
>     5 delayed acks further delayed because of locked socket
>     Quick ack mode was activated 32051 times
>     1061 packets directly queued to recvmsg prequeue.
>     620116 bytes directly received in process context from prequeue
>     359424 packet headers predicted
>     595 packets header predicted and directly queued to user
>     213531 acknowledgments not containing data payload received
>     69799 predicted acknowledgments
>     3 times recovered from packet loss due to fast retransmit
>     9376 times recovered from packet loss by selective acknowledgements
>     6 bad SACK blocks received
>     Detected reordering 5 times using FACK
>     Detected reordering 12 times using SACK
>     Detected reordering 36 times using time stamp
>     33 congestion windows fully recovered without slow start
>     70 congestion windows partially recovered using Hoe heuristic
>     13 congestion windows recovered without slow start by DSACK
>     15526 congestion windows recovered without slow start after partial a=
ck
>     11091 TCP data loss events
>     TCPLostRetransmit: 538
>     18 timeouts after reno fast retransmit
>     5211 timeouts after SACK recovery
>     2758 timeouts in loss state
>     19421 fast retransmits
>     232 forward retransmits
>     19995 retransmits in slow start
>     88651 other TCP timeouts
>     3 classic Reno fast retransmits failed
>     2608 SACK retransmits failed
>     6832 packets collapsed in receive queue due to low socket buffer
>     72330 DSACKs sent for old packets
>     10715 DSACKs sent for out of order packets
>     5884 DSACKs received
>     28 DSACKs for out of order packets received
>     2515 connections reset due to unexpected data
>     156 connections reset due to early user close
>     3646 connections aborted due to timeout
>     7 times unabled to send RST due to no memory
>     TCPSACKDiscard: 2
>     TCPDSACKIgnoredOld: 3730
>     TCPDSACKIgnoredNoUndo: 1811
>     TCPSpuriousRTOs: 46
>     TCPSackShiftFallback: 71643
> IpExt:
>     InNoRoutes: 2
>     InMcastPkts: 342
>     OutMcastPkts: 301
>     InBcastPkts: 4
>     InOctets: 1070306263
>     OutOctets: 732197456
>     InMcastOctets: 44349
>     OutMcastOctets: 40280
>     InBcastOctets: 1312
>=20
> *** Device features:
> eth0: 0x1109a9
> lo: 0x13865
> pan0: 0xff3865
> wlan0: 0x2000
>=20
> ** PCI devices:
> 00:00.0 Host bridge [0600]: Intel Corporation Mobile 4 Series Chipset Mem=
ory Controller Hub [8086:2a40] (rev 07)
> 	Subsystem: Lenovo Device [17aa:20e0]
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbort=
- <MAbort+ >SERR- <PERR- INTx-
> 	Latency: 0
> 	Capabilities: <access denied>
> 	Kernel driver in use: agpgart-intel
>=20
> 00:02.0 VGA compatible controller [0300]: Intel Corporation Mobile 4 Seri=
es Chipset Integrated Graphics Controller [8086:2a42] (rev 07) (prog-if 00 =
[VGA controller])
> 	Subsystem: Lenovo Device [17aa:20e4]
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 31
> 	Region 0: Memory at f4400000 (64-bit, non-prefetchable) [size=3D4M]
> 	Region 2: Memory at d0000000 (64-bit, prefetchable) [size=3D256M]
> 	Region 4: I/O ports at 1800 [size=3D8]
> 	Expansion ROM at <unassigned> [disabled]
> 	Capabilities: <access denied>
> 	Kernel driver in use: i915
>=20
> 00:02.1 Display controller [0380]: Intel Corporation Mobile 4 Series Chip=
set Integrated Graphics Controller [8086:2a43] (rev 07)
> 	Subsystem: Lenovo Device [17aa:20e4]
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Region 0: Memory at f4200000 (64-bit, non-prefetchable) [size=3D1M]
> 	Capabilities: <access denied>
>=20
> 00:03.0 Communication controller [0780]: Intel Corporation Mobile 4 Serie=
s Chipset MEI Controller [8086:2a44] (rev 07)
> 	Subsystem: Lenovo Device [17aa:20e6]
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx+
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 11
> 	Region 0: Memory at fc226800 (64-bit, non-prefetchable) [size=3D16]
> 	Capabilities: <access denied>
>=20
> 00:03.3 Serial controller [0700]: Intel Corporation Mobile 4 Series Chips=
et AMT SOL Redirection [8086:2a47] (rev 07) (prog-if 02 [16550])
> 	Subsystem: Lenovo Device [17aa:20ec]
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin B routed to IRQ 17
> 	Region 0: I/O ports at 1830 [size=3D8]
> 	Region 1: Memory at fc024000 (32-bit, non-prefetchable) [size=3D4K]
> 	Capabilities: <access denied>
> 	Kernel driver in use: serial
>=20
> 00:19.0 Ethernet controller [0200]: Intel Corporation 82567LM Gigabit Net=
work Connection [8086:10f5] (rev 03)
> 	Subsystem: Lenovo Device [17aa:20ee]
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 28
> 	Region 0: Memory at fc000000 (32-bit, non-prefetchable) [size=3D128K]
> 	Region 1: Memory at fc025000 (32-bit, non-prefetchable) [size=3D4K]
> 	Region 2: I/O ports at 1840 [size=3D32]
> 	Capabilities: <access denied>
> 	Kernel driver in use: e1000e
>=20
> 00:1a.0 USB Controller [0c03]: Intel Corporation 82801I (ICH9 Family) USB=
 UHCI Controller #4 [8086:2937] (rev 03) (prog-if 00 [UHCI])
> 	Subsystem: Lenovo Device [17aa:20f0]
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 20
> 	Region 4: I/O ports at 1860 [size=3D32]
> 	Capabilities: <access denied>
> 	Kernel driver in use: uhci_hcd
>=20
> 00:1a.1 USB Controller [0c03]: Intel Corporation 82801I (ICH9 Family) USB=
 UHCI Controller #5 [8086:2938] (rev 03) (prog-if 00 [UHCI])
> 	Subsystem: Lenovo Device [17aa:20f0]
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin B routed to IRQ 21
> 	Region 4: I/O ports at 1880 [size=3D32]
> 	Capabilities: <access denied>
> 	Kernel driver in use: uhci_hcd
>=20
> 00:1a.2 USB Controller [0c03]: Intel Corporation 82801I (ICH9 Family) USB=
 UHCI Controller #6 [8086:2939] (rev 03) (prog-if 00 [UHCI])
> 	Subsystem: Lenovo Device [17aa:20f0]
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin C routed to IRQ 22
> 	Region 4: I/O ports at 18a0 [size=3D32]
> 	Capabilities: <access denied>
> 	Kernel driver in use: uhci_hcd
>=20
> 00:1a.7 USB Controller [0c03]: Intel Corporation 82801I (ICH9 Family) USB=
2 EHCI Controller #2 [8086:293c] (rev 03) (prog-if 20 [EHCI])
> 	Subsystem: Lenovo Device [17aa:20f1]
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin D routed to IRQ 23
> 	Region 0: Memory at fc226c00 (32-bit, non-prefetchable) [size=3D1K]
> 	Capabilities: <access denied>
> 	Kernel driver in use: ehci_hcd
>=20
> 00:1b.0 Audio device [0403]: Intel Corporation 82801I (ICH9 Family) HD Au=
dio Controller [8086:293e] (rev 03)
> 	Subsystem: Lenovo Device [17aa:20f2]
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Interrupt: pin B routed to IRQ 17
> 	Region 0: Memory at fc020000 (64-bit, non-prefetchable) [size=3D16K]
> 	Capabilities: <access denied>
> 	Kernel driver in use: HDA Intel
>=20
> 00:1c.0 PCI bridge [0604]: Intel Corporation 82801I (ICH9 Family) PCI Exp=
ress Port 1 [8086:2940] (rev 03) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=3D00, secondary=3D02, subordinate=3D02, sec-latency=3D0
> 	I/O behind bridge: 00008000-00008fff
> 	Memory behind bridge: bc000000-bc1fffff
> 	Prefetchable memory behind bridge: 00000000bc200000-00000000bc3fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort=
- <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: <access denied>
> 	Kernel driver in use: pcieport
>=20
> 00:1c.1 PCI bridge [0604]: Intel Corporation 82801I (ICH9 Family) PCI Exp=
ress Port 2 [8086:2942] (rev 03) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=3D00, secondary=3D03, subordinate=3D03, sec-latency=3D0
> 	I/O behind bridge: 00009000-00009fff
> 	Memory behind bridge: f4300000-f43fffff
> 	Prefetchable memory behind bridge: 00000000bc400000-00000000bc5fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort=
- <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: <access denied>
> 	Kernel driver in use: pcieport
>=20
> 00:1c.3 PCI bridge [0604]: Intel Corporation 82801I (ICH9 Family) PCI Exp=
ress Port 4 [8086:2946] (rev 03) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=3D00, secondary=3D05, subordinate=3D0c, sec-latency=3D0
> 	I/O behind bridge: 00002000-00002fff
> 	Memory behind bridge: f8000000-f9ffffff
> 	Prefetchable memory behind bridge: 00000000f4000000-00000000f40fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort=
- <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: <access denied>
> 	Kernel driver in use: pcieport
>=20
> 00:1c.4 PCI bridge [0604]: Intel Corporation 82801I (ICH9 Family) PCI Exp=
ress Port 5 [8086:2948] (rev 03) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=3D00, secondary=3D0d, subordinate=3D14, sec-latency=3D0
> 	I/O behind bridge: 00003000-00003fff
> 	Memory behind bridge: fa000000-fbffffff
> 	Prefetchable memory behind bridge: 00000000f4100000-00000000f41fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort=
- <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: <access denied>
> 	Kernel driver in use: pcieport
>=20
> 00:1d.0 USB Controller [0c03]: Intel Corporation 82801I (ICH9 Family) USB=
 UHCI Controller #1 [8086:2934] (rev 03) (prog-if 00 [UHCI])
> 	Subsystem: Lenovo Device [17aa:20f0]
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin A routed to IRQ 16
> 	Region 4: I/O ports at 18c0 [size=3D32]
> 	Capabilities: <access denied>
> 	Kernel driver in use: uhci_hcd
>=20
> 00:1d.1 USB Controller [0c03]: Intel Corporation 82801I (ICH9 Family) USB=
 UHCI Controller #2 [8086:2935] (rev 03) (prog-if 00 [UHCI])
> 	Subsystem: Lenovo Device [17aa:20f0]
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin B routed to IRQ 17
> 	Region 4: I/O ports at 18e0 [size=3D32]
> 	Capabilities: <access denied>
> 	Kernel driver in use: uhci_hcd
>=20
> 00:1d.2 USB Controller [0c03]: Intel Corporation 82801I (ICH9 Family) USB=
 UHCI Controller #3 [8086:2936] (rev 03) (prog-if 00 [UHCI])
> 	Subsystem: Lenovo Device [17aa:20f0]
> 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin C routed to IRQ 18
> 	Region 4: I/O ports at 1c00 [size=3D32]
> 	Capabilities: <access denied>
> 	Kernel driver in use: uhci_hcd
>=20
> 00:1d.7 USB Controller [0c03]: Intel Corporation 82801I (ICH9 Family) USB=
2 EHCI Controller #1 [8086:293a] (rev 03) (prog-if 20 [EHCI])
> 	Subsystem: Lenovo Device [17aa:20f1]
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin D routed to IRQ 19
> 	Region 0: Memory at fc227000 (32-bit, non-prefetchable) [size=3D1K]
> 	Capabilities: <access denied>
> 	Kernel driver in use: ehci_hcd
>=20
> 00:1e.0 PCI bridge [0604]: Intel Corporation 82801 Mobile PCI Bridge [808=
6:2448] (rev 93) (prog-if 01 [Subtractive decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Bus: primary=3D00, secondary=3D15, subordinate=3D18, sec-latency=3D32
> 	I/O behind bridge: 00004000-00007fff
> 	Memory behind bridge: f4800000-f7ffffff
> 	Prefetchable memory behind bridge: 00000000f0000000-00000000f3ffffff
> 	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbo=
rt- <MAbort+ <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: <access denied>
>=20
> 00:1f.0 ISA bridge [0601]: Intel Corporation ICH9M-E LPC Interface Contro=
ller [8086:2917] (rev 03)
> 	Subsystem: Lenovo Device [17aa:20f5]
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Capabilities: <access denied>
>=20
> 00:1f.2 SATA controller [0106]: Intel Corporation ICH9M/M-E SATA AHCI Con=
troller [8086:2929] (rev 03) (prog-if 01 [AHCI 1.0])
> 	Subsystem: Lenovo Device [17aa:20f8]
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx+
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 	Interrupt: pin B routed to IRQ 29
> 	Region 0: I/O ports at 1c48 [size=3D8]
> 	Region 1: I/O ports at 183c [size=3D4]
> 	Region 2: I/O ports at 1c40 [size=3D8]
> 	Region 3: I/O ports at 1838 [size=3D4]
> 	Region 4: I/O ports at 1c20 [size=3D32]
> 	Region 5: Memory at fc226000 (32-bit, non-prefetchable) [size=3D2K]
> 	Capabilities: <access denied>
> 	Kernel driver in use: ahci
>=20
> 00:1f.3 SMBus [0c05]: Intel Corporation 82801I (ICH9 Family) SMBus Contro=
ller [8086:2930] (rev 03)
> 	Subsystem: Lenovo Device [17aa:20f9]
> 	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR+ FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
> 	Interrupt: pin A routed to IRQ 23
> 	Region 0: Memory at fc227400 (64-bit, non-prefetchable) [size=3D256]
> 	Region 4: I/O ports at 1c60 [size=3D32]
> 	Kernel driver in use: i801_smbus
>=20
> 03:00.0 Network controller [0280]: Intel Corporation PRO/Wireless 5100 AG=
N [Shiloh] Network Connection [8086:4237]
> 	Subsystem: Intel Corporation WiFi Link 5100 AGN [8086:1211]
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 30
> 	Region 0: Memory at f4300000 (64-bit, non-prefetchable) [size=3D8K]
> 	Capabilities: <access denied>
> 	Kernel driver in use: iwlagn
>=20
> 15:00.0 CardBus bridge [0607]: Ricoh Co Ltd RL5c476 II [1180:0476] (rev b=
a)
> 	Subsystem: Lenovo Device [17aa:20c6]
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 168, Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 16
> 	Region 0: Memory at f4800000 (32-bit, non-prefetchable) [size=3D4K]
> 	Bus: primary=3D15, secondary=3D16, subordinate=3D17, sec-latency=3D176
> 	Memory window 0: f0000000-f3fff000 (prefetchable)
> 	Memory window 1: c0000000-c3fff000
> 	I/O window 0: 00004000-000040ff
> 	I/O window 1: 00004400-000044ff
> 	BridgeCtl: Parity- SERR- ISA- VGA- MAbort- >Reset- 16bInt+ PostWrite+
> 	16-bit legacy interface ports at 0001
> 	Kernel driver in use: yenta_cardbus
>=20
> 15:00.1 FireWire (IEEE 1394) [0c00]: Ricoh Co Ltd R5C832 IEEE 1394 Contro=
ller [1180:0832] (rev 04) (prog-if 10 [OHCI])
> 	Subsystem: Lenovo Device [17aa:20c7]
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR+ FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 32 (500ns min, 1000ns max), Cache Line Size: 64 bytes
> 	Interrupt: pin B routed to IRQ 17
> 	Region 0: Memory at f4801000 (32-bit, non-prefetchable) [size=3D2K]
> 	Capabilities: <access denied>
> 	Kernel driver in use: firewire_ohci
>=20
>=20
> ** USB devices:
> Bus 008 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
> Bus 007 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
> Bus 006 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
> Bus 005 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
> Bus 004 Device 003: ID 0a5c:2145 Broadcom Corp. Bluetooth with Enhanced D=
ata Rate II
> Bus 004 Device 002: ID 08ff:2810 AuthenTec, Inc. AES2810
> Bus 004 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
> Bus 003 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
> Bus 002 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
> Bus 001 Device 004: ID 17ef:1004 Lenovo=20
> Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
>=20
>=20
> -- System Information:
> Debian Release: squeeze/sid
>   APT prefers testing
>   APT policy: (990, 'testing'), (500, 'unstable'), (101, 'experimental')
> Architecture: amd64 (x86_64)
>=20
> Kernel: Linux 2.6.32-5-amd64 (SMP w/2 CPU cores)
> Locale: LANG=3Den_US.UTF-8, LC_CTYPE=3Den_US.UTF-8 (charmap=3DUTF-8)
> Shell: /bin/sh linked to /bin/dash
>=20
> Versions of packages linux-image-2.6.32-5-amd64 depends on:
> ii  debconf [debconf 1.5.32                  Debian configuration managem=
ent sy
> ii  initramfs-tools  0.94.4                  tools for generating an init=
ramfs
> ii  linux-base       2.6.34-1~experimental.1 Linux image base package
> ii  module-init-tool 3.12~pre2-3             tools for managing Linux ker=
nel mo
>=20
> Versions of packages linux-image-2.6.32-5-amd64 recommends:
> ii  firmware-linux-f 2.6.34-1~experimental.1 Binary firmware for various =
driver
>=20
> Versions of packages linux-image-2.6.32-5-amd64 suggests:
> pn  grub | lilo                   <none>     (no description available)
> ii  linux-doc-2.6.32              2.6.32-9   Linux kernel specific docume=
ntatio
>=20
> Versions of packages linux-image-2.6.32-5-amd64 is related to:
> pn  firmware-bnx2                 <none>     (no description available)
> pn  firmware-bnx2x                <none>     (no description available)
> pn  firmware-ipw2x00              <none>     (no description available)
> pn  firmware-ivtv                 <none>     (no description available)
> ii  firmware-iwlwifi              0.24       Binary firmware for Intel Wi=
reless
> ii  firmware-linux                0.24       Binary firmware for various =
driver
> ii  firmware-linux-nonfree        0.24       Binary firmware for various =
driver
> pn  firmware-qlogic               <none>     (no description available)
> pn  firmware-ralink               <none>     (no description available)
> pn  xen-hypervisor                <none>     (no description available)
>=20
> -- debconf information:
>   shared/kernel-image/really-run-bootloader: true
>   linux-image-2.6.32-5-amd64/postinst/depmod-error-initrd-2.6.32-5-amd64:=
 false
>   linux-image-2.6.32-5-amd64/prerm/removing-running-kernel-2.6.32-5-amd64=
: true
>   linux-image-2.6.32-5-amd64/postinst/missing-firmware-2.6.32-5-amd64:
>   linux-image-2.6.32-5-amd64/postinst/bootloader-test-error-2.6.32-5-amd6=
4:
>   linux-image-2.6.32-5-amd64/postinst/bootloader-error-2.6.32-5-amd64:
>   linux-image-2.6.32-5-amd64/prerm/would-invalidate-boot-loader-2.6.32-5-=
amd64: true
>=20
>=20
>=20

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-lCL1fv7YrWee2A19YAkP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATARmS+e/yOyVhhEJAQKK8xAAlbIBKK8xTPJNKHITr/CJuqqZ8P0RTBGe
Ag3nMTuTXLK6a1SIUtf2iOpPH7GNPcyTLOtGFGyEN3tiQlAq2C+zHHtmVwd5ldMf
aXyONwYwZ5LyyoqPFTIIF4McRjAc9JsO+pQZpqCamNR/rNZ/dpfAisovHeCOJfVq
ZrJIh9vUGByzAnaX2NA8Ztq0BFFpxl2uVC8gA2jKiGzhQl2kRkZy2An2kuYOmRps
Rnm51xGXA/6BOi+RbfxtqRUvbx6YfkjYbKICqkpzv19sXBAiawb/UiqZAaUt4FmX
E+Rfyw9YtFSp5EvdG88Io5KaRtuw/jTgnpzdUFeIXxVHe+PF2Xd+eVHPm26vv0BV
ORLbaLWk1hsyCsWgAUo2uCJ2w/emtVqgAHghmN3i7sKlM0I/9vKalmfoyi5E4dmt
Mbo0NkDp329npvwEFftNHSHuJ9SMezQnxWQp8mMlSVYB2oqHDhSybFIqLNFgFCuA
oXKgKiD3PBT1SMWDrHEFnroM4CTW43PAbrOXo+78ejMl/uY9LyPd1KzpOOhp29qM
LMJlAFOrI3hG9iRpDnD/28MZPlhIinIwZcjAyy/KIQFKNhuWQdAYqrsRjVoUO5JL
ioFoIxYY3AdyC+bjFmfsxac64dy/Vpc7G9PT3UamWewEpgWaw5sSbY66a871z9v0
akETZ6vsVL8=
=5Ems
-----END PGP SIGNATURE-----

--=-lCL1fv7YrWee2A19YAkP--
