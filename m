From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: e1000: driver reboot/kexec bug.
Date: 17 Feb 2005 10:57:47 -0700
Message-ID: <m1is4rt6g4.fsf@ebiederm.dsl.xmission.com>
References: <468F3FDA28AA87429AD807992E22D07E044A1285@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <jgarzik@pobox.com>,
        "Chilakala, Mallikarjuna" <mallikarjuna.chilakala@intel.com>,
        <netdev@oss.sgi.com>
To: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E044A1285@orsmsx408>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"Venkatesan, Ganesh" <ganesh.venkatesan@intel.com> writes:

> Hi Eric:
> 
> Could you send us 'lspci -vvv' output for 3:4.0? Could you also help us
> with some more information on the platform you are using?

> Please send me 'ethtool -e eth?' for the interface corresponding to one
> of the 8086:1079 devices.

The motherboard is an Intel Jarell motherboard with the Lindenhurst
aka E7520 chipset.  I have seen the same symptoms on a recent
Supermicro system as well.

Do you know enough about kexec to attempt to reproduce this problem
that way?

Anyway hopefully this is enough to get you started.

Eric


03:04.0 Ethernet controller: Intel Corp.: Unknown device 1079 (rev 03)
	Subsystem: Intel Corp.: Unknown device 1079
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (63750ns min), cache line size 10
	Interrupt: pin A routed to IRQ 54
	Region 0: Memory at fe000000 (64-bit, non-prefetchable) [size=128K]
	Region 4: I/O ports at 1000 [size=64]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [e4] #07 [0002]
	Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000


ethtool -e eth0
Offset		Values
------		------
0x0000		00 02 b3 e8 fa c8 b0 0c ff ff ff ff ff ff ff ff 
0x0010		00 00 00 00 08 46 1a 34 86 80 79 10 86 80 e8 b2 
0x0020		0c c3 00 00 00 00 05 01 88 1c ff ff ff ff ff ff 
0x0030		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0040		0c c3 21 00 0c 28 05 01 86 0c ff ff ff ff ff ff 
0x0050		ff ff ff ff ff ff ff ff ff ff ff ff ff ff 02 06 
0x0060		0c 01 00 40 13 12 ff ff 0c 01 00 40 08 11 ff ff 
0x0070		ff ff ff ff ff ff ff ff ff ff ff ff ff ff 5e 37 
0x0080		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0090		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x00a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x00b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x00c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x00d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x00e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x00f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0100		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0110		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0120		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0130		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0140		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0150		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0160		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0170		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0180		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0190		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 6f 
0x01f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
