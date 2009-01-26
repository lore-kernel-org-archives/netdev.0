From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: DCA/IOAT problem
Date: Mon, 26 Jan 2009 15:15:43 -0800
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A1C225006@orsmsx507.amr.corp.intel.com>
References: <497DF609.9000600@chelsio.com> <497E13B8.9040803@itcare.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/x-pkcs7-signature";
	micalg=SHA1; boundary="----=_NextPart_000_0031_01C97FC8.F4C90010"
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: =?utf-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	"Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:25787 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751656AbZAZXPq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2009 18:15:46 -0500
In-Reply-To: <497E13B8.9040803@itcare.pl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_NextPart_000_0031_01C97FC8.F4C90010
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 7bit

Forwarding entire message to include e1000-devel

Pawel Staszewski wrote:
> Hello
>
> Some lspci:
> lspci
> 00:00.0 Host bridge: Intel Corporation Memory Controller Hub (rev 90)
> 00:02.0 PCI bridge: Intel Corporation PCI Express x8 Port 2-3 (rev 90)
> 00:04.0 PCI bridge: Intel Corporation PCI Express x16 Port 4-7 (rev
> 90) 00:08.0 System peripheral: Intel Corporation DMA Engine (rev 90)
> 00:10.0 Host bridge: Intel Corporation FSB Registers (rev 90)
> 00:10.1 Host bridge: Intel Corporation FSB Registers (rev 90)
> 00:10.2 Host bridge: Intel Corporation FSB Registers (rev 90)
> 00:11.0 Host bridge: Intel Corporation Reserved Registers (rev 90)
> 00:13.0 Host bridge: Intel Corporation Reserved Registers (rev 90)
> 00:15.0 Host bridge: Intel Corporation DDR Channel 0 Registers (rev
> 90) 00:16.0 Host bridge: Intel Corporation DDR Channel 1 Registers
> (rev 90) 00:1a.0 USB Controller: Intel Corporation USB UHCI
> Controller #4 (rev 02) 00:1a.7 USB Controller: Intel Corporation USB2
> EHCI Controller #2 (rev 02) 00:1c.0 PCI bridge: Intel Corporation PCI
> Express Port 1 (rev 02) 00:1c.4 PCI bridge: Intel Corporation PCI
> Express Port 5 (rev 02) 00:1c.5 PCI bridge: Intel Corporation PCI
> Express Port 6 (rev 02) 00:1d.0 USB Controller: Intel Corporation USB
> UHCI Controller #1 (rev 02) 00:1d.1 USB Controller: Intel Corporation
> USB UHCI Controller #2 (rev 02) 00:1d.2 USB Controller: Intel
> Corporation USB UHCI Controller #3 (rev 02) 00:1d.7 USB Controller:
> Intel Corporation USB2 EHCI Controller #1 (rev 02) 00:1e.0 PCI
> bridge: Intel Corporation 82801 PCI Bridge (rev 92) 00:1f.0 ISA
> bridge: Intel Corporation LPC Interface Controller (rev 02) 00:1f.2
> IDE interface: Intel Corporation 4 port SATA IDE Controller (rev 02)
> 00:1f.3 SMBus: Intel Corporation SMBus Controller (rev 02) 00:1f.5
> IDE interface: Intel Corporation 2 port SATA IDE Controller (rev 02)
> 01:00.0 Ethernet controller: Intel Corporation Device 10dd (rev 01)
> 04:00.0 Ethernet controller: Intel Corporation 82573E Gigabit
> Ethernet Controller (Copper) (rev 03) 05:00.0 Ethernet controller:
> Intel Corporation 82573L Gigabit Ethernet Controller
> 06:01.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev
> 02)
> and then:
> modprobe ioatdma
>
> dmesg:
> ...
> ...
> IPv4 FIB: Using LC-trie version 0.408
> e1000e 0000:04:00.0: irq 1274 for MSI/MSI-X
> e1000e 0000:04:00.0: irq 1274 for MSI/MSI-X
> e1000e 0000:05:00.0: irq 1273 for MSI/MSI-X
> e1000e 0000:05:00.0: irq 1273 for MSI/MSI-X
> 0000:05:00.0: eth1: Link is Up 1000 Mbps Full Duplex, Flow Control:
> RX/TX dca service started, version 1.4
> ioatdma 0000:00:08.0: can't find IRQ for PCI INT A; probably buggy MP
> table ioatdma 0000:00:08.0: setting latency timer to 64
> ioatdma 0000:00:08.0: Intel(R) I/OAT DMA Engine found, 4 channels,
> device version 0x12, driver version 3.30
> ioatdma 0000:00:08.0: irq 1255 for MSI/MSI-X
> ioatdma 0000:00:08.0: DCA is disabled in BIOS
> ixgbe: eth2: ixgbe_watchdog_task: NIC Link is Up 10 Gbps, Flow
> Control: None e1000e 0000:04:00.0: irq 1274 for MSI/MSI-X
> e1000e 0000:04:00.0: irq 1274 for MSI/MSI-X
>
> ...
> ...
>
>
> lspvi -vvv (for dma engine)
> 00:08.0 System peripheral: Intel Corporation DMA Engine (rev 90)
>         Subsystem: Super Micro Computer Inc Device de80
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx+
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 1255
>         Region 0: Memory at fe700000 (64-bit, non-prefetchable)
>         [size=1K] Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [58] Message Signalled Interrupts: Mask- 64bit-
> Queue=0/0 Enable+
>                 Address: feeff00c  Data: 41b2
>         Capabilities: [6c] Express (v1) Root Complex Integrated
> Endpoint, MSI 00
>                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s
> <64ns, L1 <1us
>                         ExtTag- RBE- FLReset-
>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal+
> Unsupported-
>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
>                         MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq-
> AuxPwr- TransPend-
>                 LnkCap: Port #0, Speed unknown, Width x0, ASPM
> unknown, Latency L0 <64ns, L1 <1us
>                         ClockPM- Suprise- LLActRep- BwNot-
>                 LnkCtl: ASPM Disabled; Disabled- Retrain- CommClk-
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed unknown, Width x0, TrErr- Train-
> SlotClk- DLActive- BWMgmt- ABWMgmt-
>         Kernel driver in use: ioatdma
>
>
> cat /proc/interrupts
>            CPU0       CPU1       CPU2       CPU3       CPU4
> CPU5       CPU6       CPU7
>   0:         81          6          9          7          5
> 3          9          5   IO-APIC-edge      timer
>   1:          1          0          0          0          1
> 0          0          0   IO-APIC-edge      i8042
>   2:          0          0          0          0          0
> 0          0          0    XT-PIC-XT        cascade
>  14:        901        857        867        864        708
> 674        693        692   IO-APIC-edge      ata_piix
>  15:        686        728        691        703        826
> 897        876        872   IO-APIC-edge      ata_piix
>  18:          0          0          0          0          0
> 0          0          0   IO-APIC-fasteoi   ata_piix
> 1255:          1          0          1          0          1
> 0          1          1   PCI-MSI-edge      ioat-msi
> 1256:          0          0          0          0          0
> 0          0          0   PCI-MSI-edge      eth2:lsc
> 1257:        857        720       1176        802        960
> 751        706        841   PCI-MSI-edge      eth2:v15-Tx
> 1258:        958        751        706        841       1176
> 802        720        859   PCI-MSI-edge      eth2:v14-Tx
> 1259:       1176        802        720        859        706
> 841        751        958   PCI-MSI-edge      eth2:v13-Tx
> 1260:        706        842        751        959        720
> 858        802       1175   PCI-MSI-edge      eth2:v12-Tx
> 1261:        720        858        802       1174        751
> 960        842        706   PCI-MSI-edge      eth2:v11-Tx
> 1262:        751        960        842        706        802
> 1174        858        720   PCI-MSI-edge      eth2:v10-Tx
> 1263:        802       1174        858        720        842
> 706        960        751   PCI-MSI-edge      eth2:v9-Tx
> 1264:        842        707        960        751        859
> 719       1173        802   PCI-MSI-edge      eth2:v8-Tx
> 1265:     814186     813591     813713     814872     814537
> 816002     812892     814292   PCI-MSI-edge      eth2:v7-Rx
> 1266:     626856     626688     627886     627507     628067
> 625730     626561     626521   PCI-MSI-edge      eth2:v6-Rx
> 1267:     592474     591312     591741     592107     592214
> 593218     591271     591386   PCI-MSI-edge      eth2:v5-Rx
> 1268:     558076     559008     557856     558677     557894
> 556703     557997     558879   PCI-MSI-edge      eth2:v4-Rx
> 1269:     723457     725019     723746     724688     723165
> 724716     724037     725136   PCI-MSI-edge      eth2:v3-Rx
> 1270:     553387     554096     553204     552603     553078
> 553587     553838     553769   PCI-MSI-edge      eth2:v2-Rx
> 1271:     603820     605323     605368     602989     604948
> 604887     606911     604745   PCI-MSI-edge      eth2:v1-Rx
> 1272:     800828     798049     799471     799703     799183
> 798322     799220     798254   PCI-MSI-edge      eth2:v0-Rx
> 1273:       2868       2894       2970       2808       2863
> 2803       3167       2860   PCI-MSI-edge      eth1
> 1274:        873        856        882        924        933
> 904        864        943   PCI-MSI-edge      eth0
> NMI:          0          0          0          0          0
> 0          0          0   Non-maskable interrupts
> LOC:      40527      41783      40049      40903      42180
> 39477      49021      47628   Local timer interrupts
> RES:        858         58        232        283         89
> 97        284        435   Rescheduling interrupts
> CAL:         52        101         99         88         96
> 93         92         58   Function call interrupts
> TLB:        143        133        486        452        141
> 159        396        429   TLB shootdowns
> SPU:          0          0          0          0          0
> 0          0          0   Spurious interrupts
> ERR:          0
> MIS:          0
>
>
> cat /proc/cpuinfo
>  cat /proc/cpuinfo
> processor       : 0
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 23
> model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
> stepping        : 6
> cpu MHz         : 2999.898
> cache size      : 6144 KB
> physical id     : 0
> siblings        : 4
> core id         : 0
> cpu cores       : 4
> apicid          : 0
> initial apicid  : 0
> fdiv_bug        : no
> hlt_bug         : no
> f00f_bug        : no
> coma_bug        : no
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 10
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
> mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx
> lm constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx
> est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi
> flexpriority bogomips        : 5999.79
> clflush size    : 64
> power management:
>
> processor       : 1
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 23
> model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
> stepping        : 6
> cpu MHz         : 2999.898
> cache size      : 6144 KB
> physical id     : 1
> siblings        : 4
> core id         : 0
> cpu cores       : 4
> apicid          : 4
> initial apicid  : 4
> fdiv_bug        : no
> hlt_bug         : no
> f00f_bug        : no
> coma_bug        : no
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 10
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
> mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx
> lm constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx
> est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi
> flexpriority bogomips        : 6065.40
> clflush size    : 64
> power management:
>
> processor       : 2
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 23
> model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
> stepping        : 6
> cpu MHz         : 2999.898
> cache size      : 6144 KB
> physical id     : 0
> siblings        : 4
> core id         : 1
> cpu cores       : 4
> apicid          : 1
> initial apicid  : 1
> fdiv_bug        : no
> hlt_bug         : no
> f00f_bug        : no
> coma_bug        : no
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 10
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
> mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx
> lm constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx
> est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi
> flexpriority bogomips        : 6000.46
> clflush size    : 64
> power management:
>
> processor       : 3
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 23
> model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
> stepping        : 6
> cpu MHz         : 2999.898
> cache size      : 6144 KB
> physical id     : 1
> siblings        : 4
> core id         : 1
> cpu cores       : 4
> apicid          : 5
> initial apicid  : 5
> fdiv_bug        : no
> hlt_bug         : no
> f00f_bug        : no
> coma_bug        : no
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 10
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
> mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx
> lm constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx
> est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi
> flexpriority bogomips        : 6000.47
> clflush size    : 64
> power management:
>
> processor       : 4
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 23
> model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
> stepping        : 6
> cpu MHz         : 2999.898
> cache size      : 6144 KB
> physical id     : 0
> siblings        : 4
> core id         : 2
> cpu cores       : 4
> apicid          : 2
> initial apicid  : 2
> fdiv_bug        : no
> hlt_bug         : no
> f00f_bug        : no
> coma_bug        : no
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 10
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
> mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx
> lm constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx
> est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi
> flexpriority bogomips        : 6000.43
> clflush size    : 64
> power management:
>
> processor       : 5
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 23
> model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
> stepping        : 6
> cpu MHz         : 2999.898
> cache size      : 6144 KB
> physical id     : 1
> siblings        : 4
> core id         : 2
> cpu cores       : 4
> apicid          : 6
> initial apicid  : 6
> fdiv_bug        : no
> hlt_bug         : no
> f00f_bug        : no
> coma_bug        : no
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 10
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
> mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx
> lm constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx
> est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi
> flexpriority bogomips        : 6000.50
> clflush size    : 64
> power management:
>
> processor       : 6
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 23
> model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
> stepping        : 6
> cpu MHz         : 2999.898
> cache size      : 6144 KB
> physical id     : 0
> siblings        : 4
> core id         : 3
> cpu cores       : 4
> apicid          : 3
> initial apicid  : 3
> fdiv_bug        : no
> hlt_bug         : no
> f00f_bug        : no
> coma_bug        : no
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 10
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
> mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx
> lm constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx
> est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi
> flexpriority bogomips        : 6000.43
> clflush size    : 64
> power management:
>
> processor       : 7
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 23
> model name      : Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
> stepping        : 6
> cpu MHz         : 2999.898
> cache size      : 6144 KB
> physical id     : 1
> siblings        : 4
> core id         : 3
> cpu cores       : 4
> apicid          : 7
> initial apicid  : 7
> fdiv_bug        : no
> hlt_bug         : no
> f00f_bug        : no
> coma_bug        : no
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 10
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
> mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx
> lm constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx
> est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi
> flexpriority bogomips        : 6000.47
> clflush size    : 64
> power management:
>
>
>
>
> I have enabled DCA in my Bios.
> So why i have info:
> ioatdma 0000:00:08.0: DCA is disabled in BIOS

Probably because the BIOS is not working correctly or there is a bug in 
dca. Is that a supermicro machine?  Can you include the output of 
dmidecode?  Are you running the latest BIOS?  What are you trying to 
achieve?  DCA or IOAT DMA copy offload (two separate features)

>
> and:
> ls -la /sys/class/dca/
> total 0
> drwxr-xr-x  2 root root 0 Jan 26 16:21 .
> drwxr-xr-x 33 root root 0 Jan 26 16:14 ..
>
> cat /sys/class/dma/dma0chan0/in_use
> 0
> cat /sys/class/dma/dma0chan1/in_use
> 1
> cat /sys/class/dma/dma0chan2/in_use
> 0
> cat /sys/class/dma/dma0chan3/in_use
> 0
>
>
> Why DCA is not working (or working but no info about in ioat)

The DMA channels (copy offload) are different than the DCA feature.  DCA 
involves front side bus hints sent from the adapter to the CPU handling 
the interrupt, where DMA channels are for copy offload from the processor 
to the independent data movers (DMA channels)


------=_NextPart_000_0031_01C97FC8.F4C90010
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIXMTCCAyAw
ggKJoAMCAQICBDXe9M8wDQYJKoZIhvcNAQEFBQAwTjELMAkGA1UEBhMCVVMxEDAOBgNVBAoTB0Vx
dWlmYXgxLTArBgNVBAsTJEVxdWlmYXggU2VjdXJlIENlcnRpZmljYXRlIEF1dGhvcml0eTAeFw05
ODA4MjIxNjQxNTFaFw0xODA4MjIxNjQxNTFaME4xCzAJBgNVBAYTAlVTMRAwDgYDVQQKEwdFcXVp
ZmF4MS0wKwYDVQQLEyRFcXVpZmF4IFNlY3VyZSBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwgZ8wDQYJ
KoZIhvcNAQEBBQADgY0AMIGJAoGBAMFdsVhnCGLuoJotHwhtkRRomAoe/toEbxOEYiHD0XzOnwXg
uAHwTjTs4oqVBGSs8WtTXwWzy2eAv0ICjv7dAQns4QAUT/z78AzdQ7pbK+EfgHCZFVeTFvEPl2q3
wmgjHMxNWTCsUR47ryvW7mNFe8XZX1DS41APOojnvxT94Me5AgMBAAGjggEJMIIBBTBwBgNVHR8E
aTBnMGWgY6BhpF8wXTELMAkGA1UEBhMCVVMxEDAOBgNVBAoTB0VxdWlmYXgxLTArBgNVBAsTJEVx
dWlmYXggU2VjdXJlIENlcnRpZmljYXRlIEF1dGhvcml0eTENMAsGA1UEAxMEQ1JMMTAaBgNVHRAE
EzARgQ8yMDE4MDgyMjE2NDE1MVowCwYDVR0PBAQDAgEGMB8GA1UdIwQYMBaAFEjmaPkr0rKV10fY
IyAQTzOYkJ/UMB0GA1UdDgQWBBRI5mj5K9KylddH2CMgEE8zmJCf1DAMBgNVHRMEBTADAQH/MBoG
CSqGSIb2fQdBAAQNMAsbBVYzLjBjAwIGwDANBgkqhkiG9w0BAQUFAAOBgQBYzinq/Pfetc4CuRe1
hdG54+CVzCUxDQCmkm5/tpJjnlCV0Zpv5BHeY4VumO6o/1rI01WyZnFX3sAh6z0qpyNJAQSGQnv8
7n+iFlK1Z2fTQNs7JliyKHc9rhR3Ydb6KmYnoA36p3Nc6nDxlCFlRF/6/O8paKmih3nvee9PrAd3
ODCCAz0wggKmoAMCAQICAwWw/zANBgkqhkiG9w0BAQUFADBOMQswCQYDVQQGEwJVUzEQMA4GA1UE
ChMHRXF1aWZheDEtMCsGA1UECxMkRXF1aWZheCBTZWN1cmUgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
MB4XDTA2MDIxNjE4MDEzMFoXDTE2MDIxOTE4MDEzMFowUjELMAkGA1UEBhMCVVMxGjAYBgNVBAoT
EUludGVsIENvcnBvcmF0aW9uMScwJQYDVQQDEx5JbnRlbCBFeHRlcm5hbCBCYXNpYyBQb2xpY3kg
Q0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDBpd/XOb9QVqEZ8mQ1042TdOIq3ATD
IsV2xDyt30yLyMR5Wjtus0bn3B+he89BiNO/LP6+rFzEwlD55PlX+HLGIKeNNG97dqyc30FElEUj
ZzTZFq2N4e3kVJ/XAEEgANzV8v9qp7qWwxugPgfc3z9BkYot+CifozexHLb/hEZj+yISCU61kRZv
uSQ0E11yYL4dRgcglJeaHo3oX57rvIckaLsYV5/1Aj+R8DM1Ppk965XQAKsHfnyT7C4S50T4lVn4
lz36wOdNZn/zegG1zp41lnoTFfT4KuKVJH5x7YD1p6KbgJCKLovnujGuohquBNfdXKpZkvz6pGv+
iC1HawJdAgMBAAGjgaAwgZ0wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBQaxgxKxEdvqNutK/D0
Vgaj7TdUDDA6BgNVHR8EMzAxMC+gLaArhilodHRwOi8vY3JsLmdlb3RydXN0LmNvbS9jcmxzL3Nl
Y3VyZWNhLmNybDAfBgNVHSMEGDAWgBRI5mj5K9KylddH2CMgEE8zmJCf1DAPBgNVHRMBAf8EBTAD
AQH/MA0GCSqGSIb3DQEBBQUAA4GBABMQOK2kVKVIlUWwLTdywJ+e2O+PC/uQltK2F3lRyrPfBn69
tOkIP4SgDJOfsxyobIrPLe75kBLw+Dom13OBDp/EMZJZ1CglQfVV8co9mT3aZMjSGGQiMgkJLR3j
Mfr900fXZKj5XeqCJ+JP0mEhJGEdVCY+FFlksJjV86fDrq1QMIIFYzCCBEugAwIBAgIKYSyUiQAA
AAAABTANBgkqhkiG9w0BAQUFADBSMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9y
YXRpb24xJzAlBgNVBAMTHkludGVsIEV4dGVybmFsIEJhc2ljIFBvbGljeSBDQTAeFw0wNjAzMjIy
MjIyNDJaFw0xMjAzMjIyMjMyNDJaMFYxCzAJBgNVBAYTAlVTMRowGAYDVQQKExFJbnRlbCBDb3Jw
b3JhdGlvbjErMCkGA1UEAxMiSW50ZWwgRXh0ZXJuYWwgQmFzaWMgSXNzdWluZyBDQSAzQTCCASIw
DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKvXqH/ah10uJc7YzQUh+XEDNqS6IsXOyqCtizr9
x6F+v6iRAbvddRRJRWixfV78qarSN9WMymJ90M8c9/Dfr1yzFuq95RgCAF3vdve3wKi7kJv6lkMJ
wyyB+uIYcWtljYx2LDqbb9S6Z6He3q8W/aGKvu23I9ksNx+cmZcDNZwGdXVIEHpEMyA4bp0RvYtf
p8BsGAyn6YuK63HugeyYdeFL+4+Wz2tGUqw9OWhob6oV1oDH3zboLhHJiQ2oIj3jAJ3/LrIkzcWP
2R20UIliDAPAAl6MNWJPdsNK5EEeuxEuUSpdFsMj5rBmPHH4U8i8rUmi6GEOcX5rwAw64AzS3gEC
AwEAAaOCAjUwggIxMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFAlpgTN7BnOPI0wKA9/3FoER
ghMFMAsGA1UdDwQEAwIBhjAQBgkrBgEEAYI3FQEEAwIBADAZBgkrBgEEAYI3FAIEDB4KAFMAdQBi
AEMAQTAfBgNVHSMEGDAWgBQaxgxKxEdvqNutK/D0Vgaj7TdUDDCBvQYDVR0fBIG1MIGyMIGvoIGs
oIGphk5odHRwOi8vd3d3LmludGVsLmNvbS9yZXBvc2l0b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFs
JTIwQmFzaWMlMjBQb2xpY3klMjBDQS5jcmyGV2h0dHA6Ly9jZXJ0aWZpY2F0ZXMuaW50ZWwuY29t
L3JlcG9zaXRvcnkvQ1JML0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUyMENBLmNy
bDCB4wYIKwYBBQUHAQEEgdYwgdMwYwYIKwYBBQUHMAKGV2h0dHA6Ly93d3cuaW50ZWwuY29tL3Jl
cG9zaXRvcnkvY2VydGlmaWNhdGVzL0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUy
MENBLmNydDBsBggrBgEFBQcwAoZgaHR0cDovL2NlcnRpZmljYXRlcy5pbnRlbC5jb20vcmVwb3Np
dG9yeS9jZXJ0aWZpY2F0ZXMvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwUG9saWN5JTIwQ0Eu
Y3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCuNCnecJ+vDpXzsHOzMEyz4KgTNDbJROHag8H/ZVga7soc
oJyC+HKqDfQgxifVorbTbSajCBEAxqg6bbNWBJ6qKOFHneBrXkENf5WdD50eCTCFWRV3EIsHEOQ1
kP0eNYV5Ed4hp9y6wASV6z2z86O4+qouLJiow4AIhoCKD8rEyD7ODgTvjvLCKpsVyPlG1jOVSsOS
IF2VUmueAmK3RFU4np83zerK/j0G37owhniEDT6ZhwkUd0XL45nt1m7yApMEbnXUTHNaXnE+P98k
k3nDXdW25sB+5xWcYR3GpgMdQiZgP/f0KZ+yZKNE7gcp3I/O4pXqUNWIsLSYTi3soAR2MIIFizCC
BHOgAwIBAgIKTys7CwAAAAAWqTANBgkqhkiG9w0BAQUFADBWMQswCQYDVQQGEwJVUzEaMBgGA1UE
ChMRSW50ZWwgQ29ycG9yYXRpb24xKzApBgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3Vp
bmcgQ0EgM0EwHhcNMDcwODA3MDAyMzE2WhcNMTAwODA2MDAyMzE2WjBHMRowGAYDVQQDExFCcmFu
ZGVidXJnLCBKZXNzZTEpMCcGCSqGSIb3DQEJARYaamVzc2UuYnJhbmRlYnVyZ0BpbnRlbC5jb20w
gZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBALVYgP1o+Y7nwm5Lr6GerkzP9QweQWF7Ban1beaZ
Etba5ALpVHObkA/1pXF8sE/iJnu4CxUAxAmVArSVNHWFJDdS/rR43JOvekwVIKEo4a9JABCXF+rt
K/1ImEN+RDLfl/0Wd73CRfOvRtTSlg+pUqVyCtL9B3X1bzY+OPxicYahAgMBAAGjggLsMIIC6DAL
BgNVHQ8EBAMCB4AwHQYDVR0OBBYEFKqZruraVjeOWvjg3XEwVS5Kkvn0MDwGCSsGAQQBgjcVBwQv
MC0GJSsGAQQBgjcVCIbDjHWEmeVRg/2BKIWOn1OCkcAJZ4HevTmV8EMCAWQCAQMwHwYDVR0jBBgw
FoAUCWmBM3sGc48jTAoD3/cWgRGCEwUwgckGA1UdHwSBwTCBvjCBu6CBuKCBtYZUaHR0cDovL3d3
dy5pbnRlbC5jb20vcmVwb3NpdG9yeS9DUkwvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwSXNz
dWluZyUyMENBJTIwM0EuY3Jshl1odHRwOi8vY2VydGlmaWNhdGVzLmludGVsLmNvbS9yZXBvc2l0
b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBJc3N1aW5nJTIwQ0ElMjAzQS5jcmww
ge8GCCsGAQUFBwEBBIHiMIHfMGkGCCsGAQUFBzAChl1odHRwOi8vd3d3LmludGVsLmNvbS9yZXBv
c2l0b3J5L2NlcnRpZmljYXRlcy9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBJc3N1aW5nJTIw
Q0ElMjAzQS5jcnQwcgYIKwYBBQUHMAKGZmh0dHA6Ly9jZXJ0aWZpY2F0ZXMuaW50ZWwuY29tL3Jl
cG9zaXRvcnkvY2VydGlmaWNhdGVzL0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMElzc3Vpbmcl
MjBDQSUyMDNBLmNydDAfBgNVHSUEGDAWBggrBgEFBQcDBAYKKwYBBAGCNwoDDDApBgkrBgEEAYI3
FQoEHDAaMAoGCCsGAQUFBwMEMAwGCisGAQQBgjcKAwwwUQYDVR0RBEowSKAqBgorBgEEAYI3FAID
oBwMGmplc3NlLmJyYW5kZWJ1cmdAaW50ZWwuY29tgRpqZXNzZS5icmFuZGVidXJnQGludGVsLmNv
bTANBgkqhkiG9w0BAQUFAAOCAQEAJL8raLZYyz2imhvIrmSaQNhCOEzTwIXqxhlMbnPpeZUKlUym
6Tg7VaGXsqSyNQRe2eOK3gv2Et1O1ZsJwRGLC9mzKug8xeE5doO7HbbO04C8bR4B7jID2xByDJsT
f99mrprSwng4brFaW9JiSbCQyxmmApPoVXEff3lUqphiotdebDeV8y8a+s/yJCviLUinLbs4Uowf
/SXu6k+b27ue/I/QmWq01CF9wT/QMPyyAkIR+62XCGjGAZJIfsoZzCtab9/ujU7B0d7wV1Tq/koX
L21E3rOyAZ6I+7jpV0HDqY9KjPdLQu2tQ7I1u6iPORDH29STos5g/xv48jMK+RemBTCCBdIwggS6
oAMCAQICCk82OTAAAAAAFqowDQYJKoZIhvcNAQEFBQAwVjELMAkGA1UEBhMCVVMxGjAYBgNVBAoT
EUludGVsIENvcnBvcmF0aW9uMSswKQYDVQQDEyJJbnRlbCBFeHRlcm5hbCBCYXNpYyBJc3N1aW5n
IENBIDNBMB4XDTA3MDgwNzAwMzUxM1oXDTEwMDgwNjAwMzUxM1owRzEaMBgGA1UEAxMRQnJhbmRl
YnVyZywgSmVzc2UxKTAnBgkqhkiG9w0BCQEWGmplc3NlLmJyYW5kZWJ1cmdAaW50ZWwuY29tMIGf
MA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDi2zY1Qs4T/t3n7P8HqwPt42qNN+oSkatx6IEcMpQ3
F0gPolrDmw2NqF4cC77He10MCA5vCd4dyL0wPDKguH0wcntGCaYVf4EitdnTl+TGPkuAoRaUZAhc
NjmPrL2pH8HtJf/ANHQPtVuCUnPbUl12c9HPOqvVWSdXniNBUVCM9QIDAQABo4IDMzCCAy8wCwYD
VR0PBAQDAgQwMEQGCSqGSIb3DQEJDwQ3MDUwDgYIKoZIhvcNAwICAgCAMA4GCCqGSIb3DQMEAgIA
gDAHBgUrDgMCBzAKBggqhkiG9w0DBzAdBgNVHQ4EFgQUvdfuEHaw1+wbTNraFaClPaDVErUwPQYJ
KwYBBAGCNxUHBDAwLgYmKwYBBAGCNxUIhsOMdYSZ5VGD/YEohY6fU4KRwAlnhLnZQYeE/04CAWQC
AQcwHwYDVR0jBBgwFoAUCWmBM3sGc48jTAoD3/cWgRGCEwUwgckGA1UdHwSBwTCBvjCBu6CBuKCB
tYZUaHR0cDovL3d3dy5pbnRlbC5jb20vcmVwb3NpdG9yeS9DUkwvSW50ZWwlMjBFeHRlcm5hbCUy
MEJhc2ljJTIwSXNzdWluZyUyMENBJTIwM0EuY3Jshl1odHRwOi8vY2VydGlmaWNhdGVzLmludGVs
LmNvbS9yZXBvc2l0b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBJc3N1aW5nJTIw
Q0ElMjAzQS5jcmwwge8GCCsGAQUFBwEBBIHiMIHfMGkGCCsGAQUFBzAChl1odHRwOi8vd3d3Lmlu
dGVsLmNvbS9yZXBvc2l0b3J5L2NlcnRpZmljYXRlcy9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMl
MjBJc3N1aW5nJTIwQ0ElMjAzQS5jcnQwcgYIKwYBBQUHMAKGZmh0dHA6Ly9jZXJ0aWZpY2F0ZXMu
aW50ZWwuY29tL3JlcG9zaXRvcnkvY2VydGlmaWNhdGVzL0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNp
YyUyMElzc3VpbmclMjBDQSUyMDNBLmNydDAfBgNVHSUEGDAWBggrBgEFBQcDBAYKKwYBBAGCNwoD
BDApBgkrBgEEAYI3FQoEHDAaMAoGCCsGAQUFBwMEMAwGCisGAQQBgjcKAwQwUQYDVR0RBEowSKAq
BgorBgEEAYI3FAIDoBwMGmplc3NlLmJyYW5kZWJ1cmdAaW50ZWwuY29tgRpqZXNzZS5icmFuZGVi
dXJnQGludGVsLmNvbTANBgkqhkiG9w0BAQUFAAOCAQEAWZ7lU8JqwDbBes8ezVkGWmY91zVg87Bi
0Qxh0u9J5fIF+8KZ6tt7GX3Q8GRj0bZnX4hzFk6+wxT+25hXUb7c0ZmEIMbr8LYvOWXHghvjQja1
mkIC2eArcr42E8Bwy3BcwF+0K38UsqAkmlBzDOEf/lleIjgEamarv94UvjwFNsK6/sRCVSgOIU1T
8QeeCx0Y7Roaqjwt+66CwpIT6upnfJdSfplPXeYqatHfvAb+6evOB2EG37ejQmWEN5co8dfXD+1L
kkqlNn2YZfj4SGJeYHq0s/EmDPHzyrZohSoPgZJape03LRR7JUUtesB9nNtBuCnzMfWQw/tfL3of
ae/0MDGCAsAwggK8AgEBMGQwVjELMAkGA1UEBhMCVVMxGjAYBgNVBAoTEUludGVsIENvcnBvcmF0
aW9uMSswKQYDVQQDEyJJbnRlbCBFeHRlcm5hbCBCYXNpYyBJc3N1aW5nIENBIDNBAgpPKzsLAAAA
ABapMAkGBSsOAwIaBQCgggGyMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkF
MQ8XDTA5MDEyNjIzMTU0M1owIwYJKoZIhvcNAQkEMRYEFEQEcWd5KngYrV3Ssz8GjpRgEmubMGcG
CSqGSIb3DQEJDzFaMFgwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFA
MAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMAcGBSsOAwIaMAoGCCqGSIb3DQIFMHMGCSsGAQQBgjcQ
BDFmMGQwVjELMAkGA1UEBhMCVVMxGjAYBgNVBAoTEUludGVsIENvcnBvcmF0aW9uMSswKQYDVQQD
EyJJbnRlbCBFeHRlcm5hbCBCYXNpYyBJc3N1aW5nIENBIDNBAgpPNjkwAAAAABaqMHUGCyqGSIb3
DQEJEAILMWagZDBWMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24xKzAp
BgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3VpbmcgQ0EgM0ECCk82OTAAAAAAFqowDQYJ
KoZIhvcNAQEBBQAEgYCAGAg+1jsl32VGEc21MtMB+y0FkuVVy1Qs7oRx3l6xeGh5SaL1POaV0hdY
/RqLMkQfskJKqz4aGwrl1kq4eGD+R9Kia61z2x6R69OeAoMuW3aXbAM4ofp46jmuU3wckECfHpoi
FdIB9inBcAzm3JC0iPnK+OW3iYUH5OYgQ4feLQAAAAAAAA==

------=_NextPart_000_0031_01C97FC8.F4C90010--
