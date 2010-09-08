From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel Panic on OOM with 10 HTB rules
Date: Wed, 08 Sep 2010 16:45:37 +0200
Message-ID: <1283957137.2748.71.camel@edumazet-laptop>
References: <AANLkTinQbuN4Y6yUgHhjhOkLGe3GPk9aN5z1gasvQ-zW@mail.gmail.com>
	 <1283949778.2748.5.camel@edumazet-laptop>
	 <AANLkTimDW-tuTJagnpkFq3TX4t+c_-9UUyG8z-bwPuJ1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	shemminger@vyatta.com
To: Anand Raj Manickam <anandrm@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimDW-tuTJagnpkFq3TX4t+c_-9UUyG8z-bwPuJ1@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 08 septembre 2010 =C3=A0 19:39 +0530, Anand Raj Manickam a
=C3=A9crit :
> Please find the info below  ... its a long list though

> Sorry there was no stack trace :-(
>=20
>=20
> e5570#Out of memory: kill process 10240 (apache2) score 58700 or a ch=
ild
> Killed process 10240 (apache2) vsz:234800kB, anon-rss:1576kB, file-rs=
s:1212kB
> Out of memory: kill process 10241 (apache2) score 58700 or a child
> Killed process 10241 (apache2) vsz:234800kB, anon-rss:1576kB, file-rs=
s:1232kB
> Out of memory: kill process 16120 (java) score 19383 or a child
> Killed process 16120 (java) vsz:1240516kB, anon-rss:161428kB, file-rs=
s:7516kB
> Out of memory: kill process 2185 (mysqld) score 16377 or a child
> Killed process 2185 (mysqld) vsz:131020kB, anon-rss:15392kB, file-rss=
:5144kB
> Out of memory: kill process 10238 (apache2) score 3630 or a child
> Killed process 21304 (tcstat_total.cg) vsz:2848kB, anon-rss:192kB,
> file-rss:1016kB
> Out of memory: kill process 10238 (apache2) score 3273 or a child
> Killed process 10238 (apache2) vsz:13092kB, anon-rss:1408kB, file-rss=
:624kB
> Out of memory: kill process 21315 (tcstat_total.cg) score 712 or a ch=
ild
> Killed process 21315 (tcstat_total.cg) vsz:2848kB, anon-rss:192kB,
> file-rss:196kB
> Out of memory: kill process 1983 (rsyslogd) score 449 or a child
> Killed process 1983 (rsyslogd) vsz:28744kB, anon-rss:784kB, file-rss:=
912kB
> Out of memory: kill process 10236 (apache2) score 208 or a child
> Killed process 10236 (apache2) vsz:13320kB, anon-rss:1412kB, file-rss=
:1332kB
> Out of memory: kill process 4051 (login) score 77 or a child
> Killed process 4831 (bash) vsz:4556kB, anon-rss:396kB, file-rss:1336k=
B
> Out of memory: kill process 2728 (cron) score 58 or a child
> Killed process 2728 (cron) vsz:3716kB, anon-rss:156kB, file-rss:628kB
> Out of memory: kill process 2068 (mysqld_safe) score 45 or a child
> Killed process 2068 (mysqld_safe) vsz:2904kB, anon-rss:248kB, file-rs=
s:1084kB
> Out of memory: kill process 4051 (login) score 41 or a child
> Killed process 4051 (login) vsz:2680kB, anon-rss:252kB, file-rss:948k=
B
> Out of memory: kill process 2313 (inetd) score 31 or a child
> Killed process 2313 (inetd) vsz:2004kB, anon-rss:92kB, file-rss:496kB
> Out of memory: kill process 4045 (getty) score 28 or a child
> Killed process 4045 (getty) vsz:1816kB, anon-rss:68kB, file-rss:400kB
> Out of memory: kill process 4046 (getty) score 28 or a child
> Killed process 4046 (getty) vsz:1816kB, anon-rss:72kB, file-rss:400kB
> Out of memory: kill process 4047 (getty) score 28 or a child
> Killed process 4047 (getty) vsz:1816kB, anon-rss:72kB, file-rss:400kB
> Out of memory: kill process 4048 (getty) score 28 or a child
> Killed process 4048 (getty) vsz:1816kB, anon-rss:72kB, file-rss:400kB
> Out of memory: kill process 4049 (getty) score 28 or a child
> Killed process 4049 (getty) vsz:1816kB, anon-rss:68kB, file-rss:400kB
> Out of memory: kill process 4050 (getty) score 28 or a child
> Killed process 4050 (getty) vsz:1816kB, anon-rss:68kB, file-rss:400kB
> Kernel panic - not syncing: Out of memory and no killable processes..=
=2E
>=20
>=20
> > 2) cat /proc/interrupts
>=20
>            CPU0       CPU1       CPU2       CPU3
>   0:        250          0          0          0   IO-APIC-edge      =
timer
>   1:          0          0          0          2   IO-APIC-edge      =
i8042
>   2:          0          0          0          0    XT-PIC-XT        =
cascade
>   4:          0          0          0        226   IO-APIC-edge      =
serial
>   8:          0          0          0          2   IO-APIC-edge      =
rtc0
>  12:          0          0          0          3   IO-APIC-edge      =
i8042
>  19:          0      10673          0          0   IO-APIC-fasteoi   =
ata_piix
>  33:          0          0          0          0   PCI-MSI-edge      =
pciehp
>  34:          0          0          0          0   PCI-MSI-edge      =
pciehp
>  35:          0          0          0          1   PCI-MSI-edge      =
pciehp
>  36:          1          0          0          0   PCI-MSI-edge      =
pciehp
>  37:          1          0          0          0   PCI-MSI-edge      =
pciehp
>  38:          0          1          0          0   PCI-MSI-edge      =
pciehp
>  39:         94          0          0          0   PCI-MSI-edge      =
eth0
>  40:         88          6          0          0   PCI-MSI-edge      =
eth1
>  41:          0         88          6          0   PCI-MSI-edge      =
eth2
>  42:          0         88          6          0   PCI-MSI-edge      =
eth3
>  43:          0          0         92          0   PCI-MSI-edge      =
eth4-rx-0
>  44:          0          0          0          0   PCI-MSI-edge      =
eth4-tx-0
>  45:          3          0          0          0   PCI-MSI-edge      =
eth4
>  46:          0          4         88          0   PCI-MSI-edge      =
eth5-rx-0
>  47:          0          0          0          0   PCI-MSI-edge      =
eth5-tx-0
>  48:          0          0          3          0   PCI-MSI-edge      =
eth5
>  49:          0          0          4         88   PCI-MSI-edge      =
eth6-rx-0
>  50:          0          0          0          0   PCI-MSI-edge      =
eth6-tx-0
>  51:          0          0          0          3   PCI-MSI-edge      =
eth6
>  52:          4          0          0         88   PCI-MSI-edge      =
eth7-rx-0
>  53:          0          0          0          0   PCI-MSI-edge      =
eth7-tx-0
>  54:          0          3          0          0   PCI-MSI-edge      =
eth7
> NMI:          0          0          0          0   Non-maskable inter=
rupts
> LOC:     196962     205933     209322     208530   Local timer interr=
upts
> SPU:          0          0          0          0   Spurious interrupt=
s
> PMI:          0          0          0          0   Performance
> monitoring interrupts
> PND:          0          0          0          0   Performance pendin=
g work
> RES:       4866        761        416        467   Rescheduling inter=
rupts
> CAL:         39        102        107        109   Function call inte=
rrupts
> TLB:       6019       5481       4678       6759   TLB shootdowns
> TRM:          0          0          0          0   Thermal event inte=
rrupts
> THR:          0          0          0          0   Threshold APIC int=
errupts
> MCE:          0          0          0          0   Machine check exce=
ptions
> MCP:          2          2          2          2   Machine check poll=
s
> ERR:          3
> MIS:          0
>=20
>=20
>=20
> > 3) ifconfig -a
> br0       Link encap:Ethernet  HWaddr 00:90:0b:14:ac:38
>           inet addr:192.168.164.222  Bcast:192.168.167.255  Mask:255.=
255.252.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:50 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:2300 (2.2 KiB)  TX bytes:0 (0.0 B)
>=20
> eth0      Link encap:Ethernet  HWaddr 00:90:0b:14:ac:38
>           UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
>           RX packets:10119 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:20075 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:6654384 (6.3 MiB)  TX bytes:1427890 (1.3 MiB)
>           Memory:fb580000-fb5a0000
>=20
> eth1      Link encap:Ethernet  HWaddr 00:90:0b:14:ac:39
>           UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
>           RX packets:20039 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:10155 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:1495356 (1.4 MiB)  TX bytes:6646438 (6.3 MiB)
>           Memory:fb5e0000-fb600000
>=20
> eth2      Link encap:Ethernet  HWaddr 00:90:0b:14:ac:3a
>           UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
>           RX packets:19190 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:9727 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:1432004 (1.3 MiB)  TX bytes:6365028 (6.0 MiB)
>           Memory:fb680000-fb6a0000
>=20
> eth3      Link encap:Ethernet  HWaddr 00:90:0b:14:ac:3b
>           UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
>           RX packets:9689 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:19228 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:6372426 (6.0 MiB)  TX bytes:1367600 (1.3 MiB)
>           Memory:fb6e0000-fb700000
> eth4      Link encap:Ethernet  HWaddr 00:90:0b:15:79:18
>           UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
>           RX packets:9252 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:18354 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:6085260 (5.8 MiB)  TX bytes:1305576 (1.2 MiB)
>           Memory:fb8e0000-fb900000
>=20
> eth5      Link encap:Ethernet  HWaddr 00:90:0b:15:79:19
>           UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
>           RX packets:18316 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:9290 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:1366920 (1.3 MiB)  TX bytes:6078300 (5.7 MiB)
>           Memory:fb9e0000-fba00000
>=20
> eth6      Link encap:Ethernet  HWaddr 00:90:0b:15:79:1a
>           UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
>           RX packets:18709 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:9484 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:1396126 (1.3 MiB)  TX bytes:6204656 (5.9 MiB)
>           Memory:fbae0000-fbb00000
>=20
> eth7      Link encap:Ethernet  HWaddr 00:90:0b:15:79:1b
>           UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
>           RX packets:9446 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:18746 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:6211812 (5.9 MiB)  TX bytes:1333280 (1.2 MiB)
>           Memory:fbbe0000-fbc00000
>=20
> imq0      Link encap:UNSPEC  HWaddr
> 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
>           UP RUNNING NOARP  MTU:16000  Metric:1
>           RX packets:129112 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:129114 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:11000
>           RX bytes:31060964 (29.6 MiB)  TX bytes:31062207 (29.6 MiB)
>=20
> imq1      Link encap:UNSPEC  HWaddr
> 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
>           NOARP  MTU:16000  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:11000
>  RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
>=20
> imq2      Link encap:UNSPEC  HWaddr
> 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
>           NOARP  MTU:16000  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:11000
>           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
>=20
> imq3      Link encap:UNSPEC  HWaddr
> 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
>           NOARP  MTU:16000  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:11000
>           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
>=20
> imq4      Link encap:UNSPEC  HWaddr
> 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
>           NOARP  MTU:16000  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:11000
>           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
>=20
> imq5      Link encap:UNSPEC  HWaddr
> 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
>           NOARP  MTU:16000  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:11000
>           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
>=20
> imq6      Link encap:UNSPEC  HWaddr
> 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
>           NOARP  MTU:16000  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:11000
>           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
> imq7      Link encap:UNSPEC  HWaddr
> 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
>           NOARP  MTU:16000  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:11000
>           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
>=20
> lo        Link encap:Local Loopback
>           inet addr:127.0.0.1  Mask:255.0.0.0
>           UP LOOPBACK RUNNING  MTU:16436  Metric:1
>           RX packets:14454 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:14454 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:1962561 (1.8 MiB)  TX bytes:1962561 (1.8 MiB)
>=20
>=20
>=20
> > 4) cat /proc/sys/vm/min_free_kbytes
> 3806
>=20
> > 5) cat /proc/meminfo
>=20
> MemTotal:       12462064 kB
> MemFree:        12265628 kB
> Buffers:           29672 kB
> Cached:            64800 kB
> SwapCached:            0 kB
> Active:            87748 kB
> Inactive:          75756 kB
> Active(anon):      69040 kB
> Inactive(anon):      288 kB
> Active(file):      18708 kB
> Inactive(file):    75468 kB
> Unevictable:           0 kB
> Mlocked:               0 kB
> HighTotal:      11660872 kB
> HighFree:       11515792 kB
> LowTotal:         801192 kB
> LowFree:          749836 kB
> SwapTotal:      27226684 kB
> SwapFree:       27226684 kB
> Dirty:               120 kB
> Writeback:             0 kB
> AnonPages:         69032 kB
> Mapped:            14508 kB
> Shmem:               296 kB
> Slab:              15728 kB
> SReclaimable:       6044 kB
> SUnreclaim:         9684 kB
> KernelStack:        1376 kB
> PageTables:          996 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:    33457716 kB
> Committed_AS:     848336 kB
> VmallocTotal:     122880 kB
> VmallocUsed:        9468 kB
> VmallocChunk:     106708 kB
> DirectMap4k:        6136 kB
> DirectMap2M:      907264 kB
>=20
>=20
> > for each eth*
> >  ethtool -g eth*
>=20
> e5570#ethtool -g eth0 - eth7 ( have the same config)
> Ring parameters for eth0:
> Pre-set maximums:
> RX:             4096
> RX Mini:        0
> RX Jumbo:       0
> TX:             4096
> Current hardware settings:
> RX:             256
> RX Mini:        0
> RX Jumbo:       0
> TX:             256

Thanks

You are running a 32bit kernel, so kernel can _not_ use more than 800
Mbytes of memory (Lowmem) for his own needs (including all network
buffers)

If you cannot switch to 64bit kernel, then you are forced to use lower
queue lengths (I see your imq devices use insane 11000 txqueuelen)

Each frame use 4K, maybe 16K, it depends on MTU.

even if we dont take into account other needs :
11000 * 16K =3D 170 Mbytes per imqX
1000 * 4K =3D 4Mbytes per ethX

170M * 8 -> memory overflow

Also /proc/sys/vm/min_free_kbytes  limit is probably too small.

Really, using a 32bit kernel on this machine is not wise.

Even reducing physical ram to 4GB would be better, you would get more
Lowmem memory ;)

Since vmalloc is not used very much on your machine you can reduce
vmalloc window from 128M to 32M to save 96MB of low mem
(boot parameter : vmalloc=3D32M )



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
