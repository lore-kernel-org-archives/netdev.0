From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#566079: linux-image-2.6.32-trunk-sparc64: SBUS sunbmac
 module doesn't work
Date: Thu, 21 Jan 2010 01:23:53 +0000
Message-ID: <1264037033.2169.20.camel@localhost>
References: <20100121002618.1662.62326.reportbug@sparc.auriasistemas.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-Sywc/5vrtlvJ5GnprVeE"
Cc: David Garabana Barro <dgb97@yahoo.com>, 566079@bugs.debian.org,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:41734 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751836Ab0AUBYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 20:24:06 -0500
In-Reply-To: <20100121002618.1662.62326.reportbug@sparc.auriasistemas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Sywc/5vrtlvJ5GnprVeE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2010-01-21 at 01:26 +0100, David Garabana Barro wrote:
> Package: linux-2.6
> Version: 2.6.32-5
> Severity: important
>=20
>=20
> Since I upgraded my Ultra 1 Sparc from lenny to testing/squeeze, I cannot=
 make Sbus Big Mac to run.
> With lenny's 2.6.26, it worked OK, but with both testing's 2.6.30 and sid=
's 2.6.32, I get the following message:
>=20
> [  723.175812] sunbmac.c:v2.1 August 26, 2008 David S. Miller (davem@dave=
mloft.net)
> [  723.176341] BIGMAC: Cannot map BigMAC transceiver registers.          =
         =20
>=20
> and card is not itialized

David, any ideas on this?

Ben.

> -- Package-specific info:
> ** Version:
> Linux version 2.6.32-trunk-sparc64 (Debian 2.6.32-5) (ben@decadent.org.uk=
) (gcc version 4.3.4 (Debian 4.3.4-6) ) #1 Sun Jan 10 23:56:57 UTC 2010
>=20
> ** Command line:
> root=3D/dev/sda2 ro
>=20
> ** Not tainted
>=20
> ** Kernel log:
> [   40.157359] Initializing cgroup subsys net_cls
> [   40.160145] devtmpfs: initialized
> [   40.164253] regulator: core version 0.5
> [   40.164997] NET: Registered protocol family 16
> [   40.176025] SYSIO: UPA portID ffffffff, at 000001fe00000000
> [   40.197929] bio: create slab <bio-0> at 0
> [   40.199174] vgaarb: loaded
> [   40.201734] /sbus@1f,0/eeprom@f,1200000: Mostek regs at 0x1fff1200000
> [   40.202491] AUXIO: Found device at /sbus@1f,0/auxio@f,1900000
> [   40.202688] Switching to clocksource tick
> [   40.222095] NET: Registered protocol family 2
> [   40.223501] IP route cache hash table entries: 4096 (order: 2, 32768 b=
ytes)
> [   40.228283] TCP established hash table entries: 16384 (order: 5, 26214=
4 bytes)
> [   40.229980] TCP bind hash table entries: 16384 (order: 4, 131072 bytes=
)
> [   40.231014] TCP: Hash tables configured (established 16384 bind 16384)
> [   40.231121] TCP reno registered
> [   40.232194] NET: Registered protocol family 1
> [   40.232983] Unpacking initramfs...
> [   43.336462] Freeing initrd memory: 7437k freed
> [   43.340982] audit: initializing netlink socket (disabled)
> [   43.341170] type=3D2000 audit(3.268:1): initialized
> [   43.342521] HugeTLB registered 4 MB page size, pre-allocated 0 pages
> [   43.372797] VFS: Disk quotas dquot_6.5.2
> [   43.373902] Dquot-cache hash table entries: 1024 (order 0, 8192 bytes)
> [   43.375254] msgmni has been set to 610
> [   43.378037] alg: No test for stdrng (krng)
> [   43.379024] Block layer SCSI generic (bsg) driver version 0.4 loaded (=
major 253)
> [   43.379169] io scheduler noop registered
> [   43.379256] io scheduler anticipatory registered
> [   43.379346] io scheduler deadline registered
> [   43.379644] io scheduler cfq registered (default)
> [   43.414394] Console: switching to colour frame buffer device 144x56
> [   43.444394] /sbus@1f,0/cgsix@2,0: CGsix [TGX sparc] at 0:1ff20000000
> [   43.467803] [drm] Initialized drm 1.1.0 20060810
> [   43.468731] f005a290: ttyS0 at MMIO 0x1fff1100000 (irq =3D 9) is a zs
> [   43.469525] f005a290: ttyS1 at MMIO 0x1fff1100004 (irq =3D 9) is a zs
> [   43.471096] f005b730: Keyboard at MMIO 0x1fff1000000 (irq =3D 9) is a =
zs
> [   43.471514] f005b730: Mouse at MMIO 0x1fff1000004 (irq =3D 9) is a zs
> [   43.473812] Floppy drive(s): fd0 is 1.44M
> [   43.488079] FDC 0 is a post-1991 82077
> [   43.490592] Uniform Multi-Platform E-IDE driver
> [   43.491286] ide-gd driver 1.18
> [   43.493012] mice: PS/2 mouse device common for all mice
> [   43.495474] rtc-m48t59 rtc-m48t59.0: rtc core: registered m48t59 as rt=
c0
> [   43.503137] TCP cubic registered
> [   43.505897] NET: Registered protocol family 10
> [   43.514955] lo: Disabled Privacy Extensions
> [   43.521346] Mobile IPv6
> [   43.521567] NET: Registered protocol family 17
> [   43.523033] registered taskstats version 1
> [   43.523792] rtc-m48t59 rtc-m48t59.0: setting system clock to 2010-01-2=
0 20:27:11 UTC (1264019231)
> [   44.148899] input: Sun Type 5 keyboard as /devices/root/f0059940/f005b=
730/serio0/input/input0
> [   44.150175] input: Sun Mouse as /devices/root/f0059940/f005b730/serio1=
/input/input1
> [   45.243522] SCSI subsystem initialized
> [   45.366426] esp: esp0, regs[1ffe8800000:1ffe8400000] irq[10]
> [   45.366905] esp: esp0 is a FAS100A, 40 MHz (ccf=3D0), SCSI ID 7
> [   48.370920] scsi0 : esp
> [   48.395486] scsi 0:0:0:0: Direct-Access     SEAGATE  ST32171W SUN2.1G =
7462 PQ: 0 ANSI: 2
> [   48.415078] scsi target0:0:0: Beginning Domain Validation
> [   48.436556] scsi target0:0:0: FAST-10 SCSI 10.0 MB/s ST (100 ns, offse=
t 15)
> [   48.456707] scsi target0:0:0: Domain Validation skipping write tests
> [   48.467307] scsi target0:0:0: Ending Domain Validation
> [   49.684012] scsi 0:0:6:0: CD-ROM            NEC      CD-ROM DRIVE:466 =
1.17 PQ: 0 ANSI: 2
> [   49.695874] scsi target0:0:6: Beginning Domain Validation
> [   49.713155] scsi target0:0:6: FAST-10 SCSI 10.0 MB/s ST (100 ns, offse=
t 15)
> [   49.727605] scsi target0:0:6: Domain Validation skipping write tests
> [   49.739994] scsi target0:0:6: Ending Domain Validation
> [   50.015670] sd 0:0:0:0: [sda] 4157201 512-byte logical blocks: (2.12 G=
B/1.98 GiB)
> [   50.033169] sr0: scsi3-mmc drive: 17x/40x cd/rw xa/form2 cdda tray
> [   50.046490] Uniform CD-ROM driver Revision: 3.20
> [   50.060144] sd 0:0:0:0: [sda] Write Protect is off
> [   50.074007] sd 0:0:0:0: [sda] Mode Sense: cf 00 10 08
> [   50.078835] sr 0:0:6:0: Attached scsi CD-ROM sr0
> [   50.087989] sd 0:0:0:0: [sda] Write cache: disabled, read cache: enabl=
ed, supports DPO and FUA
> [   50.116127]  sda: sda1 sda2 sda3 sda4
> [   50.171199] sd 0:0:0:0: [sda] Attached SCSI disk
> [   50.399269] sd 0:0:0:0: Attached scsi generic sg0 type 0
> [   50.422011] sr 0:0:6:0: Attached scsi generic sg1 type 5
> [   51.380669] REISERFS (device sda2): found reiserfs format "3.6" with s=
tandard journal
> [   51.396086] REISERFS (device sda2): using ordered data mode
> [   51.418846] REISERFS (device sda2): journal params: device sda2, size =
8192, journal first block 18, max trans len 1024, max batch 900, max commit=
 age 30, max trans age 30
> [   51.465245] REISERFS (device sda2): checking transaction log (sda2)
> [   51.526920] REISERFS (device sda2): Using r5 hash to sort names
> [   55.987728] udev: starting version 150
> [   64.932969] Adding 120464k swap on /dev/sda4.  Priority:-1 extents:1 a=
cross:120464k=20
> [   66.631264] loop: module loaded
> [   66.851513] sunlance.c:v2.02 8/24/03 Miguel de Icaza (miguel@nuclecu.u=
nam.mx)
> [   66.866574] SunLance: using auto-carrier-detection.
> [   66.915188] eth0: LANCE 08:00:20:85:b2:d8
> [   67.322444] sunbmac.c:v2.1 August 26, 2008 David S. Miller (davem@dave=
mloft.net)
> [   67.336615] BIGMAC: Cannot map BigMAC transceiver registers.
> [   70.763869] kjournald starting.  Commit interval 5 seconds
> [   70.783172] EXT3 FS on sda1, internal journal
> [   70.797752] EXT3-fs: mounted filesystem with ordered data mode.
> [   73.298821] eth0: Carrier Lost, trying TPE
> [   83.285717] fuse init (API version 7.13)
> [   83.319288] eth0: no IPv6 routers present
> [  112.241695] end_request: I/O error, dev fd0, sector 0
> [  723.175812] sunbmac.c:v2.1 August 26, 2008 David S. Miller (davem@dave=
mloft.net)
> [  723.176341] BIGMAC: Cannot map BigMAC transceiver registers.
>=20
> ** Model information
> cpu		: TI UltraSparc I   (SpitFire)
> fpu		: UltraSparc I integrated FPU
> pmu		: ultra12
> prom		: OBP 3.35.0 2004/04/19 12:15
> type		: sun4u
>=20
> ** Loaded modules:
> Module                  Size  Used by
> sunbmac                12583  0=20
> fuse                   48655  1=20
> ext3                  124920  1=20
> jbd                    34168  1 ext3
> mbcache                 5131  1 ext3
> sunqe                   9479  0=20
> sunlance               11439  0=20
> loop                   11063  0=20
> evdev                   7935  2=20
> reiserfs              277234  1=20
> sg                     20515  0=20
> sr_mod                 13978  0=20
> sd_mod                 31396  4=20
> cdrom                  33647  1 sr_mod
> crc_t10dif              1292  1 sd_mod
> sun_esp                 5978  0=20
> esp_scsi               22350  4 sun_esp
> scsi_transport_spi     20729  1 esp_scsi
> scsi_mod              132029  6 sg,sr_mod,sd_mod,sun_esp,esp_scsi,scsi_tr=
ansport_spi
>=20
> ** Network interface configuration:
>=20
> auto lo
> iface lo inet loopback
>=20
> auto eth0
> iface eth0 inet static
> address 192.168.30.50
> netmask 255.255.255.0
> gateway 192.168.30.100
>=20
> auto eth1
> iface eth1 inet static
> address 192.168.30.51
> netmask 255.255.255.0
> gateway 192.168.30.100
>=20
>=20
>=20
>=20
>=20
> ** Network status:
> *** IP interfaces and addresses:
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN=20
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>     inet 127.0.0.1/8 scope host lo
>     inet6 ::1/128 scope host=20
>        valid_lft forever preferred_lft forever
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast stat=
e UNKNOWN qlen 1000
>     link/ether 08:00:20:85:b2:d8 brd ff:ff:ff:ff:ff:ff
>     inet 192.168.30.50/24 brd 192.168.30.255 scope global eth0
>     inet6 fe80::a00:20ff:fe85:b2d8/64 scope link=20
>        valid_lft forever preferred_lft forever
>=20
> *** Device statistics:
> Inter-|   Receive                                                |  Trans=
mit
>  face |bytes    packets errs drop fifo frame compressed multicast|bytes  =
  packets errs drop fifo colls carrier compressed
>     lo:     560       8    0    0    0     0          0         0      56=
0       8    0    0    0     0       0          0
>   eth0:  832063    5273    0    0    0     0          0         0   94449=
6    3837    1    0    0    15       1          0
>=20
> *** Protocol statistics:
> Ip:
>     4956 total packets received
>     0 forwarded
>     0 incoming packets discarded
>     4956 incoming packets delivered
>     3517 requests sent out
> Icmp:
>     0 ICMP messages received
>     0 input ICMP message failed.
>     ICMP input histogram:
>     2 ICMP messages sent
>     0 ICMP messages failed
>     ICMP output histogram:
>         destination unreachable: 2
> IcmpMsg:
>         OutType3: 2
> Tcp:
>     10 active connections openings
>     2 passive connection openings
>     3 failed connection attempts
>     0 connection resets received
>     2 connections established
>     4421 segments received
>     2979 segments send out
>     0 segments retransmited
>     0 bad segments received.
>     0 resets sent
> Udp:
>     531 packets received
>     2 packets to unknown port received.
>     0 packet receive errors
>     536 packets sent
> UdpLite:
> TcpExt:
>     15 delayed acks sent
>     2 packets directly queued to recvmsg prequeue.
>     1400 packet headers predicted
>     85 acknowledgments not containing data payload received
>     2546 predicted acknowledgments
> IpExt:
>     InBcastPkts: 2
>     InOctets: 743851
>     OutOctets: 876142
>     InBcastOctets: 656
>=20
> *** Device features:
> eth0: 0x0
> lo: 0x13865
>=20
> ** PCI devices:
>=20
> ** Sound cards:
>=20
> -- System Information:
> Debian Release: squeeze/sid
>   APT prefers testing
>   APT policy: (900, 'testing'), (800, 'stable'), (700, 'unstable')
> Architecture: sparc (sparc64)
>=20
> Kernel: Linux 2.6.32-trunk-sparc64
> Locale: LANG=3Des_ES.UTF-8, LC_CTYPE=3Des_ES.UTF-8 (charmap=3DUTF-8)
> Shell: /bin/sh linked to /bin/bash
>=20
> Versions of packages linux-image-2.6.32-trunk-sparc64 depends on:
> ii  debconf [debconf-2.0]         1.5.28     Debian configuration managem=
ent sy
> ii  initramfs-tools [linux-initra 0.93.4     tools for generating an init=
ramfs
> ii  module-init-tools             3.11-1     tools for managing Linux ker=
nel mo
>=20
> Versions of packages linux-image-2.6.32-trunk-sparc64 recommends:
> ii  firmware-linux-free           2.6.32-5   Binary firmware for various =
driver
>=20
> Versions of packages linux-image-2.6.32-trunk-sparc64 suggests:
> pn  fdutils            <none>                (no description available)
> pn  linux-doc-2.6.32   <none>                (no description available)
> ii  silo               1.4.13a+git20070930-3 Sparc Improved LOader
>=20
> Versions of packages linux-image-2.6.32-trunk-sparc64 is related to:
> pn  firmware-bnx2                 <none>     (no description available)
> pn  firmware-bnx2x                <none>     (no description available)
> pn  firmware-ipw2x00              <none>     (no description available)
> pn  firmware-ivtv                 <none>     (no description available)
> pn  firmware-iwlwifi              <none>     (no description available)
> pn  firmware-linux                <none>     (no description available)
> pn  firmware-linux-nonfree        <none>     (no description available)
> pn  firmware-qlogic               <none>     (no description available)
> pn  firmware-ralink               <none>     (no description available)
>=20
> -- debconf information:
>   shared/kernel-image/really-run-bootloader: true
>   linux-image-2.6.32-trunk-sparc64/postinst/depmod-error-initrd-2.6.32-tr=
unk-sparc64: false
>   linux-image-2.6.32-trunk-sparc64/prerm/removing-running-kernel-2.6.32-t=
runk-sparc64: true
>   linux-image-2.6.32-trunk-sparc64/prerm/would-invalidate-boot-loader-2.6=
.32-trunk-sparc64: true
>   linux-image-2.6.32-trunk-sparc64/postinst/bootloader-error-2.6.32-trunk=
-sparc64:
>   linux-image-2.6.32-trunk-sparc64/postinst/missing-firmware-2.6.32-trunk=
-sparc64:
>   linux-image-2.6.32-trunk-sparc64/postinst/bootloader-test-error-2.6.32-=
trunk-sparc64:
>=20
>=20
>=20

--=20
Ben Hutchings
Any smoothly functioning technology is indistinguishable from a rigged demo=
.

--=-Sywc/5vrtlvJ5GnprVeE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS1espOe/yOyVhhEJAQJebg/+OrDjK2KoSOmTA9wA1R0UJsNs2QvDNOtD
241hd1P68AqPVtEO3lCYWmLt6YsvWWnNfLRsmB1rTpbjMlt28lcgzNDHLYnz1cZO
U4kvAIU2E4LynkSWqSwLt+4zl+Ddv1S8urInt3BJhfgdqtsgRAglcWpJ/MBviR/n
2ml5ELxCH6COs+A9AetbtliZFTD0Do48EazJT/mhFyPEMamgt6aUIjCBI0yiPdId
Ro9eiO9y72HH9/fit5AzEKwTdqJhQn+uceKEo+PYDcjRA6fiGdLmyPnbZOwp1zEk
gMQrYinPj+jO5YybKKiAD8eGAAgaSxInMGRNnxylouT8fkyidL03eExaQqGS8Zkh
e17nR8opv8fa6YYi64qiiOkqZsay3Uk42dKxu3q9GtyPfSyvznp1G4w15HVnUUOe
+s/MlEvEC2eQWJ7vgvVI9XoP3NJGdRBn58UyeIaOZuqPCO6jyvfsrnkeKJvtlvJY
Ymgf9TIZP2wnlFcXZExcloNekQRZocqfVFEaZWHq4FiUMvNGT3o2HRT13ChtYOJg
jVs8nG2gmy6VsIsLS+ThOaO1r2Toi9/XiMpbWS3GKU6a14hz39BOScLA8/8xhets
hrXs4wtxgSkgPuE3Zxp7BUC6FmSzkjX0w+1XA8JNtnhpcG7BmzXq6fJ425wEKkzB
wiMLu3mYzC8=
=f53L
-----END PGP SIGNATURE-----

--=-Sywc/5vrtlvJ5GnprVeE--
