From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: RE: e1000 lockup with port io type reset
Date: Wed, 2 Jul 2003 20:05:03 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.53.0307022003430.10559@montezuma.mastecende.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010107DA2C@orsmsx402.jf.intel.com>
 <Pine.LNX.4.53.0306280145260.16505@montezuma.mastecende.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <Pine.LNX.4.53.0306280145260.16505@montezuma.mastecende.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 28 Jun 2003, Zwane Mwaikambo wrote:

> Thanks, i just have to wait on the dmi decode. I'll have it to you ASAP.

Here we go;

# dmidecode 2.1
SMBIOS 2.3 present.
46 structures occupying 1342 bytes.
Table at 0x000F2970.
Handle 0x0000
	DMI type 0, 20 bytes.
	BIOS Information
		Vendor: Award Software, Inc.
		Version: ASUS CUV4X-E ACPI BIOS Revision 1004
		Release Date: 07/25/2001
		Address: 0xF0000
		Runtime Size: 64 kB
		ROM Size: 256 kB
		Characteristics:
			PCI is supported
			PNP is supported
			APM is supported
			BIOS is upgradeable
			BIOS shadowing is allowed
			ESCD support is available
			Boot from CD is supported
			Selectable boot is supported
			BIOS ROM is socketed
			EDD is supported
			5.25"/360 KB floppy services are supported (int 13h)
			5.25"/1.2 MB floppy services are supported (int 13h)
			3.5"/720 KB floppy services are supported (int 13h)
			3.5"/2.88 MB floppy services are supported (int 13h)
			Print screen service is supported (int 5h)
			8042 keyboard services are supported (int 9h)
			Serial services are supported (int 14h)
			Printer services are supported (int 17h)
			CGA/mono video services are supported (int 10h)
			ACPI is supported
			AGP is supported
Handle 0x0001
	DMI type 1, 25 bytes.
	System Information
		Manufacturer: System Manufacturer
		Product Name: System Name
		Version: System Version
		Serial Number: SYS-1234567890
		UUID: Not Settable
		Wake-up Type: Power Switch
Handle 0x0002
	DMI type 2, 8 bytes.
	Base Board Information
		Manufacturer: ASUSTeK Computer INC.
		Product Name: CUV4X-E
		Version: REV 1.xx
		Serial Number: xxxxxxxxxxx
Handle 0x0003
	DMI type 3, 17 bytes.
	Chassis Information
		Manufacturer: Chassis Manufacture
		Type: Tower
		Lock: Not Present
		Version: Chassis Version
		Serial Number: Chassis Serial Number
		Asset Tag: Asset-1234567890
		Boot-up State: Safe
		Power Supply State: Safe
		Thermal State: Safe
		Security Status: Unknown
		OEM Information: 0x00000000
Handle 0x0004
	DMI type 4, 32 bytes.
	Processor Information
		Socket Designation: PGA 370
		Type: Central Processor
		Family: Celeron
		Manufacturer: GenuineIntel
		ID: 8A 06 00 00 FF F9 83 03
		Signature: Type 0, Family 6, Model 8, Stepping 10
		Flags:
			FPU (Floating-point unit on-chip)
			VME (Virtual mode extension)
			DE (Debugging extension)
			PSE (Page size extension)
			TSC (Time stamp counter)
			MSR (Model specific registers)
			PAE (Physical address extension)
			MCE (Machine check exception)
			CX8 (CMPXCHG8 instruction supported)
			SEP (Fast system call)
			MTRR (Memory type range registers)
			PGE (Page global enable)
			MCA (Machine check architecture)
			CMOV (Conditional move instruction supported)
			PAT (Page attribute table)
			PSE-36 (36-bit page size extension)
			MMX (MMX technology supported)
			FXSR (Fast floating-point save and restore)
			SSE (Streaming SIMD extensions)
		Version: Intel Celeron(TM) Processor
		Voltage: 1.7 V
		External Clock: 100 MHz
		Max Speed: 1200 MHz
		Current Speed: 1100 MHz
		Status: Populated, Enabled
		Upgrade: LIF Socket
		L1 Cache Handle: 0x000A
		L2 Cache Handle: 0x000B
		L3 Cache Handle: Not Provided
Handle 0x0005
	DMI type 5, 24 bytes.
	Memory Controller Information
		Error Detecting Method: None
		Error Correcting Capabilities:
			Other
		Supported Interleave: Unknown
		Current Interleave: Unknown
		Maximum Memory Module Size: 1024 MB
		Maximum Total Memory Size: 4096 MB
		Supported Speeds:
			70 ns
			60 ns
			50 ns
		Supported Memory Types:
			DIMM
			SDRAM
		Memory Module Voltage: 3.3 V
		Associated Memory Slots: 4
			0x0006
			0x0007
			0x0008
			0x0009
		Enabled Error Correcting Capabilities:
			Unknown
Handle 0x0006
	DMI type 6, 12 bytes.
	Memory Module Information
		Socket Designation: DIMM 1
		Bank Connections: 0 1
		Current Speed: Unknown
		Type: DIMM SDRAM
		Installed Size: 128 MB (Single-bank Connection)
		Enabled Size: 128 MB (Single-bank Connection)
		Error Status: OK
Handle 0x0007
	DMI type 6, 12 bytes.
	Memory Module Information
		Socket Designation: DIMM 2
		Bank Connections: 2 3
		Current Speed: Unknown
		Type: DIMM SDRAM
		Installed Size: 128 MB (Double-bank Connection)
		Enabled Size: 128 MB (Double-bank Connection)
		Error Status: OK
Handle 0x0008
	DMI type 6, 12 bytes.
	Memory Module Information
		Socket Designation: DIMM 3
		Bank Connections: 4 5
		Current Speed: Unknown
		Type: DIMM SDRAM
		Installed Size: Not Installed (Single-bank Connection)
		Enabled Size: Not Installed (Single-bank Connection)
		Error Status: OK
Handle 0x0009
	DMI type 6, 12 bytes.
	Memory Module Information
		Socket Designation: DIMM 4
		Bank Connections: 6 7
		Current Speed: Unknown
		Type: DIMM SDRAM
		Installed Size: Not Installed (Single-bank Connection)
		Enabled Size: Not Installed (Single-bank Connection)
		Error Status: OK
Handle 0x000A
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: L1 Cache
		Configuration: Enabled, Not Socketed, Level 1
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 32 KB
		Maximum Size: 32 KB
		Supported SRAM Types:
			Pipeline Burst
			Synchronous
		Installed SRAM Type: Pipeline Burst Synchronous
		Speed: Unknown
		Error Correction Type: Unknown
		System Type: Data
		Associativity: 4-way Set-associative
Handle 0x000B
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: L2 Cache
		Configuration: Enabled, Not Socketed, Level 2
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 128 KB
		Maximum Size: 256 KB
		Supported SRAM Types:
			Pipeline Burst
			Synchronous
		Installed SRAM Type: Pipeline Burst Synchronous
		Speed: Unknown
		Error Correction Type: Unknown
		System Type: Data
		Associativity: 4-way Set-associative
Handle 0x000C
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: PRIMARY IDE/HDD
		Internal Connector Type: On Board IDE
		External Reference Designator: Not Specified
		External Connector Type: None
		Port Type: None
Handle 0x000D
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: SECONDARY IDE/HDD
		Internal Connector Type: On Board IDE
		External Reference Designator: Not Specified
		External Connector Type: None
		Port Type: None
Handle 0x000E
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: FLOPPY
		Internal Connector Type: On Board Floppy
		External Reference Designator: Not Specified
		External Connector Type: None
		Port Type: None
Handle 0x000F
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: USB1
		External Connector Type: Access Bus (USB)
		Port Type: USB
Handle 0x0010
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: USB2
		External Connector Type: Access Bus (USB)
		Port Type: USB
Handle 0x0011
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: PS/2 Keybaord
		External Connector Type: PS/2
		Port Type: Keyboard Port
Handle 0x0012
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: PS/2 Mouse
		External Connector Type: PS/2
		Port Type: Mouse Port
Handle 0x0013
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: Parallel Port
		External Connector Type: DB-25 female
		Port Type: Parallel Port ECP/EPP
Handle 0x0014
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: Serial Port
		External Connector Type: DB-9 male
		Port Type: Serial Port 16550 Compatible
Handle 0x0015
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: Serial Port 2
		External Connector Type: DB-9 male
		Port Type: Serial Port 16550 Compatible
Handle 0x0016
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: Video Port
		External Connector Type: Mini Jack (headphones)
		Port Type: Video Port
Handle 0x0017
	DMI type 9, 13 bytes.
	System Slot Information
		Designation: PCI 1
		Type: 32-bit PCI
		Current Usage: Available
		Length: Short
		ID: 1
		Characteristics:
			5.0 V is provided
			3.3 V is provided
			PME signal is supported
Handle 0x0018
	DMI type 9, 13 bytes.
	System Slot Information
		Designation: PCI 2
		Type: 32-bit PCI
		Current Usage: In Use
		Length: Short
		ID: 2
		Characteristics:
			5.0 V is provided
			3.3 V is provided
			PME signal is supported
Handle 0x0019
	DMI type 9, 13 bytes.
	System Slot Information
		Designation: PCI 3
		Type: 32-bit PCI
		Current Usage: In Use
		Length: Short
		ID: 3
		Characteristics:
			5.0 V is provided
			3.3 V is provided
			PME signal is supported
Handle 0x001A
	DMI type 9, 13 bytes.
	System Slot Information
		Designation: PCI 4
		Type: 32-bit PCI
		Current Usage: In Use
		Length: Short
		ID: 4
		Characteristics:
			5.0 V is provided
			3.3 V is provided
			PME signal is supported
Handle 0x001B
	DMI type 9, 13 bytes.
	System Slot Information
		Designation: PCI 5
		Type: 32-bit PCI
		Current Usage: Available
		Length: Short
		ID: 5
		Characteristics:
			5.0 V is provided
			3.3 V is provided
			PME signal is supported
Handle 0x001C
	DMI type 9, 13 bytes.
	System Slot Information
		Designation: PCI 6
		Type: 32-bit PCI
		Current Usage: Available
		Length: Short
		ID: 6
		Characteristics:
			5.0 V is provided
			3.3 V is provided
			PME signal is supported
Handle 0x001D
	DMI type 9, 13 bytes.
	System Slot Information
		Designation: AGP
		Type: 32-bit PCI
		Current Usage: In Use
		Length: Short
		ID: 7
		Characteristics:
			3.3 V is provided
			PME signal is supported
Handle 0x001E
	DMI type 11, 5 bytes.
	OEM Strings
		String 1: 0
		String 2: 0
Handle 0x001F
	DMI type 13, 22 bytes.
	BIOS Language Information
		Installable Languages: 1
			en|US|iso8859-1
		Currently Installed Language: en|US|iso8859-1
Handle 0x0020
	DMI type 14, 14 bytes.
	Group Associations
		Name: Cpu Module
		Items: 3
			0x0004 (Processor)
			0x000A (Cache)
			0x000B (Cache)
Handle 0x0021
	DMI type 14, 35 bytes.
	Group Associations
		Name: Memory Module Set
		Items: 10
			0x0022 (Physical Memory Array)
			0x0023 (Memory Device)
			0x0028 (Memory Device Mapped Address)
			0x0024 (Memory Device)
			0x0029 (Memory Device Mapped Address)
			0x0025 (Memory Device)
			0x002A (Memory Device Mapped Address)
			0x0026 (Memory Device)
			0x002B (Memory Device Mapped Address)
			0x0027 (Memory Array Mapped Address)
Handle 0x0022
	DMI type 16, 15 bytes.
	Physical Memory Array
		Location: System Board Or Motherboard
		Use: System Memory
		Error Correction Type: None
		Maximum Capacity: 1 GB
		Error Information Handle: Not Provided
		Number Of Devices: 4
Handle 0x0023
	DMI type 17, 23 bytes.
	Memory Device
		Array Handle: 0x0022
		Error Information Handle: No Error
		Total Width: 72 bits
		Data Width: 64 bits
		Size: 128 MB
		Form Factor: DIMM
		Set: 1
		Locator: DIMM 1
		Bank Locator: Not Specified
		Type: DRAM
		Type Detail: Synchronous
		Speed: Unknown
Handle 0x0024
	DMI type 17, 23 bytes.
	Memory Device
		Array Handle: 0x0022
		Error Information Handle: No Error
		Total Width: 72 bits
		Data Width: 64 bits
		Size: 128 MB
		Form Factor: DIMM
		Set: 2
		Locator: DIMM 2
		Bank Locator: Not Specified
		Type: DRAM
		Type Detail: Synchronous
		Speed: Unknown
Handle 0x0025
	DMI type 17, 23 bytes.
	Memory Device
		Array Handle: 0x0022
		Error Information Handle: No Error
		Total Width: Unknown
		Data Width: Unknown
		Size: No Module Installed
		Form Factor: DIMM
		Set: 2
		Locator: DIMM 3
		Bank Locator: Not Specified
		Type: DRAM
		Type Detail: Synchronous
		Speed: Unknown
Handle 0x0026
	DMI type 17, 23 bytes.
	Memory Device
		Array Handle: 0x0022
		Error Information Handle: No Error
		Total Width: Unknown
		Data Width: Unknown
		Size: No Module Installed
		Form Factor: DIMM
		Set: 2
		Locator: DIMM 4
		Bank Locator: Not Specified
		Type: DRAM
		Type Detail: Synchronous
		Speed: Unknown
Handle 0x0027
	DMI type 19, 15 bytes.
	Memory Array Mapped Address
		Starting Address: 0x00000000000
		Ending Address: 0x040000003FF
		Range Size: 268435457 kB
		Physical Array Handle: 0x0022
		Partition Width: 0
Handle 0x0028
	DMI type 20, 19 bytes.
	Memory Device Mapped Address
		Starting Address: 0x00000000000
		Ending Address: 0x00007FFFFFF
		Range Size: 128 MB
		Physical Device Handle: 0x0023
		Memory Array Mapped Address Handle: 0x0027
		Partition Row Position: 1
Handle 0x0029
	DMI type 20, 19 bytes.
	Memory Device Mapped Address
		Starting Address: 0x00008000000
		Ending Address: 0x0000FFFFFFF
		Range Size: 128 MB
		Physical Device Handle: 0x0024
		Memory Array Mapped Address Handle: 0x0027
		Partition Row Position: 2
Handle 0x002A
	DMI type 126, 19 bytes.
	Inactive
Handle 0x002B
	DMI type 126, 19 bytes.
	Inactive
Handle 0x002C
	DMI type 32, 11 bytes.
	System Boot Information
		Status: No errors detected
Handle 0x002D
	DMI type 127, 4 bytes.
	End Of Table

00:00.0 Host bridge: VIA Technologies, Inc. VT82C693A/694x [Apollo PRO133x] (rev c4)
	Subsystem: Asustek Computer, Inc.: Unknown device 80e7
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Latency: 0
	Region 0: Memory at fc000000 (32-bit, prefetchable) [size=32M]
	Capabilities: [a0] AGP version 2.0
		Status: RQ=31 SBA+ 64bit- FW- Rate=x1,x2
		Command: RQ=0 SBA- AGP- 64bit- FW- Rate=<none>
	Capabilities: [c0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 06 11 91 06 06 00 10 22 c4 00 00 06 00 00 00 00
10: 08 00 00 fc 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 43 10 e7 80
30: 00 00 00 00 a0 00 00 00 00 00 00 00 00 00 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: fd d8 c8 f6 04 00 10 10 88 00 08 08 0c 10 10 10
60: 0f 2a 00 a0 e6 e6 95 95 41 7c 86 2f 08 6f 00 33
70: c0 88 cc 0c 0e a1 d2 00 01 b4 01 02 00 00 00 02
80: 0f 41 00 00 e0 00 00 00 03 80 f1 0f cc 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 02 c0 20 00 03 02 00 1f 00 00 00 00 6b 02 00 00
b0: 7f 63 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 01 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 01 00 00 00 00 00 00 0e 00 00 00 00 00 00 00 00

00:01.0 PCI bridge: VIA Technologies, Inc. VT82C598/694x [Apollo MVP3/Pro133x AGP] (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Latency: 0
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
	I/O behind bridge: 0000d000-0000dfff
	Memory behind bridge: fa000000-fadfffff
	Prefetchable memory behind bridge: faf00000-fbffffff
	BridgeCtl: Parity- SERR- NoISA- VGA+ MAbort- >Reset- FastB2B-
	Capabilities: [80] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 06 11 98 85 07 00 30 22 00 00 04 06 00 00 01 00
10: 00 00 00 00 00 00 00 00 00 01 01 00 d0 d0 00 00
20: 00 fa d0 fa f0 fa f0 fb 00 00 00 00 00 00 00 00
30: 00 00 00 00 80 00 00 00 00 00 00 00 00 00 08 00
40: c8 cd 00 44 04 72 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 01 00 02 02 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:04.0 ISA bridge: VIA Technologies, Inc. VT82C686 [Apollo Super South] (rev 40)
	Subsystem: Asustek Computer, Inc.: Unknown device 80e7
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping+ SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Capabilities: [c0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 06 11 86 06 87 00 10 02 40 00 01 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 43 10 e7 80
30: 00 00 00 00 c0 00 00 00 00 00 00 00 00 00 00 00
40: 08 41 00 00 00 80 60 a0 05 00 84 00 00 00 00 f3
50: 0e 06 04 00 00 a0 b0 70 00 04 ff 08 40 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 27 00 40 82 00 00 60 00 00 00 00 00
80: 00 00 00 00 00 1d 00 00 00 60 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 01 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 41 00 00 00 00 00 00 00 00 00

00:04.1 IDE interface: VIA Technologies, Inc. VT82C586/B/686A/B PIPC Bus Master IDE (rev 06) (prog-if 8a [Master SecP PriP])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping+ SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32
	Region 4: I/O ports at b800 [size=16]
	Capabilities: [c0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 06 11 71 05 87 00 90 02 06 8a 01 01 00 20 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 b8 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 c0 00 00 00 00 00 00 00 00 00 00 00
40: 0b c2 09 05 1c 10 c0 00 a8 20 a8 20 ff 00 ff ff
50: 07 07 17 f0 04 00 00 00 a8 a8 a8 a8 00 00 00 00
60: 00 02 00 00 00 00 00 00 00 02 00 00 00 00 00 00
70: 02 01 00 00 00 00 00 00 02 01 00 00 00 00 00 00
80: 00 50 f6 0f 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 01 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 06 00 71 05 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:04.4 Host bridge: VIA Technologies, Inc. VT82C686 [Apollo Super ACPI] (rev 40)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Capabilities: [68] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 06 11 57 30 00 00 90 02 40 00 00 06 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 68 00 00 00 00 00 00 00 00 00 00 00
40: 20 80 40 00 1a 10 00 00 01 e4 00 00 48 08 00 00
50: 00 ff ff 04 10 00 00 00 00 ff ff 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 01 00 02 00 00 00 00 00
70: 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 01 e8 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 01 00 00 00 40 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:08.0 Ethernet controller: Intel Corp. 82544GC Gigabit Ethernet Controller (Copper) (rev 02)
	Subsystem: Intel Corp. PRO/1000 T Desktop Adapter
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (63750ns min), cache line size 08
	Interrupt: pin A routed to IRQ 10
	Region 0: Memory at f9800000 (32-bit, non-prefetchable) [size=128K]
	Region 1: Memory at f9000000 (32-bit, non-prefetchable) [size=128K]
	Region 2: I/O ports at a800 [size=32]
	Expansion ROM at <unassigned> [disabled] [size=128K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable+ DSel=0 DScale=1 PME-
	Capabilities: [e4] PCI-X non-bridge device.
		Command: DPERE- ERO+ RBC=0 OST=0
		Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-, DC=simple, DMMRBC=2, DMOST=0, DMCRS=0, RSCEM-	Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000
00: 86 80 0c 10 17 00 30 02 02 00 00 02 08 20 00 00
10: 00 00 80 f9 00 00 00 f9 01 a8 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 12 11
30: 00 00 00 00 dc 00 00 00 00 00 00 00 0a 01 ff 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 01 e4 22 c8
e0: 00 21 00 37 07 f0 02 00 00 00 40 00 00 00 00 00
f0: 05 00 80 00 00 00 00 00 00 00 00 00 00 00 00 00

00:09.0 Ethernet controller: 3Com Corporation 3c905B 100BaseTX [Cyclone] (rev 30)
	Subsystem: 3Com Corporation 3C905B Fast Etherlink XL 10/100
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (2500ns min, 2500ns max), cache line size 08
	Interrupt: pin A routed to IRQ 7
	Region 0: I/O ports at a400 [size=128]
	Region 1: Memory at f8800000 (32-bit, non-prefetchable) [size=128]
	Expansion ROM at <unassigned> [disabled] [size=128K]
	Capabilities: [dc] Power Management version 1
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: b7 10 55 90 17 00 10 02 30 00 00 02 08 20 00 00
10: 01 a4 00 00 00 00 80 f8 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 b7 10 55 90
30: 00 00 00 00 dc 00 00 00 00 00 00 00 07 01 0a 0a
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 40 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 01 00 01 f6
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:0a.0 FireWire (IEEE 1394): Texas Instruments TSB12LV23 IEEE-1394 Controller (prog-if 10 [OHCI])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (750ns min, 1000ns max), cache line size 08
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at f8000000 (32-bit, non-prefetchable) [size=2K]
	Region 1: Memory at f7800000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: [44] Power Management version 1
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 4c 10 19 80 16 00 10 02 00 10 00 0c 08 20 00 00
10: 00 00 00 f8 00 00 80 f7 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 44 00 00 00 00 00 00 00 0b 01 03 04
40: 00 00 00 00 01 00 11 40 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

01:00.0 VGA compatible controller: ATI Technologies Inc 3D Rage Pro AGP 1X/2X (rev 5c) (prog-if 00 [VGA])
	Subsystem: ATI Technologies Inc Rage Pro Turbo AGP 2X
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping+ SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (2000ns min), cache line size 08
	Region 0: Memory at fb000000 (32-bit, prefetchable) [size=16M]
	Region 1: I/O ports at d800 [size=256]
	Region 2: Memory at fa000000 (32-bit, non-prefetchable) [size=4K]
	Expansion ROM at fafe0000 [disabled] [size=128K]
	Capabilities: [50] AGP version 1.0
		Status: RQ=255 SBA+ 64bit- FW- Rate=x1,x2
		Command: RQ=0 SBA- AGP- 64bit- FW- Rate=<none>
00: 02 10 42 47 87 00 90 02 5c 00 00 03 08 40 00 00
10: 08 00 00 fb 01 d8 00 00 00 00 00 fa 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 02 10 80 00
30: 00 00 fe fa 50 00 00 00 00 00 00 00 ff 00 08 00
40: 0c 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 02 00 10 00 03 02 00 ff 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
