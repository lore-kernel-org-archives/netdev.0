From: =?iso-8859-15?Q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
Subject: Re: [BUG] 2.6.37-rc5 Memory leak in net/ipv4/udp.c
Date: Fri, 17 Dec 2010 15:28:12 +0100
Message-ID: <19723.29564.671887.636356@ipc1.ka-ro>
References: <19723.14557.349975.821418@ipc1.ka-ro>
	<1292582116.2906.5.camel@edumazet-laptop>
	<19723.17775.241784.993744@ipc1.ka-ro>
	<1292585534.2906.12.camel@edumazet-laptop>
	<19723.19914.961119.861405@ipc1.ka-ro>
	<19723.20449.974043.309608@ipc1.ka-ro>
	<1292595727.2906.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([213.146.116.110]:40576 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754860Ab0LQO2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 09:28:19 -0500
In-Reply-To: <1292595727.2906.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Eric Dumazet writes:
> Le vendredi 17 d=E9cembre 2010 =E0 12:56 +0100, Lothar Wa=DFmann a =E9=
crit :
>=20
> > Forget about this. I was a little confused when reading the
> > alloc_large_system_hash() function. No I understand.
>=20
> Any idea why you got a small allocation ?
>=20
How much should I expect?

> How much LOWMEM do you have on your platform ?
>=20
It's a new platform with a Freescale i.MX28 SoC:

Linux version 2.6.37-rc5-karo+ (lothar@ipc1) (gcc version 4.4.1 (GCC) )=
 #43 PREEMPT Fri Dec 17 13:59:40 CET 2010
CPU: ARM926EJ-S [41069265] revision 5 (ARMv5TEJ), cr=3D00053177
CPU: VIVT data cache, VIVT instruction cache
Machine: Ka-Ro electronics TX28 module
Memory policy: ECC disabled, Data cache writeback
On node 0 totalpages: 32768
free_area_init_node: node 0, pgdat c0454c9c, node_mem_map c0994000
  Normal zone: 288 pages used for memmap
  Normal zone: 0 pages reserved
  Normal zone: 32480 pages, LIFO batch:7
pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
pcpu-alloc: [0] 0=20
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 32=
480
Kernel command line: init=3D/linuxrc tx28_baseboard=3Dstk5-v3 root=3D/d=
ev/nfs nfsroot=3D192.168.1.225:/tftpboot/KARO/imx28,nolock ip=3Dbootp d=
ebug panic=3D1 console=3DttyAM0,115200 ro
PID hash table entries: 512 (order: -1, 2048 bytes)
Dentry cache hash table entries: 16384 (order: 4, 65536 bytes)
Inode-cache hash table entries: 8192 (order: 3, 32768 bytes)
Memory: 128MB =3D 128MB total
Memory: 119968k/119968k available, 11104k reserved, 0K highmem


Lothar Wa=DFmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=DFe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=E4ftsf=FChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
