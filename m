From: Joao Correia <joaomiguelcorreia@gmail.com>
Subject: Re: some tc commands fail on 2.6.29-rc6-git5, works on 2.6.28.7
Date: Tue, 3 Mar 2009 23:10:36 +0000
Message-ID: <a5d9929e0903031510r7f173f5cib7bd1a2426e92473@mail.gmail.com>
References: <a5d9929e0903011636w6bff1032y28ab58c0ff8c8052@mail.gmail.com>
	 <20090301165729.8e08e1d7.akpm@linux-foundation.org>
	 <49AC28FF.1040102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f178.google.com ([209.85.218.178]:45430 "EHLO
	mail-bw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753429AbZCCXKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 18:10:40 -0500
In-Reply-To: <49AC28FF.1040102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello again

Sorry for taking so long, been busy with some unexpected work.

I have checked the .config and can not (to the extent of my not-guru
knowledge) find anything out of place. Excuse me if its obvious and it
didnt strike me yet.

The commands asked plus some others i remembered give the output at the bottom.
Where can i send the gzipped .config? Not the list, I imagine?

I have confirmed again that the exact same commands (as on the
original message), work flawlessly on 2.6.28.7 without a hitch, and,
AFAIK, work as intended. I have also tried the latest 2.6.29-rc6-git7
and it still fails like on git6.

It happens even with other NIC's (both a D-Link gigabit and an onboard
Atheros A1L gigabit (output of lspci -vv at the end of this message).

Thank you very much for your time,
Joao Correia


Output of the commands:
(big wall of text coming your way, beware)

[root@duron ~]# lsmod
Module                  Size  Used by
act_police              5028  0
sch_ingress             2236  2
cls_fw                  4636  1
cls_u32                 7196  6
sch_sfq                 5884  3
sch_cbq                16764  1
xt_ipp2p                8220  1
xt_MARK                 2012  1
xt_CONNMARK             2780  2
xt_dscp                 2268  3
xt_CLASSIFY             1468  7
ipt_MASQUERADE          2652  1
xt_connlimit            3876  6
xt_mac                  1500  18
xt_mark                 1628  18
xt_comment              1436  40
xt_time                 2652  42
xt_DELUDE               2524  1
xt_TARPIT               2876  2
xt_CHAOS                3412  1
compat_xtables          3196  3 xt_DELUDE,xt_TARPIT,xt_CHAOS
xt_limit                2016  5
iptable_raw             1980  0
iptable_mangle          2556  1
iptable_nat             4988  1
nf_nat                 16400  2 ipt_MASQUERADE,iptable_nat
ipt_ULOG                6948  3
autofs4                24448  2
it87                   20012  0
hwmon_vid               2940  1 it87
ipv6                  269168  48
nf_conntrack_ipv4       7812  36 iptable_nat,nf_nat
nf_defrag_ipv4          1724  1 nf_conntrack_ipv4
xt_state                1948  25
nf_conntrack           56292  7
xt_CONNMARK,ipt_MASQUERADE,xt_connlimit,iptable_nat,nf_nat,nf_conntrack_ipv4,xt_state
xt_tcpudp               2812  69
ipt_REJECT              2940  2
iptable_filter          2524  1
ip_tables              10828  4
iptable_raw,iptable_mangle,iptable_nat,iptable_filter
x_tables               12992  20
xt_ipp2p,xt_MARK,xt_CONNMARK,xt_dscp,xt_CLASSIFY,ipt_MASQUERADE,xt_connlimit,xt_mac,xt_mark,xt_comment,xt_time,xt_CHAOS,compat_xtables,xt_limit,iptable_nat,ipt_ULOG,xt_state,xt_tcpudp,ipt_REJECT,ip_tables
cpufreq_ondemand        6888  1
powernow_k8            17408  1
ext4                  229560  2
jbd2                   63328  1 ext4
crc16                   1724  1 ext4
dm_multipath           15720  0
scsi_dh                 6112  1 dm_multipath
dm_mod                 53096  1 dm_multipath
raid0                   7676  2
tda1004x               15712  1
saa7134_dvb            20680  0
videobuf_dvb            6304  1 saa7134_dvb
dvb_core               82944  1 videobuf_dvb
snd_hda_codec_atihdmi     3356  1
snd_hda_codec_realtek   202528  1
snd_hda_intel          26248  0
snd_seq_dummy           2656  0
snd_hda_codec          58492  3
snd_hda_codec_atihdmi,snd_hda_codec_realtek,snd_hda_intel
snd_hwdep               7328  1 snd_hda_codec
snd_seq_oss            31424  0
snd_seq_midi_event      6140  1 snd_seq_oss
snd_seq                51920  5 snd_seq_dummy,snd_seq_oss,snd_seq_midi_event
tda827x                 9408  2
snd_seq_device          6568  3 snd_seq_dummy,snd_seq_oss,snd_seq
snd_pcm_oss            45024  0
tda8290                12612  1
snd_mixer_oss          15004  1 snd_pcm_oss
tuner                  27748  0
snd_pcm                73632  3 snd_hda_intel,snd_hda_codec,snd_pcm_oss
snd_timer              20708  2 snd_seq,snd_pcm
saa7134               142320  1 saa7134_dvb
ir_common              39904  1 saa7134
v4l2_common            14396  2 tuner,saa7134
videodev               38784  3 tuner,saa7134,v4l2_common
v4l1_compat            13472  1 videodev
snd                    56004  12
snd_hda_codec_realtek,snd_hda_intel,snd_seq_dummy,snd_hda_codec,snd_hwdep,snd_seq_oss,snd_seq,snd_seq_device,snd_pcm_oss,snd_mixer_oss,snd_pcm,snd_timer
pcspkr                  2396  0
soundcore               6144  1 snd
serio_raw               5248  0
videobuf_dma_sg        11008  2 saa7134_dvb,saa7134
ath5k                 131048  0
k8temp                  4348  0
sr_mod                 14948  0
atl1                   31044  0
r8169                  32736  0
videobuf_core          15712  3 videobuf_dvb,saa7134,videobuf_dma_sg
tveeprom               11808  1 saa7134
snd_page_alloc          8164  2 snd_hda_intel,snd_pcm
i2c_piix4               9132  0
i2c_core               20432  9
tda1004x,saa7134_dvb,tda827x,tda8290,tuner,saa7134,v4l2_common,tveeprom,i2c_piix4
hwmon                   2360  2 it87,k8temp
cdrom                  33312  1 sr_mod
mii                     4540  2 atl1,r8169
ahci                   30188  3
sg                     28304  0
floppy                 53316  0
pata_via                8288  0
pata_atiixp             4348  5
pata_acpi               3804  0
ata_generic             4448  0
libata                157260  5 ahci,pata_via,pata_atiixp,pata_acpi,ata_generic
sd_mod                 33684  13
scsi_mod              138964  5 scsi_dh,sr_mod,sg,libata,sd_mod
crc_t10dif              1500  1 sd_mod
ext3                  125924  3
jbd                    44016  1 ext3
mbcache                 6560  2 ext4,ext3
uhci_hcd               22252  0
ohci_hcd               23532  0
ehci_hcd               35240  0




[root@duron ~]# tc -V
tc utility, iproute2-ss090115



(on the list below, eth2 is the D-Link System Inc DGE-528T Gigabit
Ethernet Adapter (rev 10))
[root@duron ~]# lspci -vv
00:00.0 Host bridge: Advanced Micro Devices [AMD] RS780 Host Bridge
        Subsystem: ATI Technologies Inc Unknown device 7910
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
        Latency: 0

00:01.0 PCI bridge: Advanced Micro Devices [AMD] RS780 PCI to PCI
bridge (int gfx) (prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64
        Bus: primary=00, secondary=01, subordinate=01, sec-latency=64
        I/O behind bridge: 0000d000-0000dfff
        Memory behind bridge: fe800000-fe9fffff
        Prefetchable memory behind bridge: 00000000d0000000-00000000dfffffff
        Secondary status: 66MHz+ FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort+ <SERR- <PERR-
        BridgeCtl: Parity- SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
        Capabilities: [44] HyperTransport: MSI Mapping Enable+ Fixed+
        Capabilities: [b0] Subsystem: Advanced Micro Devices [AMD]
RS780 PCI to PCI bridge (int gfx)

00:06.0 PCI bridge: Advanced Micro Devices [AMD] RS780 PCI to PCI
bridge (PCIE port 2) (prog-if 00 [Normal decode])
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
        Memory behind bridge: fea00000-feafffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
        BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
        Capabilities: [50] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
                DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s
<64ns, L1 <1us
                        ExtTag+ RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 128 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq-
AuxPwr- TransPend-
                LnkCap: Port #3, Speed 5GT/s, Width x1, ASPM L0s L1,
Latency L0 <64ns, L1 <1us
                        ClockPM- Suprise- LLActRep+ BwNot+
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train-
SlotClk+ DLActive+ BWMgmt+ ABWMgmt-
                SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd-
HotPlug+ Surpise+
                        Slot #  6, PowerLimit 25.000000; Interlock- NoCompl+
                SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet-
CmdCplt- HPIrq- LinkChg-
                        Control: AttnInd Unknown, PwrInd Unknown,
Power- Interlock-
                SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt-
PresDet+ Interlock-
                        Changed: MRL- PresDet+ LinkState+
                RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal-
PMEIntEna- CRSVisible-
                RootCap: CRSVisible-
                RootSta: PME ReqID 0000, PMEStatus- PMEPending-
        Capabilities: [a0] Message Signalled Interrupts: Mask- 64bit-
Queue=0/0 Enable+
                Address: fee0300c  Data: 4159
        Capabilities: [b0] Subsystem: ATI Technologies Inc Unknown device 7910
        Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
        Capabilities: [100] Vendor Specific Information <?>
        Capabilities: [110] Virtual Channel <?>
        Kernel driver in use: pcieport-driver

00:11.0 SATA controller: ATI Technologies Inc SB700/SB800 SATA
Controller [IDE mode] (prog-if 01 [AHCI 1.0])
        Subsystem: ASUSTeK Computer Inc. Unknown device 82f1
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 26
        Region 0: I/O ports at c000 [size=8]
        Region 1: I/O ports at b000 [size=4]
        Region 2: I/O ports at a000 [size=8]
        Region 3: I/O ports at 9000 [size=4]
        Region 4: I/O ports at 8000 [size=16]
        Region 5: Memory at fe7ff800 (32-bit, non-prefetchable) [size=1K]
        Capabilities: [60] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+
Queue=0/2 Enable+
                Address: 00000000fee0200c  Data: 4181
        Capabilities: [70] SATA HBA <?>
        Kernel driver in use: ahci
        Kernel modules: ahci

00:12.0 USB Controller: ATI Technologies Inc SB700/SB800 USB OHCI0
Controller (prog-if 10 [OHCI])
        Subsystem: ATI Technologies Inc SB700/SB800 USB OHCI0 Controller
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 16
        Region 0: Memory at fe7fe000 (32-bit, non-prefetchable) [size=4K]
        Kernel driver in use: ohci_hcd
        Kernel modules: ohci-hcd

00:12.1 USB Controller: ATI Technologies Inc SB700 USB OHCI1
Controller (prog-if 10 [OHCI])
        Subsystem: ATI Technologies Inc SB700 USB OHCI1 Controller
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 16
        Region 0: Memory at fe7fd000 (32-bit, non-prefetchable) [size=4K]
        Kernel driver in use: ohci_hcd
        Kernel modules: ohci-hcd

00:12.2 USB Controller: ATI Technologies Inc SB700/SB800 USB EHCI
Controller (prog-if 20 [EHCI])
        Subsystem: ATI Technologies Inc Unknown device 4397
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 64 bytes
        Interrupt: pin B routed to IRQ 17
        Region 0: Memory at fe7ff000 (32-bit, non-prefetchable) [size=256]
        Capabilities: [c0] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold-)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
                Bridge: PM- B3+
        Capabilities: [e4] Debug port: BAR=1 offset=00e0
        Kernel driver in use: ehci_hcd
        Kernel modules: ehci-hcd

00:13.0 USB Controller: ATI Technologies Inc SB700/SB800 USB OHCI0
Controller (prog-if 10 [OHCI])
        Subsystem: ATI Technologies Inc Unknown device 4398
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 18
        Region 0: Memory at fe7fc000 (32-bit, non-prefetchable) [size=4K]
        Kernel driver in use: ohci_hcd
        Kernel modules: ohci-hcd

00:13.1 USB Controller: ATI Technologies Inc SB700 USB OHCI1
Controller (prog-if 10 [OHCI])
        Subsystem: ATI Technologies Inc Unknown device 4399
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 18
        Region 0: Memory at fe7fb000 (32-bit, non-prefetchable) [size=4K]
        Kernel driver in use: ohci_hcd
        Kernel modules: ohci-hcd

00:13.2 USB Controller: ATI Technologies Inc SB700/SB800 USB EHCI
Controller (prog-if 20 [EHCI])
        Subsystem: ATI Technologies Inc SB700/SB800 USB EHCI Controller
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 64 bytes
        Interrupt: pin B routed to IRQ 19
        Region 0: Memory at fe7fa800 (32-bit, non-prefetchable) [size=256]
        Capabilities: [c0] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold-)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
                Bridge: PM- B3+
        Capabilities: [e4] Debug port: BAR=1 offset=00e0
        Kernel driver in use: ehci_hcd
        Kernel modules: ehci-hcd

00:14.0 SMBus: ATI Technologies Inc SBx00 SMBus Controller (rev 3a)
        Subsystem: ASUSTeK Computer Inc. Unknown device 82f1
        Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Capabilities: [b0] HyperTransport: MSI Mapping Enable- Fixed+
        Kernel driver in use: piix4_smbus
        Kernel modules: i2c-piix4

00:14.1 IDE interface: ATI Technologies Inc SB700/SB800 IDE Controller
(prog-if 8a [Master SecP PriP])
        Subsystem: ASUSTeK Computer Inc. Unknown device 82f1
        Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64
        Interrupt: pin A routed to IRQ 16
        Region 0: I/O ports at 01f0 [size=8]
        Region 1: I/O ports at 03f4 [size=1]
        Region 2: I/O ports at 0170 [size=8]
        Region 3: I/O ports at 0374 [size=1]
        Region 4: I/O ports at ff00 [size=16]
        Capabilities: [70] Message Signalled Interrupts: Mask- 64bit-
Queue=0/1 Enable-
                Address: 00000000  Data: 0000
        Kernel driver in use: pata_atiixp
        Kernel modules: pata_atiixp

00:14.2 Audio device: ATI Technologies Inc SBx00 Azalia (Intel HDA)
        Subsystem: ASUSTeK Computer Inc. Unknown device 82fe
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=slow >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 64 bytes
        Interrupt: pin ? routed to IRQ 16
        Region 0: Memory at fe7f4000 (64-bit, non-prefetchable) [size=16K]
        Capabilities: [50] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Kernel driver in use: HDA Intel
        Kernel modules: snd-hda-intel

00:14.3 ISA bridge: ATI Technologies Inc SB700/SB800 LPC host controller
        Subsystem: ATI Technologies Inc Unknown device 4383
        Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0

00:14.4 PCI bridge: ATI Technologies Inc SBx00 PCI to PCI Bridge
(prog-if 01 [Subtractive decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64
        Bus: primary=00, secondary=03, subordinate=03, sec-latency=64
        I/O behind bridge: 0000e000-0000efff
        Memory behind bridge: feb00000-febfffff
        Prefetchable memory behind bridge: f0000000-f00fffff
        Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort+ <SERR- <PERR-
        BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-

00:14.5 USB Controller: ATI Technologies Inc SB700/SB800 USB OHCI2
Controller (prog-if 10 [OHCI])
        Subsystem: ATI Technologies Inc Unknown device 4396
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 64 bytes
        Interrupt: pin C routed to IRQ 18
        Region 0: Memory at fe7f9000 (32-bit, non-prefetchable) [size=4K]
        Kernel driver in use: ohci_hcd
        Kernel modules: ohci-hcd

00:18.0 Host bridge: Advanced Micro Devices [AMD] K8
[Athlon64/Opteron] HyperTransport Technology Configuration
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Capabilities: [80] HyperTransport: Host or Secondary Interface
                !!! Possibly incomplete decoding
                Command: WarmRst+ DblEnd-
                Link Control: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=0
                Link Config: MLWI=16bit MLWO=16bit LWI=16bit LWO=16bit
                Revision ID: 1.02

00:18.1 Host bridge: Advanced Micro Devices [AMD] K8
[Athlon64/Opteron] Address Map
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.2 Host bridge: Advanced Micro Devices [AMD] K8
[Athlon64/Opteron] DRAM Controller
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.3 Host bridge: Advanced Micro Devices [AMD] K8
[Athlon64/Opteron] Miscellaneous Control
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Capabilities: [f0] Secure device <?>
        Kernel driver in use: k8temp
        Kernel modules: k8temp

01:05.0 VGA compatible controller: ATI Technologies Inc Radeon HD 3200
Graphics (prog-if 00 [VGA controller])
        Subsystem: ASUSTeK Computer Inc. Unknown device 82f1
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 10
        Region 0: Memory at d0000000 (32-bit, prefetchable) [size=256M]
        Region 1: I/O ports at d000 [size=256]
        Region 2: Memory at fe9f0000 (32-bit, non-prefetchable) [size=64K]
        Region 5: Memory at fe800000 (32-bit, non-prefetchable) [size=1M]
        Capabilities: [50] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [a0] Message Signalled Interrupts: Mask- 64bit+
Queue=0/0 Enable-
                Address: 0000000000000000  Data: 0000

01:05.1 Audio device: ATI Technologies Inc RS780 Azalia controller
        Subsystem: ATI Technologies Inc RS780 Azalia controller
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin B routed to IRQ 19
        Region 0: Memory at fe9e8000 (32-bit, non-prefetchable) [size=16K]
        Capabilities: [50] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [a0] Message Signalled Interrupts: Mask- 64bit+
Queue=0/0 Enable-
                Address: 0000000000000000  Data: 0000
        Kernel driver in use: HDA Intel
        Kernel modules: snd-hda-intel

02:00.0 Ethernet controller: Attansic Technology Corp. L1 Gigabit
Ethernet Adapter (rev b0)
        Subsystem: ASUSTeK Computer Inc. P5KPL-VM Motherboard
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR+ <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 27
        Region 0: Memory at feac0000 (64-bit, non-prefetchable) [size=256K]
        Expansion ROM at feaa0000 [disabled] [size=128K]
        Capabilities: [40] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [48] Message Signalled Interrupts: Mask- 64bit+
Queue=0/0 Enable+
                Address: 00000000fee0300c  Data: 41a1
        Capabilities: [58] Express (v1) Endpoint, MSI 00
                DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s
<4us, L1 unlimited
                        ExtTag- AttnBtn+ AttnInd+ PwrInd+ RBE- FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr- UncorrErr+ FatalErr- UnsuppReq+
AuxPwr+ TransPend+
                LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s,
Latency L0 unlimited, L1 unlimited
                        ClockPM- Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train-
SlotClk+ DLActive- BWMgmt- ABWMgmt-
        Capabilities: [100] Advanced Error Reporting <?>
        Kernel driver in use: atl1
        Kernel modules: atl1

03:05.0 Ethernet controller: D-Link System Inc DGE-528T Gigabit
Ethernet Adapter (rev 10)
        Subsystem: D-Link System Inc DGE-528T Gigabit Ethernet Adapter
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64 (8000ns min, 16000ns max), Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 20
        Region 0: I/O ports at e800 [size=256]
        Region 1: Memory at febffc00 (32-bit, non-prefetchable) [size=256]
        Expansion ROM at f0000000 [disabled] [size=128K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Kernel driver in use: r8169
        Kernel modules: r8169

03:06.0 Ethernet controller: Atheros Communications Inc. Atheros
AR5001X+ Wireless Network Adapter (rev 01)
        Subsystem: Global Sun Technology Inc Trust Speedshare Turbo
Pro Wireless PCI Adapter
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 168 (2500ns min, 7000ns max), Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 21
        Region 0: Memory at febe0000 (32-bit, non-prefetchable) [size=64K]
        Capabilities: [44] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 PME-Enable- DSel=0 DScale=2 PME-
        Kernel driver in use: ath5k
        Kernel modules: ath5k

03:07.0 Multimedia controller: Philips Semiconductors
SAA7131/SAA7133/SAA7135 Video Broadcast Decoder (rev d0)
        Subsystem: ASUSTeK Computer Inc. P7131 Dual
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64 (21000ns min, 8000ns max)
        Interrupt: pin A routed to IRQ 22
        Region 0: Memory at febff000 (32-bit, non-prefetchable) [size=2K]
        Capabilities: [40] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Kernel driver in use: saa7134
        Kernel modules: saa7134










On Mon, Mar 2, 2009 at 6:44 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> Andrew Morton wrote, On 03/02/2009 01:57 AM:
>
>> (cc netdev)
>>
>> On Mon, 2 Mar 2009 00:36:03 +0000 Joao Correia <joaomiguelcorreia@gmail.com> wrote:
>>
>>> Hello all
>>>
>>> On a Fedora 9 box, with a 2.6.29-rc6-git5 compiled with the same
>>> .config as the previously running 2.6.28.7, i get:
>>>
>>> [root@duron ~]# /sbin/tc qdisc add dev eth2 handle ffff: ingress
>>> [root@duron ~]# /sbin/tc filter add dev eth2 parent ffff: protocol ip
>>> prio 50 u32 match ip src 0.0.0.0/0 police rate 30320kbit burst 500k
>>> drop flowid :1
>>> RTNETLINK answers: Invalid argument
>>> We have an error talking to the kernel
>>> [root@duron ~]# uname -a
>>> Linux duron 2.6.29-rc6-git5 #3 SMP Sun Mar 1 00:02:56 WET 2009 i686
>>> athlon i386 GNU/Linux
>>> [root@duron ~]#
>>>
>>> There is no information regarding this event on dmesg or /var/log/messages.
>>> eth2 exists and is working properly, under 2.6.28.7 it works (without
>>> complaints).
>>>
>>> Please advise on what steps I may take to provide more information. I have
>>> both kernel sources and availability to apply patches/recompile as needed.
>
>
> Hi,
>
> I've just repeated your commands (with eth0) on the current Linus' tree
> and it works OK. Check your .config and "modules_install" again, and if
> no result send gzipped .config and show "lsmod" and "tc -V" output after
> these commands above.
>
> Cheers,
> Jarek P.
>
