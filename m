From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Fri, 26 Jun 2009 12:26:30 +0200
Message-ID: <4A44A256.9080803@dti2.net>
References: <4A43E9F1.90209@cosmosbay.com> <20090626080302.GB5204@ff.dom.local> <19012.37515.146191.198843@robur.slu.se> <20090626093727.GA6832@ff.dom.local>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Robert Olsson <robert@robur.slu.se>,
	Eric Dumazet <dada1@cosmosbay.com>, pstaszewski@itcare.pl,
	Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:2383 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983AbZFZKcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 06:32:14 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v10.0.5)
	with ESMTP id md50004337705.msg
	for <netdev@vger.kernel.org>; Fri, 26 Jun 2009 12:26:35 +0200
In-Reply-To: <20090626093727.GA6832@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski escribi=F3:
> Pawel has reported these problems for a long time:
> http://bugzilla.kernel.org/show_bug.cgi?id=3D6648
>=20
> So, until it's fully investigated, it seems some 'fast' fix is needed
> here.

	I have never reported these problems but I am definitely seeing the sa=
me
message on kernel 2.6.29.5, usually, when one of my BGP peers goes down=
=2E So,
just a "me too".

	Regards,

		Jorge

-----------------
[ 1198.333854] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1198.437028] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1198.460848] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1199.240223] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1199.279723] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1199.383081] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1200.154893] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1200.191711] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1200.223242] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1200.270299] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1200.355795] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1206.239254] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1206.271995] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1206.349351] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1206.384676] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1206.428801] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1206.457315] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1206.485710] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1206.513691] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1209.039681] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1209.069224] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1209.108840] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1209.141450] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1209.172317] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1209.197824] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1209.224711] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1209.251566] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1209.289603] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1211.561178] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1211.598062] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1211.633238] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1211.684420] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
[ 1216.507853] Fix inflate_threshold_root. Now=3D15 size=3D11 bits
-----------------
cat /proc/meminfo
MemTotal:         515732 kB
MemFree:          139544 kB
Buffers:            4992 kB
Cached:             8488 kB
SwapCached:            0 kB
Active:           295904 kB
Inactive:           8132 kB
Active(anon):     291716 kB
Inactive(anon):        0 kB
Active(file):       4188 kB
Inactive(file):     8132 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:             0 kB
SwapFree:              0 kB
Dirty:                 0 kB
Writeback:             0 kB
AnonPages:        290556 kB
Mapped:             2320 kB
Slab:              42392 kB
SReclaimable:       1096 kB
SUnreclaim:        41296 kB
PageTables:          512 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:      257864 kB
Committed_AS:     294496 kB
VmallocTotal:     515448 kB
VmallocUsed:        3140 kB
VmallocChunk:     501096 kB
DirectMap4k:        8128 kB
DirectMap4M:      516096 kB
-----------------
cat /proc/vmallocinfo
0xe07f0000-0xe07f5000   20480 acpi_tb_verify_table+0x20/0x4a phys=3D1ff=
f0000 ioremap
0xe07f6000-0xe07f8000    8192 acpi_tb_verify_table+0x20/0x4a phys=3D1ff=
ff000 ioremap
0xe07fa000-0xe07fc000    8192 acpi_tb_verify_table+0x20/0x4a phys=3D1ff=
f0000 ioremap
0xe07fe000-0xe0800000    8192 acpi_tb_verify_table+0x20/0x4a phys=3D1ff=
f0000 ioremap
0xe0801000-0xe080d000   49152 cramfs_uncompress_init+0x18/0x57 pages=3D=
11 vmalloc
0xe080e000-0xe0810000    8192 e100_probe+0x1db/0x471 phys=3Dfdde0000 io=
remap
0xe0812000-0xe0814000    8192 e100_probe+0x1db/0x471 phys=3Dfdd80000 io=
remap
0xe0816000-0xe0818000    8192 e100_probe+0x1db/0x471 phys=3Dfbbf0000 io=
remap
0xe081a000-0xe081c000    8192 e100_probe+0x1db/0x471 phys=3Dfbbe0000 io=
remap
0xe081e000-0xe0820000    8192 ahc_linux_pci_reserve_mem_region+0x49/0x7=
2
[aic7xxx] phys=3Dfe9f0000 ioremap
0xe0820000-0xe0822000    8192 module_alloc_update_bounds+0x8/0x2c pages=
=3D1 vmalloc
0xe0822000-0xe0825000   12288 module_alloc_update_bounds+0x8/0x2c pages=
=3D2 vmalloc
0xe0826000-0xe0828000    8192 module_alloc_update_bounds+0x8/0x2c pages=
=3D1 vmalloc
0xe082d000-0xe0832000   20480 module_alloc_update_bounds+0x8/0x2c pages=
=3D4 vmalloc
0xe0833000-0xe0836000   12288 module_alloc_update_bounds+0x8/0x2c pages=
=3D2 vmalloc
0xe0838000-0xe083c000   16384 module_alloc_update_bounds+0x8/0x2c pages=
=3D3 vmalloc
0xe083c000-0xe0840000   16384 module_alloc_update_bounds+0x8/0x2c pages=
=3D3 vmalloc
0xe0840000-0xe0861000  135168 e1000_probe+0x18a/0x83b phys=3Dfebc0000 i=
oremap
0xe0862000-0xe0871000   61440 module_alloc_update_bounds+0x8/0x2c pages=
=3D14 vmalloc
0xe0875000-0xe087f000   40960 module_alloc_update_bounds+0x8/0x2c pages=
=3D9 vmalloc
0xe0880000-0xe0889000   36864 module_alloc_update_bounds+0x8/0x2c pages=
=3D8 vmalloc
0xe088d000-0xe0897000   40960 module_alloc_update_bounds+0x8/0x2c pages=
=3D9 vmalloc
0xe0897000-0xe08b5000  122880 module_alloc_update_bounds+0x8/0x2c pages=
=3D29 vmalloc
0xe08bd000-0xe08c1000   16384 module_alloc_update_bounds+0x8/0x2c pages=
=3D3 vmalloc
0xe08c7000-0xe08c9000    8192 module_alloc_update_bounds+0x8/0x2c pages=
=3D1 vmalloc
0xe08c9000-0xe08cc000   12288 module_alloc_update_bounds+0x8/0x2c pages=
=3D2 vmalloc
0xe08d3000-0xe08d7000   16384 module_alloc_update_bounds+0x8/0x2c pages=
=3D3 vmalloc
0xe08d8000-0xe08dd000   20480 module_alloc_update_bounds+0x8/0x2c pages=
=3D4 vmalloc
0xe08de000-0xe08e5000   28672 module_alloc_update_bounds+0x8/0x2c pages=
=3D6 vmalloc
0xe08e6000-0xe08e8000    8192 module_alloc_update_bounds+0x8/0x2c pages=
=3D1 vmalloc
0xe08e8000-0xe08ed000   20480 module_alloc_update_bounds+0x8/0x2c pages=
=3D4 vmalloc
0xe08f3000-0xe08f6000   12288 module_alloc_update_bounds+0x8/0x2c pages=
=3D2 vmalloc
0xe08ff000-0xe0902000   12288 module_alloc_update_bounds+0x8/0x2c pages=
=3D2 vmalloc
0xe090e000-0xe0914000   24576 module_alloc_update_bounds+0x8/0x2c pages=
=3D5 vmalloc
0xe091e000-0xe0922000   16384 module_alloc_update_bounds+0x8/0x2c pages=
=3D3 vmalloc
0xe092e000-0xe0934000   24576 module_alloc_update_bounds+0x8/0x2c pages=
=3D5 vmalloc
0xe0935000-0xe0942000   53248 module_alloc_update_bounds+0x8/0x2c pages=
=3D12 vmalloc
0xe095d000-0xe0979000  114688 module_alloc_update_bounds+0x8/0x2c pages=
=3D27 vmalloc
0xe097e000-0xe0980000    8192 ahc_linux_pci_reserve_mem_region+0x49/0x7=
2
[aic7xxx] phys=3Dfe9e0000 ioremap
0xe0990000-0xe0992000    8192 module_alloc_update_bounds+0x8/0x2c pages=
=3D1 vmalloc
0xe099a000-0xe099c000    8192 module_alloc_update_bounds+0x8/0x2c pages=
=3D1 vmalloc
0xe0a00000-0xe0b01000 1052672 he_start+0x204/0x1126 [he] phys=3Dfe80000=
0 ioremap
0xe14bf000-0xe15c1000 1056768 tnode_new+0x18/0x48 pages=3D257 vmalloc
0xe15ed000-0xe15f0000   12288 xt_alloc_table_info+0x68/0x97 [x_tables] =
pages=3D2
vmalloc
0xe15f1000-0xe15f4000   12288 xt_alloc_table_info+0x68/0x97 [x_tables] =
pages=3D2
vmalloc
-----------------


