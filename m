From: Simon Guinot <simon.guinot@sequanux.org>
Subject: Re: [PATCH v9 0/8] thunderbolt: Introducing Thunderbolt(TM)
 Networking
Date: Wed, 9 Nov 2016 15:36:32 +0100
Message-ID: <20161109143632.GE6167@kw.sim.vm.gnt>
References: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="mYYhpFXgKVw71fwr"
Cc: gregkh@linuxfoundation.org, andreas.noever@gmail.com,
        bhelgaas@google.com, corbet@lwn.net, linux-kernel@vger.kernel.org,
        linux-pci@vger.kernel.org, netdev@vger.kernel.org,
        linux-doc@vger.kernel.org, mario_limonciello@dell.com,
        thunderbolt-linux@intel.com, mika.westerberg@intel.com,
        tomas.winkler@intel.com, xiong.y.zhang@intel.com,
        Michael Jamet <michael.jamet@intel.com>
To: Amir Levy <amir.jer.levy@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--mYYhpFXgKVw71fwr
Content-Type: multipart/mixed; boundary="kadn00tgSopKmJ1H"
Content-Disposition: inline


--kadn00tgSopKmJ1H
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 09, 2016 at 04:20:00PM +0200, Amir Levy wrote:
> This driver enables Thunderbolt Networking on non-Apple platforms
> running Linux.
>=20
> Thunderbolt Networking provides peer-to-peer connections to transfer
> files between computers, perform PC migrations, and/or set up small
> workgroups with shared storage.
>=20
> This is a virtual connection that emulates an Ethernet adapter that
> enables Ethernet networking with the benefit of Thunderbolt superfast
> medium capability.
>=20
> Thunderbolt Networking enables two hosts and several devices that
> have a Thunderbolt controller to be connected together in a linear
> (Daisy chain) series from a single port.
>=20
> Thunderbolt Networking for Linux is compatible with Thunderbolt
> Networking on systems running macOS or Windows and also supports
> Thunderbolt generation 2 and 3 controllers.
>=20
> Note that all pre-existing Thunderbolt generation 3 features, such as
> USB, Display and other Thunderbolt device connectivity will continue
> to function exactly as they did prior to enabling Thunderbolt Networking.
>=20
> Code and Software Specifications:
> This kernel code creates a virtual ethernet device for computer to
> computer communication over a Thunderbolt cable.
> The new driver is a separate driver to the existing Thunderbolt driver.
> It is designed to work on systems running Linux that
> interface with Intel Connection Manager (ICM) firmware based
> Thunderbolt controllers that support Thunderbolt Networking.
> The kernel code operates in coordination with the Thunderbolt user-
> space daemon to implement full Thunderbolt networking functionality.
>=20
> Hardware Specifications:
> Thunderbolt Hardware specs have not yet been published but are used
> where necessary for register definitions.=20

Hi Amir,

I have an ASUS "All Series/Z87-DELUXE/QUAD" motherboard with a
Thunderbolt 2 "Falcon Ridge" chipset (device ID 156d).

Is the thunderbolt-icm driver supposed to work with this chipset ?

I have installed both a 4.8.6 Linux kernel (patched with your v9
series) and the thunderbolt-software-daemon (27 october release)
inside a Debian system (Jessie).

If I connect the ASUS motherboard with a MacBook Pro (Thunderbolt 2,
device ID 156c), I can see that the thunderbolt-icm driver is loaded and
that the thunderbolt-software-daemon is well started. But the Ethernet
interface is not created.

I have attached to this email the syslog file. There is the logs from
both the kernel and the daemon inside. Note that the daemon logs are
everything but clear about what could be the issue. Maybe I missed some
kind of configuration ? But I failed to find any valuable information
about configuring the driver and/or the daemon in the various
documentation files.

Please, can you provide some guidance ? I'd really like to test your
patch series.

Thanks in advance.

Simon

--kadn00tgSopKmJ1H
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=syslog
Content-Transfer-Encoding: quoted-printable

Nov  9 16:30:30 debian8 systemd-modules-load[218]: Inserted module 'lp'
Nov  9 16:30:30 debian8 systemd-modules-load[218]: Inserted module 'ppdev'
Nov  9 16:30:30 debian8 systemd-modules-load[218]: Inserted module 'parport=
_pc'
Nov  9 16:30:30 debian8 systemd-modules-load[218]: Inserted module 'fuse'
Nov  9 16:30:30 debian8 systemd[1]: Started Create Static Device Nodes in /=
dev.
Nov  9 16:30:30 debian8 systemd[1]: Starting udev Kernel Device Manager...
Nov  9 16:30:30 debian8 systemd[1]: Started Load Kernel Modules.
Nov  9 16:30:30 debian8 systemd[1]: Mounting FUSE Control File System...
Nov  9 16:30:30 debian8 systemd[1]: Starting Apply Kernel Variables...
Nov  9 16:30:30 debian8 systemd[1]: Mounted Configuration File System.
Nov  9 16:30:30 debian8 systemd[1]: Mounted FUSE Control File System.
Nov  9 16:30:30 debian8 systemd[1]: Started udev Kernel Device Manager.
Nov  9 16:30:30 debian8 systemd[1]: Starting Copy rules generated while the=
 root was ro...
Nov  9 16:30:30 debian8 systemd[1]: Starting LSB: MD array assembly...
Nov  9 16:30:30 debian8 systemd[1]: Starting LSB: Set preliminary keymap...
Nov  9 16:30:30 debian8 systemd[1]: Started Apply Kernel Variables.
Nov  9 16:30:30 debian8 systemd[1]: Started Copy rules generated while the =
root was ro.
Nov  9 16:30:30 debian8 mdadm-raid[247]: Generating udev events for MD arra=
ys...done.
Nov  9 16:30:30 debian8 systemd[1]: Started LSB: MD array assembly.
Nov  9 16:30:30 debian8 keyboard-setup[248]: Setting preliminary keymap...d=
one.
Nov  9 16:30:30 debian8 systemd[1]: Started LSB: Set preliminary keymap.
Nov  9 16:30:30 debian8 systemd[1]: Starting Remount Root and Kernel File S=
ystems...
Nov  9 16:30:30 debian8 systemd[1]: Started Remount Root and Kernel File Sy=
stems.
Nov  9 16:30:30 debian8 systemd[1]: Started Various fixups to make systemd =
work better on Debian.
Nov  9 16:30:30 debian8 systemd[1]: Starting Load/Save Random Seed...
Nov  9 16:30:30 debian8 systemd[1]: Starting Local File Systems (Pre).
Nov  9 16:30:30 debian8 systemd[1]: Reached target Local File Systems (Pre).
Nov  9 16:30:30 debian8 systemd[1]: Started Load/Save Random Seed.
Nov  9 16:30:30 debian8 mtp-probe: checking bus 3, device 3: "/sys/devices/=
pci0000:00/0000:00:14.0/usb3/3-4"
Nov  9 16:30:30 debian8 mtp-probe: checking bus 3, device 4: "/sys/devices/=
pci0000:00/0000:00:14.0/usb3/3-5"
Nov  9 16:30:30 debian8 mtp-probe: checking bus 3, device 5: "/sys/devices/=
pci0000:00/0000:00:14.0/usb3/3-6"
Nov  9 16:30:30 debian8 kernel: [    0.000000] Linux version 4.8.6+ (sguino=
t@debian8) (gcc version 4.9.2 (Debian 4.9.2-10) ) #2 SMP Mon Nov 7 18:52:35=
 CET 2016
Nov  9 16:30:30 debian8 kernel: [    0.000000] Command line: BOOT_IMAGE=3D/=
boot/vmlinuz-4.8.6+ root=3DUUID=3D6e1b0503-9be7-40ef-8da7-ef7e35297f58 ro c=
onsole=3DttyS1,115200n8
Nov  9 16:30:30 debian8 mtp-probe: bus: 3, device: 4 was not an MTP device
Nov  9 16:30:30 debian8 kernel: [    0.000000] x86/fpu: Supporting XSAVE fe=
ature 0x001: 'x87 floating point registers'
Nov  9 16:30:30 debian8 kernel: [    0.000000] x86/fpu: Supporting XSAVE fe=
ature 0x002: 'SSE registers'
Nov  9 16:30:30 debian8 kernel: [    0.000000] x86/fpu: Supporting XSAVE fe=
ature 0x004: 'AVX registers'
Nov  9 16:30:30 debian8 kernel: [    0.000000] x86/fpu: xstate_offset[2]:  =
576, xstate_sizes[2]:  256
Nov  9 16:30:30 debian8 mtp-probe: bus: 3, device: 5 was not an MTP device
Nov  9 16:30:30 debian8 kernel: [    0.000000] x86/fpu: Enabled xstate feat=
ures 0x7, context size is 832 bytes, using 'standard' format.
Nov  9 16:30:30 debian8 kernel: [    0.000000] x86/fpu: Using 'eager' FPU c=
ontext switches.
Nov  9 16:30:30 debian8 kernel: [    0.000000] e820: BIOS-provided physical=
 RAM map:
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x0000000000=
000000-0x0000000000057fff] usable
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x0000000000=
058000-0x0000000000058fff] reserved
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x0000000000=
059000-0x000000000009efff] usable
Nov  9 16:30:30 debian8 mtp-probe: bus: 3, device: 3 was not an MTP device
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x0000000000=
09f000-0x000000000009ffff] reserved
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x0000000000=
100000-0x000000003508dfff] usable
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x0000000035=
08e000-0x0000000035094fff] ACPI NVS
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x0000000035=
095000-0x00000000354ecfff] usable
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x0000000035=
4ed000-0x0000000035960fff] reserved
Nov  9 16:30:30 debian8 systemd[1]: Found device ST1000DM003-9YN162 1.
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x0000000035=
961000-0x00000000486c4fff] usable
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x0000000048=
6c5000-0x00000000488cdfff] reserved
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x0000000048=
8ce000-0x00000000488e6fff] ACPI data
Nov  9 16:30:30 debian8 systemd[1]: Starting File System Check on /dev/disk=
/by-uuid/057B-B280...
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x0000000048=
8e7000-0x0000000048e2cfff] ACPI NVS
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x0000000048=
e2d000-0x0000000049f48fff] reserved
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x0000000049=
f49000-0x0000000049ffefff] type 20
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x0000000049=
fff000-0x0000000049ffffff] usable
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x000000004b=
000000-0x000000004f1fffff] reserved
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x00000000e0=
000000-0x00000000efffffff] reserved
Nov  9 16:30:30 debian8 systemd[1]: Found device ST1000DM003-9YN162 4.
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x00000000fe=
c00000-0x00000000fec00fff] reserved
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x00000000fe=
d00000-0x00000000fed03fff] reserved
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x00000000fe=
d1c000-0x00000000fed1ffff] reserved
Nov  9 16:30:30 debian8 systemd[1]: Starting File System Check on /dev/disk=
/by-uuid/39f58bf3-20a1-4c5d-8c38-7804598f1b07...
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x00000000fe=
e00000-0x00000000fee00fff] reserved
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x00000000ff=
000000-0x00000000ffffffff] reserved
Nov  9 16:30:30 debian8 kernel: [    0.000000] BIOS-e820: [mem 0x0000000100=
000000-0x00000001afdfffff] usable
Nov  9 16:30:30 debian8 systemd[1]: Found device ST1000DM003-9YN162 3.
Nov  9 16:30:30 debian8 systemd[1]: Found device ST1000DM003-9YN162 3.
Nov  9 16:30:30 debian8 systemd[1]: Activating swap Swap Partition...
Nov  9 16:30:30 debian8 systemd[1]: Activating swap /dev/disk/by-uuid/e37ef=
c6f-badb-45c0-8854-f115567dc8fc...
Nov  9 16:30:30 debian8 systemd[1]: Activated swap Swap Partition.
Nov  9 16:30:30 debian8 systemd[1]: Activated swap /dev/disk/by-uuid/e37efc=
6f-badb-45c0-8854-f115567dc8fc.
Nov  9 16:30:30 debian8 kernel: [    0.000000] NX (Execute Disable) protect=
ion: active
Nov  9 16:30:30 debian8 systemd[1]: Starting Swap.
Nov  9 16:30:30 debian8 kernel: [    0.000000] efi: EFI v2.31 by American M=
egatrends
Nov  9 16:30:30 debian8 kernel: [    0.000000] efi:  ESRT=3D0x49f47818  ACP=
I=3D0x488d3000  ACPI 2.0=3D0x488d3000  SMBIOS=3D0xf04c0  MPS=3D0xfd4f0=20
Nov  9 16:30:30 debian8 kernel: [    0.000000] esrt: Reserving ESRT space f=
rom 0x0000000049f47818 to 0x0000000049f47850.
Nov  9 16:30:30 debian8 kernel: [    0.000000] SMBIOS 2.7 present.
Nov  9 16:30:30 debian8 kernel: [    0.000000] DMI: ASUS All Series/Z87-DEL=
UXE/QUAD, BIOS 2103 08/18/2014
Nov  9 16:30:30 debian8 kernel: [    0.000000] e820: update [mem 0x00000000=
-0x00000fff] usable =3D=3D> reserved
Nov  9 16:30:30 debian8 kernel: [    0.000000] e820: remove [mem 0x000a0000=
-0x000fffff] usable
Nov  9 16:30:30 debian8 kernel: [    0.000000] e820: last_pfn =3D 0x1afe00 =
max_arch_pfn =3D 0x400000000
Nov  9 16:30:30 debian8 kernel: [    0.000000] MTRR default type: uncachable
Nov  9 16:30:30 debian8 kernel: [    0.000000] MTRR fixed ranges enabled:
Nov  9 16:30:30 debian8 kernel: [    0.000000]   00000-9FFFF write-back
Nov  9 16:30:30 debian8 kernel: [    0.000000]   A0000-BFFFF uncachable
Nov  9 16:30:30 debian8 kernel: [    0.000000]   C0000-CFFFF write-protect
Nov  9 16:30:30 debian8 systemd[1]: Reached target Swap.
Nov  9 16:30:30 debian8 kernel: [    0.000000]   D0000-DFFFF uncachable
Nov  9 16:30:30 debian8 kernel: [    0.000000]   E0000-FFFFF write-protect
Nov  9 16:30:30 debian8 kernel: [    0.000000] MTRR variable ranges enabled:
Nov  9 16:30:30 debian8 kernel: [    0.000000]   0 base 0000000000 mask 7F0=
0000000 write-back
Nov  9 16:30:30 debian8 kernel: [    0.000000]   1 base 0100000000 mask 7F8=
0000000 write-back
Nov  9 16:30:30 debian8 kernel: [    0.000000]   2 base 0180000000 mask 7FC=
0000000 write-back
Nov  9 16:30:30 debian8 systemd-fsck[388]: /dev/sda4: clean, 119435/6014566=
4 files, 7633198/240576768 blocks
Nov  9 16:30:30 debian8 systemd[1]: Started File System Check on /dev/disk/=
by-uuid/39f58bf3-20a1-4c5d-8c38-7804598f1b07.
Nov  9 16:30:30 debian8 kernel: [    0.000000]   3 base 0080000000 mask 7F8=
0000000 uncachable
Nov  9 16:30:30 debian8 kernel: [    0.000000]   4 base 0060000000 mask 7FE=
0000000 uncachable
Nov  9 16:30:30 debian8 kernel: [    0.000000]   5 base 0050000000 mask 7FF=
0000000 uncachable
Nov  9 16:30:30 debian8 kernel: [    0.000000]   6 base 004C000000 mask 7FF=
C000000 uncachable
Nov  9 16:30:30 debian8 systemd[1]: Mounting /home...
Nov  9 16:30:30 debian8 kernel: [    0.000000]   7 base 004B000000 mask 7FF=
F000000 uncachable
Nov  9 16:30:30 debian8 kernel: [    0.000000]   8 base 01B0000000 mask 7FF=
0000000 uncachable
Nov  9 16:30:30 debian8 kernel: [    0.000000]   9 base 01AFE00000 mask 7FF=
FE00000 uncachable
Nov  9 16:30:30 debian8 systemd[1]: Mounted /home.
Nov  9 16:30:30 debian8 kernel: [    0.000000] x86/PAT: Configuration [0-7]=
: WB  WC  UC- UC  WB  WC  UC- WT =20
Nov  9 16:30:30 debian8 kernel: [    0.000000] e820: update [mem 0x4b000000=
-0xffffffff] usable =3D=3D> reserved
Nov  9 16:30:30 debian8 kernel: [    0.000000] e820: last_pfn =3D 0x4a000 m=
ax_arch_pfn =3D 0x400000000
Nov  9 16:30:30 debian8 kernel: [    0.000000] found SMP MP-table at [mem 0=
x000fd800-0x000fd80f] mapped at [ffff9882400fd800]
Nov  9 16:30:30 debian8 systemd[1]: Starting system-systemd\x2drfkill.slice.
Nov  9 16:30:30 debian8 kernel: [    0.000000] Base memory trampoline at [f=
fff988240097000] 97000 size 24576
Nov  9 16:30:30 debian8 kernel: [    0.000000] Using GB pages for direct ma=
pping
Nov  9 16:30:30 debian8 kernel: [    0.000000] BRK [0x181960000, 0x181960ff=
f] PGTABLE
Nov  9 16:30:30 debian8 systemd[1]: Created slice system-systemd\x2drfkill.=
slice.
Nov  9 16:30:30 debian8 kernel: [    0.000000] BRK [0x181961000, 0x181961ff=
f] PGTABLE
Nov  9 16:30:30 debian8 kernel: [    0.000000] BRK [0x181962000, 0x181962ff=
f] PGTABLE
Nov  9 16:30:30 debian8 kernel: [    0.000000] BRK [0x181963000, 0x181963ff=
f] PGTABLE
Nov  9 16:30:30 debian8 kernel: [    0.000000] BRK [0x181964000, 0x181964ff=
f] PGTABLE
Nov  9 16:30:30 debian8 kernel: [    0.000000] BRK [0x181965000, 0x181965ff=
f] PGTABLE
Nov  9 16:30:30 debian8 kernel: [    0.000000] BRK [0x181966000, 0x181966ff=
f] PGTABLE
Nov  9 16:30:30 debian8 kernel: [    0.000000] BRK [0x181967000, 0x181967ff=
f] PGTABLE
Nov  9 16:30:30 debian8 systemd[1]: Starting Load/Save RF Kill Switch Statu=
s of rfkill0...
Nov  9 16:30:30 debian8 kernel: [    0.000000] BRK [0x181968000, 0x181968ff=
f] PGTABLE
Nov  9 16:30:30 debian8 kernel: [    0.000000] BRK [0x181969000, 0x181969ff=
f] PGTABLE
Nov  9 16:30:30 debian8 kernel: [    0.000000] BRK [0x18196a000, 0x18196aff=
f] PGTABLE
Nov  9 16:30:30 debian8 kernel: [    0.000000] RAMDISK: [mem 0x17560000-0x2=
2fcffff]
Nov  9 16:30:30 debian8 systemd[1]: Mounted Configuration File System.
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: Early table checksum v=
erification disabled
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: RSDP 0x00000000488D300=
0 000024 (v02 ALASKA)
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: XSDT 0x00000000488D308=
0 00007C (v01 ALASKA A M I    01072009 AMI  00010013)
Nov  9 16:30:30 debian8 systemd[1]: Started Set Up Additional Binary Format=
s.
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: FACP 0x00000000488E187=
8 00010C (v05 ALASKA A M I    01072009 AMI  00010013)
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: DSDT 0x00000000488D319=
8 00E6DC (v02 ALASKA A M I    00000031 INTL 20091112)
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: FACS 0x0000000048E2B08=
0 000040
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: APIC 0x00000000488E198=
8 000092 (v03 ALASKA A M I    01072009 AMI  00010013)
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: FPDT 0x00000000488E1A2=
0 000044 (v01 ALASKA A M I    01072009 AMI  00010013)
Nov  9 16:30:30 debian8 systemd[1]: Started Various fixups to make systemd =
work better on Debian.
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: LPIT 0x00000000488E1A6=
8 00005C (v01 ALASKA A M I    00000000 AMI. 00000005)
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: SSDT 0x00000000488E1AC=
8 000539 (v01 PmRef  Cpu0Ist  00003000 INTL 20091112)
Nov  9 16:30:30 debian8 systemd[1]: Started File System Check on Root Devic=
e.
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: SSDT 0x00000000488E200=
8 000AD8 (v01 PmRef  CpuPm    00003000 INTL 20091112)
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: MCFG 0x00000000488E2AE=
0 00003C (v01 ALASKA A M I    01072009 MSFT 00000097)
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: HPET 0x00000000488E2B2=
0 000038 (v01 ALASKA A M I    01072009 AMI. 00000005)
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: SSDT 0x00000000488E2B5=
8 00036D (v01 SataRe SataTabl 00001000 INTL 20091112)
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: SSDT 0x00000000488E2EC=
8 0034E1 (v01 SaSsdt SaSsdt   00003000 INTL 20091112)
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: BGRT 0x00000000488E640=
8 000038 (v00 ALASKA A M I    01072009 AMI  00010013)
Nov  9 16:30:30 debian8 systemd-fsck[374]: fsck.fat 3.0.27 (2014-11-12)
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: Local APIC address 0xf=
ee00000
Nov  9 16:30:30 debian8 kernel: [    0.000000] No NUMA configuration found
Nov  9 16:30:30 debian8 kernel: [    0.000000] Faking a node at [mem 0x0000=
000000000000-0x00000001afdfffff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] NODE_DATA(0) allocated [mem =
0x1afdfb000-0x1afdfffff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] Zone ranges:
Nov  9 16:30:30 debian8 kernel: [    0.000000]   DMA      [mem 0x0000000000=
001000-0x0000000000ffffff]
Nov  9 16:30:30 debian8 systemd-fsck[374]: /dev/sda1: 9 files, 69/130812 cl=
usters
Nov  9 16:30:30 debian8 kernel: [    0.000000]   DMA32    [mem 0x0000000001=
000000-0x00000000ffffffff]
Nov  9 16:30:30 debian8 kernel: [    0.000000]   Normal   [mem 0x0000000100=
000000-0x00000001afdfffff]
Nov  9 16:30:30 debian8 kernel: [    0.000000]   Device   empty
Nov  9 16:30:30 debian8 systemd[1]: Started File System Check on /dev/disk/=
by-uuid/057B-B280.
Nov  9 16:30:30 debian8 kernel: [    0.000000] Movable zone start for each =
node
Nov  9 16:30:30 debian8 kernel: [    0.000000] Early memory node ranges
Nov  9 16:30:30 debian8 kernel: [    0.000000]   node   0: [mem 0x000000000=
0001000-0x0000000000057fff]
Nov  9 16:30:30 debian8 kernel: [    0.000000]   node   0: [mem 0x000000000=
0059000-0x000000000009efff]
Nov  9 16:30:30 debian8 systemd[1]: Mounting /boot/efi...
Nov  9 16:30:30 debian8 kernel: [    0.000000]   node   0: [mem 0x000000000=
0100000-0x000000003508dfff]
Nov  9 16:30:30 debian8 kernel: [    0.000000]   node   0: [mem 0x000000003=
5095000-0x00000000354ecfff]
Nov  9 16:30:30 debian8 kernel: [    0.000000]   node   0: [mem 0x000000003=
5961000-0x00000000486c4fff]
Nov  9 16:30:30 debian8 systemd[1]: Started Load/Save RF Kill Switch Status=
 of rfkill0.
Nov  9 16:30:30 debian8 kernel: [    0.000000]   node   0: [mem 0x000000004=
9fff000-0x0000000049ffffff]
Nov  9 16:30:30 debian8 systemd[1]: Starting Sound Card.
Nov  9 16:30:30 debian8 systemd[1]: Reached target Sound Card.
Nov  9 16:30:30 debian8 systemd[1]: Mounted /boot/efi.
Nov  9 16:30:30 debian8 systemd[1]: Starting Local File Systems.
Nov  9 16:30:30 debian8 systemd[1]: Reached target Local File Systems.
Nov  9 16:30:30 debian8 systemd[1]: Starting Create Volatile Files and Dire=
ctories...
Nov  9 16:30:30 debian8 systemd[1]: Starting Remote File Systems.
Nov  9 16:30:30 debian8 systemd[1]: Reached target Remote File Systems.
Nov  9 16:30:30 debian8 systemd[1]: Starting Trigger Flushing of Journal to=
 Persistent Storage...
Nov  9 16:30:30 debian8 systemd[1]: Starting LSB: Prepare console...
Nov  9 16:30:30 debian8 systemd[1]: Starting LSB: Raise network interfaces.=
=2E..
Nov  9 16:30:30 debian8 systemd[1]: Started Trigger Flushing of Journal to =
Persistent Storage.
Nov  9 16:30:30 debian8 systemd[1]: Started Create Volatile Files and Direc=
tories.
Nov  9 16:30:30 debian8 systemd[1]: Starting Update UTMP about System Boot/=
Shutdown...
Nov  9 16:30:30 debian8 kbd[428]: Setting console screen modes.
Nov  9 16:30:30 debian8 networking[429]: Configuring network interfaces.../=
etc/network/interfaces:11: too few parameters for iface line
Nov  9 16:30:30 debian8 networking[429]: ifquery: couldn't read interfaces =
file "/etc/network/interfaces"
Nov  9 16:30:30 debian8 systemd[1]: Started LSB: Raise network interfaces..
Nov  9 16:30:30 debian8 networking[429]: /etc/network/interfaces:11: too fe=
w parameters for iface line
Nov  9 16:30:30 debian8 kernel: [    0.000000]   node   0: [mem 0x000000010=
0000000-0x00000001afdfffff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] Initmem setup node 0 [mem 0x=
0000000000001000-0x00000001afdfffff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] On node 0 totalpages: 1015784
Nov  9 16:30:30 debian8 networking[429]: ifquery: couldn't read interfaces =
file "/etc/network/interfaces"
Nov  9 16:30:30 debian8 kernel: [    0.000000]   DMA zone: 64 pages used fo=
r memmap
Nov  9 16:30:30 debian8 kernel: [    0.000000]   DMA zone: 26 pages reserved
Nov  9 16:30:30 debian8 networking[429]: /etc/network/interfaces:11: too fe=
w parameters for iface line
Nov  9 16:30:30 debian8 kernel: [    0.000000]   DMA zone: 3997 pages, LIFO=
 batch:0
Nov  9 16:30:30 debian8 kernel: [    0.000000]   DMA32 zone: 4554 pages use=
d for memmap
Nov  9 16:30:30 debian8 kernel: [    0.000000]   DMA32 zone: 291403 pages, =
LIFO batch:31
Nov  9 16:30:30 debian8 kernel: [    0.000000]   Normal zone: 11256 pages u=
sed for memmap
Nov  9 16:30:30 debian8 kernel: [    0.000000]   Normal zone: 720384 pages,=
 LIFO batch:31
Nov  9 16:30:30 debian8 networking[429]: ifup: couldn't read interfaces fil=
e "/etc/network/interfaces"
Nov  9 16:30:30 debian8 kernel: [    0.000000] Reserving Intel graphics mem=
ory at 0x000000004b200000-0x000000004f1fffff
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: PM-Timer IO Port: 0x18=
08
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: Local APIC address 0xf=
ee00000
Nov  9 16:30:30 debian8 networking[429]: failed.
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: LAPIC_NMI (acpi_id[0xf=
f] high edge lint[0x1])
Nov  9 16:30:30 debian8 kernel: [    0.000000] IOAPIC[0]: apic_id 8, versio=
n 32, address 0xfec00000, GSI 0-23
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus=
_irq 0 global_irq 2 dfl dfl)
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus=
_irq 9 global_irq 9 high level)
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: IRQ0 used by override.
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: IRQ9 used by override.
Nov  9 16:30:30 debian8 systemd[1]: Starting Network.
Nov  9 16:30:30 debian8 kernel: [    0.000000] Using ACPI (MADT) for SMP co=
nfiguration information
Nov  9 16:30:30 debian8 kernel: [    0.000000] ACPI: HPET id: 0x8086a701 ba=
se: 0xfed00000
Nov  9 16:30:30 debian8 kernel: [    0.000000] smpboot: Allowing 8 CPUs, 0 =
hotplug CPUs
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0x00000000-0x00000fff]
Nov  9 16:30:30 debian8 systemd[1]: Reached target Network.
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0x00058000-0x00058fff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0x0009f000-0x0009ffff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0x000a0000-0x000fffff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0x3508e000-0x35094fff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0x354ed000-0x35960fff]
Nov  9 16:30:30 debian8 systemd[1]: Starting Network is Online.
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0x486c5000-0x488cdfff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0x488ce000-0x488e6fff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0x488e7000-0x48e2cfff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0x48e2d000-0x49f48fff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0x49f49000-0x49ffefff]
Nov  9 16:30:30 debian8 systemd[1]: Reached target Network is Online.
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0x4a000000-0x4affffff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0x4b000000-0x4f1fffff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0x4f200000-0xdfffffff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0xe0000000-0xefffffff]
Nov  9 16:30:30 debian8 systemd[1]: Starting LSB: RPC portmapper replacemen=
t...
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0xf0000000-0xfebfffff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0xfec00000-0xfec00fff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0xfec01000-0xfecfffff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0xfed00000-0xfed03fff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0xfed04000-0xfed1bfff]
Nov  9 16:30:30 debian8 systemd[1]: Started Update UTMP about System Boot/S=
hutdown.
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0xfed1c000-0xfed1ffff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0xfed20000-0xfedfffff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0xfee00000-0xfee00fff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0xfee01000-0xfeffffff]
Nov  9 16:30:30 debian8 kernel: [    0.000000] PM: Registered nosave memory=
: [mem 0xff000000-0xffffffff]
Nov  9 16:30:30 debian8 kbd[428]: setterm: $TERM is not defined.
Nov  9 16:30:30 debian8 kernel: [    0.000000] e820: [mem 0x4f200000-0xdfff=
ffff] available for PCI devices
Nov  9 16:30:30 debian8 kernel: [    0.000000] Booting paravirtualized kern=
el on bare hardware
Nov  9 16:30:30 debian8 kernel: [    0.000000] clocksource: refined-jiffies=
: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns
Nov  9 16:30:30 debian8 systemd[1]: Started LSB: Prepare console.
Nov  9 16:30:30 debian8 kernel: [    0.000000] setup_percpu: NR_CPUS:512 nr=
_cpumask_bits:512 nr_cpu_ids:8 nr_node_ids:1
Nov  9 16:30:30 debian8 kernel: [    0.000000] percpu: Embedded 35 pages/cp=
u @ffff9883efa00000 s104792 r8192 d30376 u262144
Nov  9 16:30:30 debian8 kernel: [    0.000000] pcpu-alloc: s104792 r8192 d3=
0376 u262144 alloc=3D1*2097152
Nov  9 16:30:30 debian8 kernel: [    0.000000] pcpu-alloc: [0] 0 1 2 3 4 5 =
6 7=20
Nov  9 16:30:30 debian8 kernel: [    0.000000] Built 1 zonelists in Node or=
der, mobility grouping on.  Total pages: 999884
Nov  9 16:30:30 debian8 kernel: [    0.000000] Policy zone: Normal
Nov  9 16:30:30 debian8 systemd[1]: Starting LSB: Set console font and keym=
ap...
Nov  9 16:30:30 debian8 kernel: [    0.000000] Kernel command line: BOOT_IM=
AGE=3D/boot/vmlinuz-4.8.6+ root=3DUUID=3D6e1b0503-9be7-40ef-8da7-ef7e35297f=
58 ro console=3DttyS1,115200n8
Nov  9 16:30:30 debian8 kernel: [    0.000000] PID hash table entries: 4096=
 (order: 3, 32768 bytes)
Nov  9 16:30:30 debian8 kernel: [    0.000000] Calgary: detecting Calgary v=
ia BIOS EBDA area
Nov  9 16:30:30 debian8 kernel: [    0.000000] Calgary: Unable to locate Ri=
o Grande table in EBDA - bailing!
Nov  9 16:30:30 debian8 rpcbind[467]: Starting rpcbind daemon....
Nov  9 16:30:30 debian8 kernel: [    0.000000] Memory: 3499716K/4063136K av=
ailable (6083K kernel code, 1232K rwdata, 2776K rodata, 1376K init, 808K bs=
s, 563420K reserved, 0K cma-reserved)
Nov  9 16:30:30 debian8 kernel: [    0.000000] Hierarchical RCU implementat=
ion.
Nov  9 16:30:30 debian8 kernel: [    0.000000] 	Build-time adjustment of le=
af fanout to 64.
Nov  9 16:30:30 debian8 systemd[1]: Started LSB: RPC portmapper replacement.
Nov  9 16:30:30 debian8 kernel: [    0.000000] 	RCU restricting CPUs from N=
R_CPUS=3D512 to nr_cpu_ids=3D8.
Nov  9 16:30:30 debian8 kernel: [    0.000000] RCU: Adjusting geometry for =
rcu_fanout_leaf=3D64, nr_cpu_ids=3D8
Nov  9 16:30:30 debian8 kernel: [    0.000000] NR_IRQS:33024 nr_irqs:488 16
Nov  9 16:30:30 debian8 kernel: [    0.000000] Console: colour dummy device=
 80x25
Nov  9 16:30:30 debian8 systemd[1]: Starting RPC Port Mapper.
Nov  9 16:30:30 debian8 kernel: [    0.000000] console [ttyS1] enabled
Nov  9 16:30:30 debian8 kernel: [    0.000000] clocksource: hpet: mask: 0xf=
fffffff max_cycles: 0xffffffff, max_idle_ns: 133484882848 ns
Nov  9 16:30:30 debian8 kernel: [    0.000000] hpet clockevent registered
Nov  9 16:30:30 debian8 systemd[1]: Reached target RPC Port Mapper.
Nov  9 16:30:30 debian8 kernel: [    0.000000] tsc: Fast TSC calibration us=
ing PIT
Nov  9 16:30:30 debian8 kernel: [    0.000000] tsc: Detected 3398.200 MHz p=
rocessor
Nov  9 16:30:30 debian8 kernel: [    0.000017] Calibrating delay loop (skip=
ped), value calculated using timer frequency.. 6796.40 BogoMIPS (lpj=3D1359=
2800)
Nov  9 16:30:30 debian8 kernel: [    0.000404] pid_max: default: 32768 mini=
mum: 301
Nov  9 16:30:30 debian8 kernel: [    0.000582] ACPI: Core revision 20160422
Nov  9 16:30:30 debian8 kernel: [    0.008302] ACPI: 5 ACPI AML tables succ=
essfully acquired and loaded
Nov  9 16:30:30 debian8 systemd[1]: Starting LSB: NFS support files common =
to client and server...
Nov  9 16:30:30 debian8 kernel: [    0.008537]=20
Nov  9 16:30:30 debian8 kernel: [    0.009185] Security Framework initializ=
ed
Nov  9 16:30:30 debian8 kernel: [    0.009335] Yama: becoming mindful.
Nov  9 16:30:30 debian8 kernel: [    0.009467] AppArmor: AppArmor disabled =
by boot time parameter
Nov  9 16:30:30 debian8 console-setup[472]: Setting up console font and key=
map...done.
Nov  9 16:30:30 debian8 kernel: [    0.009813] Dentry cache hash table entr=
ies: 524288 (order: 10, 4194304 bytes)
Nov  9 16:30:30 debian8 kernel: [    0.010979] Inode-cache hash table entri=
es: 262144 (order: 9, 2097152 bytes)
Nov  9 16:30:30 debian8 kernel: [    0.011653] Mount-cache hash table entri=
es: 8192 (order: 4, 65536 bytes)
Nov  9 16:30:30 debian8 systemd[1]: Started LSB: Set console font and keyma=
p.
Nov  9 16:30:30 debian8 kernel: [    0.011894] Mountpoint-cache hash table =
entries: 8192 (order: 4, 65536 bytes)
Nov  9 16:30:30 debian8 kernel: [    0.012346] CPU: Physical Processor ID: 0
Nov  9 16:30:30 debian8 kernel: [    0.012492] CPU: Processor Core ID: 0
Nov  9 16:30:30 debian8 kernel: [    0.012629] ENERGY_PERF_BIAS: Set to 'no=
rmal', was 'performance'
Nov  9 16:30:30 debian8 kernel: [    0.012844] ENERGY_PERF_BIAS: View and u=
pdate with x86_energy_perf_policy(8)
Nov  9 16:30:30 debian8 rpc.statd[541]: Version 1.2.8 starting
Nov  9 16:30:30 debian8 kernel: [    0.013098] mce: CPU supports 9 MCE banks
Nov  9 16:30:30 debian8 kernel: [    0.013250] CPU0: Thermal monitoring ena=
bled (TM1)
Nov  9 16:30:30 debian8 kernel: [    0.013434] process: using mwait in idle=
 threads
Nov  9 16:30:30 debian8 sm-notify[542]: Version 1.2.8 starting
Nov  9 16:30:30 debian8 kernel: [    0.013603] Last level iTLB entries: 4KB=
 1024, 2MB 1024, 4MB 1024
Nov  9 16:30:30 debian8 kernel: [    0.013822] Last level dTLB entries: 4KB=
 1024, 2MB 1024, 4MB 1024, 1GB 4
Nov  9 16:30:30 debian8 kernel: [    0.014300] Freeing SMP alternatives mem=
ory: 24K (ffffffffba28e000 - ffffffffba294000)
Nov  9 16:30:30 debian8 kernel: [    0.022238] ftrace: allocating 24996 ent=
ries in 98 pages
Nov  9 16:30:30 debian8 kernel: [    0.028985] smpboot: APIC(0) Converting =
physical 0 to logical package 0
Nov  9 16:30:30 debian8 nfs-common[535]: Starting NFS common utilities: sta=
td idmapd.
Nov  9 16:30:30 debian8 kernel: [    0.029223] smpboot: Max logical package=
s: 2
Nov  9 16:30:30 debian8 kernel: [    0.029443] x2apic: IRQ remapping doesn'=
t support X2APIC mode
Nov  9 16:30:30 debian8 kernel: [    0.030047] ..TIMER: vector=3D0x30 apic1=
=3D0 pin1=3D2 apic2=3D-1 pin2=3D-1
Nov  9 16:30:30 debian8 systemd[1]: Started LSB: NFS support files common t=
o client and server.
Nov  9 16:30:30 debian8 kernel: [    0.069946] TSC deadline timer enabled
Nov  9 16:30:30 debian8 kernel: [    0.069948] smpboot: CPU0: Intel(R) Core=
(TM) i7-4770 CPU @ 3.40GHz (family: 0x6, model: 0x3c, stepping: 0x3)
Nov  9 16:30:30 debian8 kernel: [    0.070317] Performance Events: PEBS fmt=
2+, Haswell events, 16-deep LBR, full-width counters, Intel PMU driver.
Nov  9 16:30:30 debian8 kernel: [    0.070721] ... version:                3
Nov  9 16:30:30 debian8 kernel: [    0.070867] ... bit width:              =
48
Nov  9 16:30:30 debian8 kernel: [    0.071016] ... generic registers:      4
Nov  9 16:30:30 debian8 kernel: [    0.071161] ... value mask:             =
0000ffffffffffff
Nov  9 16:30:30 debian8 kernel: [    0.071352] ... max period:             =
0000ffffffffffff
Nov  9 16:30:30 debian8 kernel: [    0.071543] ... fixed-purpose events:   3
Nov  9 16:30:30 debian8 kernel: [    0.071689] ... event mask:             =
000000070000000f
Nov  9 16:30:30 debian8 kernel: [    0.072295] NMI watchdog: enabled on all=
 CPUs, permanently consumes one hw-PMU counter.
Nov  9 16:30:30 debian8 kernel: [    0.072649] x86: Booting SMP configurati=
on:
Nov  9 16:30:30 debian8 kernel: [    0.072801] .... node  #0, CPUs:      #1=
 #2 #3 #4 #5 #6 #7
Nov  9 16:30:30 debian8 systemd[1]: Starting System Initialization.
Nov  9 16:30:30 debian8 kernel: [    0.632101] x86: Booted up 1 node, 8 CPUs
Nov  9 16:30:30 debian8 kernel: [    0.632262] smpboot: Total of 8 processo=
rs activated (54378.36 BogoMIPS)
Nov  9 16:30:30 debian8 kernel: [    0.654844] devtmpfs: initialized
Nov  9 16:30:30 debian8 kernel: [    0.655011] x86/mm: Memory block size: 1=
28MB
Nov  9 16:30:30 debian8 systemd[1]: Reached target System Initialization.
Nov  9 16:30:30 debian8 systemd[1]: Starting Avahi mDNS/DNS-SD Stack Activa=
tion Socket.
Nov  9 16:30:30 debian8 systemd[1]: Listening on Avahi mDNS/DNS-SD Stack Ac=
tivation Socket.
Nov  9 16:30:30 debian8 systemd[1]: Starting D-Bus System Message Bus Socke=
t.
Nov  9 16:30:30 debian8 systemd[1]: Listening on D-Bus System Message Bus S=
ocket.
Nov  9 16:30:30 debian8 systemd[1]: Starting ACPID Listen Socket.
Nov  9 16:30:30 debian8 systemd[1]: Listening on ACPID Listen Socket.
Nov  9 16:30:30 debian8 systemd[1]: Starting ACPI Events Check.
Nov  9 16:30:30 debian8 systemd[1]: Started ACPI Events Check.
Nov  9 16:30:30 debian8 systemd[1]: Starting CUPS Printing Service Sockets.
Nov  9 16:30:30 debian8 systemd[1]: Listening on CUPS Printing Service Sock=
ets.
Nov  9 16:30:30 debian8 systemd[1]: Starting Sockets.
Nov  9 16:30:30 debian8 systemd[1]: Reached target Sockets.
Nov  9 16:30:30 debian8 systemd[1]: Starting Daily Cleanup of Temporary Dir=
ectories.
Nov  9 16:30:30 debian8 systemd[1]: Started Daily Cleanup of Temporary Dire=
ctories.
Nov  9 16:30:30 debian8 systemd[1]: Starting Timers.
Nov  9 16:30:30 debian8 systemd[1]: Reached target Timers.
Nov  9 16:30:30 debian8 systemd[1]: Started Manage Sound Card State (restor=
e and store).
Nov  9 16:30:30 debian8 systemd[1]: Starting Restore Sound Card State...
Nov  9 16:30:30 debian8 kernel: [    0.670815] PM: Registering ACPI NVS reg=
ion [mem 0x3508e000-0x35094fff] (28672 bytes)
Nov  9 16:30:30 debian8 systemd[1]: Starting CUPS Printer Service Spool.
Nov  9 16:30:30 debian8 kernel: [    0.671095] PM: Registering ACPI NVS reg=
ion [mem 0x488e7000-0x48e2cfff] (5529600 bytes)
Nov  9 16:30:30 debian8 kernel: [    0.671493] clocksource: jiffies: mask: =
0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
Nov  9 16:30:30 debian8 kernel: [    0.686807] pinctrl core: initialized pi=
nctrl subsystem
Nov  9 16:30:30 debian8 kernel: [    0.702866] NET: Registered protocol fam=
ily 16
Nov  9 16:30:30 debian8 systemd[1]: Started CUPS Printer Service Spool.
Nov  9 16:30:30 debian8 kernel: [    0.718816] cpuidle: using governor ladd=
er
Nov  9 16:30:30 debian8 kernel: [    0.734824] cpuidle: using governor menu
Nov  9 16:30:30 debian8 systemd[1]: Starting Paths.
Nov  9 16:30:30 debian8 kernel: [    0.734981] ACPI FADT declares the syste=
m doesn't support PCIe ASPM, so disable it
Nov  9 16:30:30 debian8 kernel: [    0.735251] ACPI: bus type PCI registered
Nov  9 16:30:30 debian8 kernel: [    0.735397] acpiphp: ACPI Hot Plug PCI C=
ontroller Driver version: 0.5
Nov  9 16:30:30 debian8 kernel: [    0.766874] PCI: MMCONFIG for domain 000=
0 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
Nov  9 16:30:30 debian8 systemd[1]: Reached target Paths.
Nov  9 16:30:30 debian8 kernel: [    0.767205] PCI: MMCONFIG at [mem 0xe000=
0000-0xefffffff] reserved in E820
Nov  9 16:30:30 debian8 kernel: [    0.767452] pmd_set_huge: Cannot satisfy=
 [mem 0xe0000000-0xe0200000] with a huge-page mapping due to MTRR override.
Nov  9 16:30:30 debian8 systemd[1]: Starting Basic System.
Nov  9 16:30:30 debian8 kernel: [    0.768004] PCI: Using configuration typ=
e 1 for base access
Nov  9 16:30:30 debian8 kernel: [    0.768239] core: PMU erratum BJ122, BV9=
8, HSD29 worked around, HT is on
Nov  9 16:30:30 debian8 kernel: [    0.768645] mtrr: your CPUs had inconsis=
tent fixed MTRR settings
Nov  9 16:30:30 debian8 kernel: [    0.768861] mtrr: probably your BIOS doe=
s not setup all CPUs.
Nov  9 16:30:30 debian8 kernel: [    0.769066] mtrr: corrected configuratio=
n.
Nov  9 16:30:30 debian8 kernel: [    0.782910] HugeTLB registered 1 GB page=
 size, pre-allocated 0 pages
Nov  9 16:30:30 debian8 systemd[1]: Reached target Basic System.
Nov  9 16:30:30 debian8 kernel: [    0.783138] HugeTLB registered 2 MB page=
 size, pre-allocated 0 pages
Nov  9 16:30:30 debian8 kernel: [    0.830910] ACPI: Added _OSI(Module Devi=
ce)
Nov  9 16:30:30 debian8 systemd[1]: Starting Bluetooth service...
Nov  9 16:30:30 debian8 kernel: [    0.831063] ACPI: Added _OSI(Processor D=
evice)
Nov  9 16:30:30 debian8 kernel: [    0.831224] ACPI: Added _OSI(3.0 _SCP Ex=
tensions)
Nov  9 16:30:30 debian8 kernel: [    0.831395] ACPI: Added _OSI(Processor A=
ggregator Device)
Nov  9 16:30:30 debian8 kernel: [    0.831715] ACPI: Executed 1 blocks of m=
odule-level executable AML code
Nov  9 16:30:30 debian8 kernel: [    0.834727] ACPI: [Firmware Bug]: BIOS _=
OSI(Linux) query ignored
Nov  9 16:30:30 debian8 systemd[1]: Starting Accounts Service...
Nov  9 16:30:30 debian8 kernel: [    0.835611] ACPI: Dynamic OEM Table Load:
Nov  9 16:30:30 debian8 kernel: [    0.835773] ACPI: SSDT 0xFFFF9883EA24F80=
0 0003D3 (v01 PmRef  Cpu0Cst  00003001 INTL 20091112)
Nov  9 16:30:30 debian8 kernel: [    0.836498] ACPI: Dynamic OEM Table Load:
Nov  9 16:30:30 debian8 kernel: [    0.836659] ACPI: SSDT 0xFFFF9883EB0B280=
0 0005AA (v01 PmRef  ApIst    00003000 INTL 20091112)
Nov  9 16:30:30 debian8 systemd[1]: Starting Deferred execution scheduler...
Nov  9 16:30:30 debian8 kernel: [    0.837422] ACPI: Dynamic OEM Table Load:
Nov  9 16:30:30 debian8 kernel: [    0.837582] ACPI: SSDT 0xFFFF9883EA69AA0=
0 000119 (v01 PmRef  ApCst    00003000 INTL 20091112)
Nov  9 16:30:30 debian8 kernel: [    0.839158] ACPI: Interpreter enabled
Nov  9 16:30:30 debian8 systemd[1]: Started Deferred execution scheduler.
Nov  9 16:30:30 debian8 systemd[1]: Starting OpenBSD Secure Shell server...
Nov  9 16:30:30 debian8 kernel: [    0.839308] ACPI: (supports S0 S3 S4 S5)
Nov  9 16:30:30 debian8 kernel: [    0.839451] ACPI: Using IOAPIC for inter=
rupt routing
Nov  9 16:30:30 debian8 kernel: [    0.839647] PCI: Using host bridge windo=
ws from ACPI; if necessary, use "pci=3Dnocrs" and report a bug
Nov  9 16:30:30 debian8 kernel: [    0.845546] ACPI: Power Resource [FN00] =
(off)
Nov  9 16:30:30 debian8 kernel: [    0.845756] ACPI: Power Resource [FN01] =
(off)
Nov  9 16:30:30 debian8 systemd[1]: Started OpenBSD Secure Shell server.
Nov  9 16:30:30 debian8 kernel: [    0.845963] ACPI: Power Resource [FN02] =
(off)
Nov  9 16:30:30 debian8 kernel: [    0.846169] ACPI: Power Resource [FN03] =
(off)
Nov  9 16:30:30 debian8 systemd[1]: Starting Modem Manager...
Nov  9 16:30:30 debian8 kernel: [    0.846375] ACPI: Power Resource [FN04] =
(off)
Nov  9 16:30:30 debian8 kernel: [    0.847093] ACPI: PCI Root Bridge [PCI0]=
 (domain 0000 [bus 00-fe])
Nov  9 16:30:30 debian8 kernel: [    0.847318] acpi PNP0A08:00: _OSC: OS su=
pports [ExtendedConfig ASPM ClockPM Segments MSI]
Nov  9 16:30:30 debian8 kernel: [    0.847762] acpi PNP0A08:00: _OSC: platf=
orm does not support [PCIeHotplug PME]
Nov  9 16:30:30 debian8 kernel: [    0.848108] acpi PNP0A08:00: _OSC: OS no=
w controls [AER PCIeCapability]
Nov  9 16:30:30 debian8 kernel: [    0.848345] acpi PNP0A08:00: FADT indica=
tes ASPM is unsupported, using BIOS configuration
Nov  9 16:30:30 debian8 systemd[1]: Starting Restore /etc/resolv.conf if th=
e system crashed before the ppp link was shut down....
Nov  9 16:30:30 debian8 kernel: [    0.848900] PCI host bridge to bus 0000:=
00
Nov  9 16:30:30 debian8 kernel: [    0.849051] pci_bus 0000:00: root bus re=
source [io  0x0000-0x0cf7 window]
Nov  9 16:30:30 debian8 kernel: [    0.849294] pci_bus 0000:00: root bus re=
source [io  0x0d00-0xffff window]
Nov  9 16:30:30 debian8 systemd[1]: Starting Run anacron jobs...
Nov  9 16:30:30 debian8 kernel: [    0.849537] pci_bus 0000:00: root bus re=
source [mem 0x000a0000-0x000bffff window]
Nov  9 16:30:30 debian8 kernel: [    0.849804] pci_bus 0000:00: root bus re=
source [mem 0x000d0000-0x000d3fff window]
Nov  9 16:30:30 debian8 kernel: [    0.850071] pci_bus 0000:00: root bus re=
source [mem 0x000d4000-0x000d7fff window]
Nov  9 16:30:30 debian8 kernel: [    0.850339] pci_bus 0000:00: root bus re=
source [mem 0x000d8000-0x000dbfff window]
Nov  9 16:30:30 debian8 systemd[1]: Started Run anacron jobs.
Nov  9 16:30:30 debian8 kernel: [    0.850606] pci_bus 0000:00: root bus re=
source [mem 0x000dc000-0x000dffff window]
Nov  9 16:30:30 debian8 kernel: [    0.850873] pci_bus 0000:00: root bus re=
source [mem 0x4f200000-0xfeafffff window]
Nov  9 16:30:30 debian8 kernel: [    0.851143] pci_bus 0000:00: root bus re=
source [bus 00-fe]
Nov  9 16:30:30 debian8 kernel: [    0.851344] pci 0000:00:00.0: [8086:0c00=
] type 00 class 0x060000
Nov  9 16:30:30 debian8 kernel: [    0.851405] pci 0000:00:01.0: [8086:0c01=
] type 01 class 0x060400
Nov  9 16:30:30 debian8 kernel: [    0.851428] pci 0000:00:01.0: PME# suppo=
rted from D0 D3hot D3cold
Nov  9 16:30:30 debian8 systemd[1]: Starting Regular background program pro=
cessing daemon...
Nov  9 16:30:30 debian8 kernel: [    0.851487] pci 0000:00:01.0: System wak=
eup disabled by ACPI
Nov  9 16:30:30 debian8 kernel: [    0.851718] pci 0000:00:02.0: [8086:0412=
] type 00 class 0x030000
Nov  9 16:30:30 debian8 kernel: [    0.851724] pci 0000:00:02.0: reg 0x10: =
[mem 0xde400000-0xde7fffff 64bit]
Nov  9 16:30:30 debian8 anacron[565]: Anacron 2.3 started on 2016-11-09
Nov  9 16:30:30 debian8 kernel: [    0.851728] pci 0000:00:02.0: reg 0x18: =
[mem 0x50000000-0x5fffffff 64bit pref]
Nov  9 16:30:30 debian8 kernel: [    0.851731] pci 0000:00:02.0: reg 0x20: =
[io  0xf000-0xf03f]
Nov  9 16:30:30 debian8 kernel: [    0.851784] pci 0000:00:03.0: [8086:0c0c=
] type 00 class 0x040300
Nov  9 16:30:30 debian8 kernel: [    0.851789] pci 0000:00:03.0: reg 0x10: =
[mem 0xdf134000-0xdf137fff 64bit]
Nov  9 16:30:30 debian8 anacron[565]: Normal exit (0 jobs run)
Nov  9 16:30:30 debian8 kernel: [    0.851861] pci 0000:00:14.0: [8086:8c31=
] type 00 class 0x0c0330
Nov  9 16:30:30 debian8 kernel: [    0.851874] pci 0000:00:14.0: reg 0x10: =
[mem 0xdf120000-0xdf12ffff 64bit]
Nov  9 16:30:30 debian8 kernel: [    0.851922] pci 0000:00:14.0: PME# suppo=
rted from D3hot D3cold
Nov  9 16:30:30 debian8 systemd[1]: Started Regular background program proc=
essing daemon.
Nov  9 16:30:30 debian8 kernel: [    0.851949] pci 0000:00:14.0: System wak=
eup disabled by ACPI
Nov  9 16:30:30 debian8 kernel: [    0.852176] pci 0000:00:16.0: [8086:8c3a=
] type 00 class 0x078000
Nov  9 16:30:30 debian8 kernel: [    0.852189] pci 0000:00:16.0: reg 0x10: =
[mem 0xdf13e000-0xdf13e00f 64bit]
Nov  9 16:30:30 debian8 kernel: [    0.852241] pci 0000:00:16.0: PME# suppo=
rted from D0 D3hot D3cold
Nov  9 16:30:30 debian8 kernel: [    0.852293] pci 0000:00:19.0: [8086:153b=
] type 00 class 0x020000
Nov  9 16:30:30 debian8 kernel: [    0.852304] pci 0000:00:19.0: reg 0x10: =
[mem 0xdf100000-0xdf11ffff]
Nov  9 16:30:30 debian8 kernel: [    0.852310] pci 0000:00:19.0: reg 0x14: =
[mem 0xdf13c000-0xdf13cfff]
Nov  9 16:30:30 debian8 systemd[1]: Starting Network Manager...
Nov  9 16:30:30 debian8 kernel: [    0.852316] pci 0000:00:19.0: reg 0x18: =
[io  0xf060-0xf07f]
Nov  9 16:30:30 debian8 kernel: [    0.852363] pci 0000:00:19.0: PME# suppo=
rted from D0 D3hot D3cold
Nov  9 16:30:30 debian8 kernel: [    0.852389] pci 0000:00:19.0: System wak=
eup disabled by ACPI
Nov  9 16:30:30 debian8 kernel: [    0.852617] pci 0000:00:1a.0: [8086:8c2d=
] type 00 class 0x0c0320
Nov  9 16:30:30 debian8 systemd[1]: Starting /etc/rc.local Compatibility...
Nov  9 16:30:30 debian8 kernel: [    0.852631] pci 0000:00:1a.0: reg 0x10: =
[mem 0xdf13b000-0xdf13b3ff]
Nov  9 16:30:30 debian8 kernel: [    0.852701] pci 0000:00:1a.0: PME# suppo=
rted from D0 D3hot D3cold
Nov  9 16:30:30 debian8 kernel: [    0.852737] pci 0000:00:1a.0: System wak=
eup disabled by ACPI
Nov  9 16:30:30 debian8 systemd[1]: Started getty on tty2-tty6 if dbus and =
logind are not available.
Nov  9 16:30:30 debian8 kernel: [    0.852965] pci 0000:00:1b.0: [8086:8c20=
] type 00 class 0x040300
Nov  9 16:30:30 debian8 kernel: [    0.852977] pci 0000:00:1b.0: reg 0x10: =
[mem 0xdf130000-0xdf133fff 64bit]
Nov  9 16:30:30 debian8 kernel: [    0.853032] pci 0000:00:1b.0: PME# suppo=
rted from D0 D3hot D3cold
Nov  9 16:30:30 debian8 kernel: [    0.853061] pci 0000:00:1b.0: System wak=
eup disabled by ACPI
Nov  9 16:30:30 debian8 systemd[1]: Starting Login Service...
Nov  9 16:30:30 debian8 kernel: [    0.853287] pci 0000:00:1c.0: [8086:8c10=
] type 01 class 0x060400
Nov  9 16:30:30 debian8 kernel: [    0.853337] pci 0000:00:1c.0: PME# suppo=
rted from D0 D3hot D3cold
Nov  9 16:30:30 debian8 kernel: [    0.853388] pci 0000:00:1c.0: System wak=
eup disabled by ACPI
Nov  9 16:30:30 debian8 systemd[1]: Starting LSB: start Samba NetBIOS names=
erver (nmbd)...
Nov  9 16:30:30 debian8 kernel: [    0.853615] pci 0000:00:1c.1: [8086:8c12=
] type 01 class 0x060400
Nov  9 16:30:30 debian8 kernel: [    0.853666] pci 0000:00:1c.1: PME# suppo=
rted from D0 D3hot D3cold
Nov  9 16:30:30 debian8 kernel: [    0.853715] pci 0000:00:1c.1: System wak=
eup disabled by ACPI
Nov  9 16:30:30 debian8 kernel: [    0.853942] pci 0000:00:1c.3: [8086:8c16=
] type 01 class 0x060400
Nov  9 16:30:30 debian8 systemd[1]: Starting LSB: exim Mail Transport Agent=
=2E..
Nov  9 16:30:30 debian8 kernel: [    0.853993] pci 0000:00:1c.3: PME# suppo=
rted from D0 D3hot D3cold
Nov  9 16:30:30 debian8 kernel: [    0.854041] pci 0000:00:1c.3: System wak=
eup disabled by ACPI
Nov  9 16:30:30 debian8 kernel: [    0.854267] pci 0000:00:1c.4: [8086:8c18=
] type 01 class 0x060400
Nov  9 16:30:30 debian8 kernel: [    0.854319] pci 0000:00:1c.4: PME# suppo=
rted from D0 D3hot D3cold
Nov  9 16:30:30 debian8 kernel: [    0.854367] pci 0000:00:1c.4: System wak=
eup disabled by ACPI
Nov  9 16:30:30 debian8 systemd[1]: Starting LSB: daemon to balance interru=
pts for SMP systems...
Nov  9 16:30:30 debian8 kernel: [    0.854599] pci 0000:00:1d.0: [8086:8c26=
] type 00 class 0x0c0320
Nov  9 16:30:30 debian8 kernel: [    0.854613] pci 0000:00:1d.0: reg 0x10: =
[mem 0xdf13a000-0xdf13a3ff]
Nov  9 16:30:30 debian8 kernel: [    0.854682] pci 0000:00:1d.0: PME# suppo=
rted from D0 D3hot D3cold
Nov  9 16:30:30 debian8 kernel: [    0.854718] pci 0000:00:1d.0: System wak=
eup disabled by ACPI
Nov  9 16:30:30 debian8 kernel: [    0.854947] pci 0000:00:1f.0: [8086:8c44=
] type 00 class 0x060100
Nov  9 16:30:30 debian8 systemd[1]: Starting LSB: git-daemon service...
Nov  9 16:30:30 debian8 kernel: [    0.855076] pci 0000:00:1f.3: [8086:8c22=
] type 00 class 0x0c0500
Nov  9 16:30:30 debian8 kernel: [    0.855087] pci 0000:00:1f.3: reg 0x10: =
[mem 0xdf139000-0xdf1390ff 64bit]
Nov  9 16:30:30 debian8 kernel: [    0.855103] pci 0000:00:1f.3: reg 0x20: =
[io  0xf040-0xf05f]
Nov  9 16:30:30 debian8 systemd[1]: Starting LSB: keep memory of all UPnP d=
evices that announced themselves...
Nov  9 16:30:30 debian8 kernel: [    0.855191] pci 0000:01:00.0: [1b21:1242=
] type 00 class 0x0c0330
Nov  9 16:30:30 debian8 kernel: [    0.855205] pci 0000:01:00.0: reg 0x10: =
[mem 0xdf000000-0xdf007fff 64bit]
Nov  9 16:30:30 debian8 kernel: [    0.855275] pci 0000:01:00.0: PME# suppo=
rted from D3hot D3cold
Nov  9 16:30:30 debian8 kernel: [    0.855296] pci 0000:01:00.0: System wak=
eup disabled by ACPI
Nov  9 16:30:30 debian8 systemd[1]: Starting LSB: start Samba daemons for t=
he AD DC...
Nov  9 16:30:30 debian8 kernel: [    0.867182] pci 0000:00:01.0: PCI bridge=
 to [bus 01]
Nov  9 16:30:30 debian8 systemd[1]: Starting LSB: Speech Dispatcher...
Nov  9 16:30:30 debian8 systemd[1]: Starting LSB: Start the GNUstep distrib=
uted object mapper...
Nov  9 16:30:30 debian8 systemd[1]: Starting Avahi mDNS/DNS-SD Stack...
Nov  9 16:30:30 debian8 systemd[1]: Starting D-Bus System Message Bus...
Nov  9 16:30:30 debian8 systemd[1]: Started D-Bus System Message Bus.
Nov  9 16:30:30 debian8 bluetoothd[559]: Bluetooth daemon 5.23
Nov  9 16:30:30 debian8 ModemManager[563]: <info>  ModemManager (version 1.=
4.0) starting in system bus...
Nov  9 16:30:30 debian8 cron[569]: (CRON) INFO (pidfile fd =3D 3)
Nov  9 16:30:30 debian8 cron[569]: (CRON) INFO (Running @reboot jobs)
Nov  9 16:30:30 debian8 speech-dispatcher[580]: speech-dispatcher disabled;=
 edit /etc/default/speech-dispatcher.
Nov  9 16:30:30 debian8 irqbalance[575]: Starting SMP IRQ Balancer: irqbala=
nce.
Nov  9 16:30:30 debian8 gdomap[581]: GNUstep distributed object mapper disa=
bled, see /etc/default/gdomap.
Nov  9 16:30:30 debian8 minissdpd[630]: setsockopt(udp, IP_ADD_MEMBERSHIP)(=
0.0.0.0): No such device
Nov  9 16:30:30 debian8 minissdpd[630]: Failed to add IPv4 multicast member=
ship for interface 0.0.0.0.
Nov  9 16:30:30 debian8 kernel: [    0.867362] pci 0000:00:01.0:   bridge w=
indow [mem 0xdf000000-0xdf0fffff]
Nov  9 16:30:30 debian8 minissdpd[578]: Starting UPnP devices daemon: MiniS=
SDPd.
Nov  9 16:30:30 debian8 kernel: [    0.867408] acpiphp: Slot [1] registered
Nov  9 16:30:30 debian8 git-daemon[651]: Ready to rumble
Nov  9 16:30:30 debian8 kernel: [    0.867554] pci 0000:00:1c.0: PCI bridge=
 to [bus 02]
Nov  9 16:30:30 debian8 kernel: [    0.867787] pci 0000:03:00.0: [1b21:0612=
] type 00 class 0x010601
Nov  9 16:30:30 debian8 kernel: [    0.867803] pci 0000:03:00.0: reg 0x10: =
[io  0xe050-0xe057]
Nov  9 16:30:30 debian8 kernel: [    0.867812] pci 0000:03:00.0: reg 0x14: =
[io  0xe040-0xe043]
Nov  9 16:30:30 debian8 kernel: [    0.867822] pci 0000:03:00.0: reg 0x18: =
[io  0xe030-0xe037]
Nov  9 16:30:30 debian8 avahi-daemon[582]: Found user 'avahi' (UID 106) and=
 group 'avahi' (GID 114).
Nov  9 16:30:30 debian8 kernel: [    0.867831] pci 0000:03:00.0: reg 0x1c: =
[io  0xe020-0xe023]
Nov  9 16:30:30 debian8 kernel: [    0.867841] pci 0000:03:00.0: reg 0x20: =
[io  0xe000-0xe01f]
Nov  9 16:30:30 debian8 avahi-daemon[582]: Successfully dropped root privil=
eges.
Nov  9 16:30:30 debian8 kernel: [    0.867850] pci 0000:03:00.0: reg 0x24: =
[mem 0xdef00000-0xdef001ff]
Nov  9 16:30:30 debian8 kernel: [    0.867927] pci 0000:03:00.0: System wak=
eup disabled by ACPI
Nov  9 16:30:30 debian8 kernel: [    0.879191] pci 0000:00:1c.1: PCI bridge=
 to [bus 03]
Nov  9 16:30:30 debian8 kernel: [    0.879372] pci 0000:00:1c.1:   bridge w=
indow [io  0xe000-0xefff]
Nov  9 16:30:30 debian8 kernel: [    0.879374] pci 0000:00:1c.1:   bridge w=
indow [mem 0xdef00000-0xdeffffff]
Nov  9 16:30:30 debian8 avahi-daemon[582]: avahi-daemon 0.6.31 starting up.
Nov  9 16:30:30 debian8 kernel: [    0.879422] pci 0000:04:00.0: [10b5:8608=
] type 01 class 0x060400
Nov  9 16:30:30 debian8 kernel: [    0.879437] pci 0000:04:00.0: reg 0x10: =
[mem 0xdee00000-0xdee1ffff]
Nov  9 16:30:30 debian8 kernel: [    0.879531] pci 0000:04:00.0: PME# suppo=
rted from D0 D3hot D3cold
Nov  9 16:30:30 debian8 kernel: [    0.891197] pci 0000:00:1c.3: PCI bridge=
 to [bus 04-0c]
Nov  9 16:30:30 debian8 avahi-daemon[582]: Successfully called chroot().
Nov  9 16:30:30 debian8 kernel: [    0.891387] pci 0000:00:1c.3:   bridge w=
indow [io  0xc000-0xdfff]
Nov  9 16:30:30 debian8 kernel: [    0.891389] pci 0000:00:1c.3:   bridge w=
indow [mem 0xde800000-0xdeefffff]
Nov  9 16:30:30 debian8 kernel: [    0.891392] pci 0000:00:1c.3:   bridge w=
indow [mem 0xaa100000-0xaa1fffff 64bit pref]
Nov  9 16:30:30 debian8 kernel: [    0.891475] pci 0000:05:01.0: [10b5:8608=
] type 01 class 0x060400
Nov  9 16:30:30 debian8 avahi-daemon[582]: Successfully dropped remaining c=
apabilities.
Nov  9 16:30:30 debian8 kernel: [    0.891581] pci 0000:05:01.0: PME# suppo=
rted from D0 D3hot D3cold
Nov  9 16:30:30 debian8 kernel: [    0.891646] pci 0000:05:04.0: [10b5:8608=
] type 01 class 0x060400
Nov  9 16:30:30 debian8 kernel: [    0.891751] pci 0000:05:04.0: PME# suppo=
rted from D0 D3hot D3cold
Nov  9 16:30:30 debian8 kernel: [    0.891813] pci 0000:05:05.0: [10b5:8608=
] type 01 class 0x060400
Nov  9 16:30:30 debian8 kernel: [    0.891918] pci 0000:05:05.0: PME# suppo=
rted from D0 D3hot D3cold
Nov  9 16:30:30 debian8 kernel: [    0.891981] pci 0000:05:06.0: [10b5:8608=
] type 01 class 0x060400
Nov  9 16:30:30 debian8 avahi-daemon[582]: No service file found in /etc/av=
ahi/services.
Nov  9 16:30:30 debian8 kernel: [    0.892086] pci 0000:05:06.0: PME# suppo=
rted from D0 D3hot D3cold
Nov  9 16:30:30 debian8 kernel: [    0.892150] pci 0000:05:07.0: [10b5:8608=
] type 01 class 0x060400
Nov  9 16:30:30 debian8 kernel: [    0.892255] pci 0000:05:07.0: PME# suppo=
rted from D0 D3hot D3cold
Nov  9 16:30:30 debian8 systemd[1]: Started Avahi mDNS/DNS-SD Stack.
Nov  9 16:30:30 debian8 kernel: [    0.892317] pci 0000:05:08.0: [10b5:8608=
] type 01 class 0x060400
Nov  9 16:30:30 debian8 kernel: [    0.892422] pci 0000:05:08.0: PME# suppo=
rted from D0 D3hot D3cold
Nov  9 16:30:30 debian8 kernel: [    0.892484] pci 0000:05:09.0: [10b5:8608=
] type 01 class 0x060400
Nov  9 16:30:30 debian8 kernel: [    0.892588] pci 0000:05:09.0: PME# suppo=
rted from D0 D3hot D3cold
Nov  9 16:30:30 debian8 systemd[1]: Started Bluetooth service.
Nov  9 16:30:30 debian8 kernel: [    0.892664] pci 0000:04:00.0: PCI bridge=
 to [bus 05-0c]
Nov  9 16:30:30 debian8 kernel: [    0.892858] pci 0000:04:00.0:   bridge w=
indow [io  0xc000-0xdfff]
Nov  9 16:30:30 debian8 kernel: [    0.892861] pci 0000:04:00.0:   bridge w=
indow [mem 0xde800000-0xdedfffff]
Nov  9 16:30:30 debian8 kernel: [    0.892866] pci 0000:04:00.0:   bridge w=
indow [mem 0xaa100000-0xaa1fffff 64bit pref]
Nov  9 16:30:30 debian8 kernel: [    0.892904] pci 0000:05:01.0: PCI bridge=
 to [bus 06]
Nov  9 16:30:30 debian8 systemd[1]: Starting Bluetooth.
Nov  9 16:30:30 debian8 kernel: [    0.893133] pci 0000:05:04.0: PCI bridge=
 to [bus 07]
Nov  9 16:30:30 debian8 kernel: [    0.893379] pci 0000:08:00.0: [10ec:8168=
] type 00 class 0x020000
Nov  9 16:30:30 debian8 systemd[1]: Reached target Bluetooth.
Nov  9 16:30:30 debian8 kernel: [    0.893401] pci 0000:08:00.0: reg 0x10: =
[io  0xd000-0xd0ff]
Nov  9 16:30:30 debian8 kernel: [    0.893433] pci 0000:08:00.0: reg 0x18: =
[mem 0xded00000-0xded00fff 64bit]
Nov  9 16:30:30 debian8 kernel: [    0.893453] pci 0000:08:00.0: reg 0x20: =
[mem 0xaa100000-0xaa103fff 64bit pref]
Nov  9 16:30:30 debian8 kernel: [    0.893563] pci 0000:08:00.0: supports D=
1 D2
Nov  9 16:30:30 debian8 kernel: [    0.893564] pci 0000:08:00.0: PME# suppo=
rted from D0 D1 D2 D3hot D3cold
Nov  9 16:30:30 debian8 systemd[1]: Starting System Logging Service...
Nov  9 16:30:30 debian8 kernel: [    0.903211] pci 0000:05:05.0: PCI bridge=
 to [bus 08]
Nov  9 16:30:30 debian8 kernel: [    0.903395] pci 0000:05:05.0:   bridge w=
indow [io  0xd000-0xdfff]
Nov  9 16:30:30 debian8 systemd[1]: Starting Permit User Sessions...
Nov  9 16:30:30 debian8 kernel: [    0.903398] pci 0000:05:05.0:   bridge w=
indow [mem 0xded00000-0xdedfffff]
Nov  9 16:30:30 debian8 kernel: [    0.903403] pci 0000:05:05.0:   bridge w=
indow [mem 0xaa100000-0xaa1fffff 64bit pref]
Nov  9 16:30:30 debian8 kernel: [    0.903443] pci 0000:05:06.0: PCI bridge=
 to [bus 09]
Nov  9 16:30:30 debian8 kernel: [    0.903691] pci 0000:0a:00.0: [14e4:43b1=
] type 00 class 0x028000
Nov  9 16:30:30 debian8 kernel: [    0.903719] pci 0000:0a:00.0: reg 0x10: =
[mem 0xdea00000-0xdea07fff 64bit]
Nov  9 16:30:30 debian8 kernel: [    0.903739] pci 0000:0a:00.0: reg 0x18: =
[mem 0xde800000-0xde9fffff 64bit]
Nov  9 16:30:30 debian8 systemd[1]: Starting ACPI event daemon...
Nov  9 16:30:30 debian8 kernel: [    0.903879] pci 0000:0a:00.0: supports D=
1 D2
Nov  9 16:30:30 debian8 kernel: [    0.903880] pci 0000:0a:00.0: PME# suppo=
rted from D0 D1 D2 D3hot D3cold
Nov  9 16:30:30 debian8 kernel: [    0.915217] pci 0000:05:07.0: PCI bridge=
 to [bus 0a]
Nov  9 16:30:30 debian8 kernel: [    0.915404] pci 0000:05:07.0:   bridge w=
indow [mem 0xde800000-0xdeafffff]
Nov  9 16:30:30 debian8 avahi-daemon[582]: Network interface enumeration co=
mpleted.
Nov  9 16:30:30 debian8 kernel: [    0.915447] pci 0000:05:08.0: PCI bridge=
 to [bus 0b]
Nov  9 16:30:30 debian8 kernel: [    0.915692] pci 0000:0c:00.0: [1b21:0612=
] type 00 class 0x010601
Nov  9 16:30:30 debian8 kernel: [    0.915712] pci 0000:0c:00.0: reg 0x10: =
[io  0xc050-0xc057]
Nov  9 16:30:30 debian8 avahi-daemon[582]: Registering HINFO record with va=
lues 'X86_64'/'LINUX'.
Nov  9 16:30:30 debian8 kernel: [    0.915725] pci 0000:0c:00.0: reg 0x14: =
[io  0xc040-0xc043]
Nov  9 16:30:30 debian8 kernel: [    0.915737] pci 0000:0c:00.0: reg 0x18: =
[io  0xc030-0xc037]
Nov  9 16:30:30 debian8 kernel: [    0.915750] pci 0000:0c:00.0: reg 0x1c: =
[io  0xc020-0xc023]
Nov  9 16:30:30 debian8 kernel: [    0.915762] pci 0000:0c:00.0: reg 0x20: =
[io  0xc000-0xc01f]
Nov  9 16:30:30 debian8 kernel: [    0.915774] pci 0000:0c:00.0: reg 0x24: =
[mem 0xdec00000-0xdec001ff]
Nov  9 16:30:30 debian8 avahi-daemon[582]: Server startup complete. Host na=
me is debian8.local. Local service cookie is 2384464375.
Nov  9 16:30:30 debian8 kernel: [    0.927222] pci 0000:05:09.0: PCI bridge=
 to [bus 0c]
Nov  9 16:30:30 debian8 kernel: [    0.927406] pci 0000:05:09.0:   bridge w=
indow [io  0xc000-0xcfff]
Nov  9 16:30:30 debian8 bluetoothd[559]: Starting SDP server
Nov  9 16:30:30 debian8 kernel: [    0.927409] pci 0000:05:09.0:   bridge w=
indow [mem 0xdec00000-0xdecfffff]
Nov  9 16:30:30 debian8 kernel: [    0.927499] acpiphp: Slot [1-1] register=
ed
Nov  9 16:30:30 debian8 kernel: [    0.927651] pci 0000:00:1c.4: PCI bridge=
 to [bus 0d-77]
Nov  9 16:30:30 debian8 kernel: [    0.927842] pci 0000:00:1c.4:   bridge w=
indow [mem 0xb0000000-0xde0fffff]
Nov  9 16:30:30 debian8 kernel: [    0.927845] pci 0000:00:1c.4:   bridge w=
indow [mem 0x60000000-0xa9ffffff 64bit pref]
Nov  9 16:30:30 debian8 kernel: [    0.928305] ACPI: PCI Interrupt Link [LN=
KA] (IRQs 3 4 5 6 7 10 *11 12 14 15)
Nov  9 16:30:30 debian8 systemd[1]: Started ACPI event daemon.
Nov  9 16:30:30 debian8 kernel: [    0.928663] ACPI: PCI Interrupt Link [LN=
KB] (IRQs 3 *4 5 6 7 10 11 12 14 15)
Nov  9 16:30:30 debian8 kernel: [    0.929019] ACPI: PCI Interrupt Link [LN=
KC] (IRQs 3 4 5 6 7 10 11 12 *14 15)
Nov  9 16:30:30 debian8 kernel: [    0.929374] ACPI: PCI Interrupt Link [LN=
KD] (IRQs 3 4 5 6 7 10 11 12 14 *15)
Nov  9 16:30:30 debian8 kernel: [    0.929729] ACPI: PCI Interrupt Link [LN=
KE] (IRQs 3 4 *5 6 7 10 11 12 14 15)
Nov  9 16:30:30 debian8 systemd[1]: Starting CUPS Printing Service...
Nov  9 16:30:30 debian8 kernel: [    0.930085] ACPI: PCI Interrupt Link [LN=
KF] (IRQs 3 4 5 6 7 *10 11 12 14 15)
Nov  9 16:30:30 debian8 kernel: [    0.930439] ACPI: PCI Interrupt Link [LN=
KG] (IRQs *3 4 5 6 7 10 11 12 14 15)
Nov  9 16:30:30 debian8 kernel: [    0.930794] ACPI: PCI Interrupt Link [LN=
KH] (IRQs 3 4 5 *6 7 10 11 12 14 15)
Nov  9 16:30:30 debian8 systemd[1]: Started CUPS Printing Service.
Nov  9 16:30:30 debian8 kernel: [    0.931338] ACPI: Enabled 6 GPEs in bloc=
k 00 to 3F
Nov  9 16:30:30 debian8 kernel: [    0.931577] vgaarb: setting as boot devi=
ce: PCI:0000:00:02.0
Nov  9 16:30:30 debian8 kernel: [    0.931781] vgaarb: device added: PCI:00=
00:00:02.0,decodes=3Dio+mem,owns=3Dio+mem,locks=3Dnone
Nov  9 16:30:30 debian8 kernel: [    0.932071] vgaarb: loaded
Nov  9 16:30:30 debian8 kernel: [    0.932172] vgaarb: bridge control possi=
ble 0000:00:02.0
Nov  9 16:30:30 debian8 systemd[1]: Starting Make remote CUPS printers avai=
lable locally...
Nov  9 16:30:30 debian8 kernel: [    0.935148] PCI: Using ACPI for IRQ rout=
ing
Nov  9 16:30:30 debian8 kernel: [    0.940190] PCI: pci_cache_line_size set=
 to 64 bytes
Nov  9 16:30:30 debian8 systemd[1]: Started Make remote CUPS printers avail=
able locally.
Nov  9 16:30:30 debian8 kernel: [    0.940251] e820: reserve RAM buffer [me=
m 0x00058000-0x0005ffff]
Nov  9 16:30:30 debian8 kernel: [    0.940252] e820: reserve RAM buffer [me=
m 0x0009f000-0x0009ffff]
Nov  9 16:30:30 debian8 kernel: [    0.940253] e820: reserve RAM buffer [me=
m 0x3508e000-0x37ffffff]
Nov  9 16:30:30 debian8 kernel: [    0.940253] e820: reserve RAM buffer [me=
m 0x354ed000-0x37ffffff]
Nov  9 16:30:30 debian8 kernel: [    0.940254] e820: reserve RAM buffer [me=
m 0x486c5000-0x4bffffff]
Nov  9 16:30:30 debian8 systemd[1]: Started Restore Sound Card State.
Nov  9 16:30:30 debian8 kernel: [    0.940254] e820: reserve RAM buffer [me=
m 0x4a000000-0x4bffffff]
Nov  9 16:30:30 debian8 kernel: [    0.940255] e820: reserve RAM buffer [me=
m 0x1afe00000-0x1afffffff]
Nov  9 16:30:30 debian8 systemd[1]: Started Restore /etc/resolv.conf if the=
 system crashed before the ppp link was shut down..
Nov  9 16:30:30 debian8 kernel: [    0.940344] hpet0: at MMIO 0xfed00000, I=
RQs 2, 8, 0, 0, 0, 0, 0, 0
Nov  9 16:30:30 debian8 kernel: [    0.940623] hpet0: 8 comparators, 64-bit=
 14.318180 MHz counter
Nov  9 16:30:30 debian8 kernel: [    0.942846] clocksource: Switched to clo=
cksource hpet
Nov  9 16:30:30 debian8 kernel: [    0.947004] VFS: Disk quotas dquot_6.6.0
Nov  9 16:30:30 debian8 kernel: [    0.962865] VFS: Dquot-cache hash table =
entries: 512 (order 0, 4096 bytes)
Nov  9 16:30:30 debian8 kernel: [    0.978911] pnp: PnP ACPI init
Nov  9 16:30:30 debian8 kernel: [    0.979074] system 00:00: [mem 0xfed4000=
0-0xfed44fff] has been reserved
Nov  9 16:30:30 debian8 systemd[1]: Started /etc/rc.local Compatibility.
Nov  9 16:30:30 debian8 kernel: [    0.979312] system 00:00: Plug and Play =
ACPI device, IDs PNP0c01 (active)
Nov  9 16:30:30 debian8 kernel: [    0.979425] system 00:01: [io  0x0680-0x=
069f] has been reserved
Nov  9 16:30:30 debian8 kernel: [    0.979638] system 00:01: [io  0xffff] h=
as been reserved
Nov  9 16:30:30 debian8 kernel: [    0.979830] system 00:01: [io  0xffff] h=
as been reserved
Nov  9 16:30:30 debian8 kernel: [    0.980022] system 00:01: [io  0xffff] h=
as been reserved
Nov  9 16:30:30 debian8 systemd[1]: Started LSB: daemon to balance interrup=
ts for SMP systems.
Nov  9 16:30:30 debian8 kernel: [    0.980214] system 00:01: [io  0x1c00-0x=
1cfe] has been reserved
Nov  9 16:30:30 debian8 kernel: [    0.980427] system 00:01: [io  0x1d00-0x=
1dfe] has been reserved
Nov  9 16:30:30 debian8 kernel: [    0.980640] system 00:01: [io  0x1e00-0x=
1efe] has been reserved
Nov  9 16:30:30 debian8 systemd[1]: Started LSB: git-daemon service.
Nov  9 16:30:30 debian8 kernel: [    0.980853] system 00:01: [io  0x1f00-0x=
1ffe] has been reserved
Nov  9 16:30:30 debian8 kernel: [    0.981066] system 00:01: [io  0x1800-0x=
18fe] has been reserved
Nov  9 16:30:30 debian8 kernel: [    0.981279] system 00:01: [io  0x164e-0x=
164f] has been reserved
Nov  9 16:30:30 debian8 kernel: [    0.981492] system 00:01: Plug and Play =
ACPI device, IDs PNP0c02 (active)
Nov  9 16:30:30 debian8 systemd[1]: Started LSB: keep memory of all UPnP de=
vices that announced themselves.
Nov  9 16:30:30 debian8 systemd[1]: Started LSB: Speech Dispatcher.
Nov  9 16:30:30 debian8 systemd[1]: Started LSB: Start the GNUstep distribu=
ted object mapper.
Nov  9 16:30:30 debian8 dbus[586]: [system] Activating via systemd: service=
 name=3D'org.freedesktop.PolicyKit1' unit=3D'polkitd.service'
Nov  9 16:30:30 debian8 dbus[586]: [system] Activating via systemd: service=
 name=3D'org.freedesktop.hostname1' unit=3D'dbus-org.freedesktop.hostname1.=
service'
Nov  9 16:30:30 debian8 bluetoothd[559]: Bluetooth management interface 1.1=
3 initialized
Nov  9 16:30:30 debian8 systemd[1]: Started Permit User Sessions.
Nov  9 16:30:30 debian8 systemd[1]: Started Login Service.
Nov  9 16:30:30 debian8 systemd[1]: Starting Hostname Service...
Nov  9 16:30:30 debian8 systemd[1]: Starting Light Display Manager...
Nov  9 16:30:30 debian8 systemd[1]: Starting Authenticate and Authorize Use=
rs to Run Privileged Tasks...
Nov  9 16:30:30 debian8 systemd[1]: Starting Getty on tty1...
Nov  9 16:30:30 debian8 systemd[1]: Started Getty on tty1.
Nov  9 16:30:30 debian8 kernel: [    0.981508] pnp 00:02: Plug and Play ACP=
I device, IDs PNP0b00 (active)
Nov  9 16:30:30 debian8 systemd[1]: Starting Login Prompts.
Nov  9 16:30:30 debian8 kernel: [    0.981539] system 00:03: [io  0x1854-0x=
1857] has been reserved
Nov  9 16:30:30 debian8 kernel: [    0.981752] system 00:03: Plug and Play =
ACPI device, IDs INT3f0d PNP0c02 (active)
Nov  9 16:30:30 debian8 kernel: [    0.981807] system 00:04: [io  0x0290-0x=
029f] has been reserved
Nov  9 16:30:30 debian8 systemd[1]: Reached target Login Prompts.
Nov  9 16:30:30 debian8 kernel: [    0.982020] system 00:04: Plug and Play =
ACPI device, IDs PNP0c02 (active)
Nov  9 16:30:30 debian8 kernel: [    0.982054] system 00:05: [io  0x04d0-0x=
04d1] has been reserved
Nov  9 16:30:30 debian8 kernel: [    0.982267] system 00:05: Plug and Play =
ACPI device, IDs PNP0c02 (active)
Nov  9 16:30:30 debian8 kernel: [    0.982545] system 00:06: [mem 0xfed1c00=
0-0xfed1ffff] has been reserved
Nov  9 16:30:30 debian8 bluetoothd[559]: Sap driver initialization failed.
Nov  9 16:30:30 debian8 bluetoothd[559]: sap-server: Operation not permitte=
d (1)
Nov  9 16:30:30 debian8 kernel: [    0.982782] system 00:06: [mem 0xfed1000=
0-0xfed17fff] has been reserved
Nov  9 16:30:30 debian8 kernel: [    0.983025] system 00:06: [mem 0xfed1800=
0-0xfed18fff] has been reserved
Nov  9 16:30:30 debian8 kernel: [    0.983264] system 00:06: [mem 0xfed1900=
0-0xfed19fff] has been reserved
Nov  9 16:30:30 debian8 kernel: [    0.983501] system 00:06: [mem 0xe000000=
0-0xefffffff] has been reserved
Nov  9 16:30:30 debian8 acpid: starting up with netlink and the input layer
Nov  9 16:30:30 debian8 kernel: [    0.983739] system 00:06: [mem 0xfed2000=
0-0xfed3ffff] has been reserved
Nov  9 16:30:30 debian8 kernel: [    0.983976] system 00:06: [mem 0xfed9000=
0-0xfed93fff] has been reserved
Nov  9 16:30:30 debian8 kernel: [    0.984213] system 00:06: [mem 0xfed4500=
0-0xfed8ffff] has been reserved
Nov  9 16:30:30 debian8 dbus[586]: [system] Successfully activated service =
'org.freedesktop.hostname1'
Nov  9 16:30:30 debian8 kernel: [    0.984450] system 00:06: [mem 0xff00000=
0-0xffffffff] has been reserved
Nov  9 16:30:30 debian8 kernel: [    0.984687] system 00:06: [mem 0xfee0000=
0-0xfeefffff] could not be reserved
Nov  9 16:30:30 debian8 kernel: [    0.984937] system 00:06: [mem 0xdffdf00=
0-0xdffdffff] has been reserved
Nov  9 16:30:30 debian8 kernel: [    0.985174] system 00:06: [mem 0xdffe000=
0-0xdffeffff] has been reserved
Nov  9 16:30:30 debian8 systemd[1]: Started Hostname Service.
Nov  9 16:30:30 debian8 kernel: [    0.985412] system 00:06: Plug and Play =
ACPI device, IDs PNP0c02 (active)
Nov  9 16:30:30 debian8 kernel: [    0.985554] pnp: PnP ACPI: found 7 devic=
es
Nov  9 16:30:30 debian8 kernel: [    0.991383] clocksource: acpi_pm: mask: =
0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
Nov  9 16:30:30 debian8 kernel: [    0.991780] pci 0000:00:1c.4: bridge win=
dow [io  0x1000-0x0fff] to [bus 0d-77] add_size 1000
Nov  9 16:30:30 debian8 kernel: [    0.991782] pci 0000:00:1c.4: res[13]=3D=
[io  0x1000-0x0fff] res_to_dev_res add_size 1000 min_align 1000
Nov  9 16:30:30 debian8 kernel: [    0.991783] pci 0000:00:1c.4: res[13]=3D=
[io  0x1000-0x1fff] res_to_dev_res add_size 1000 min_align 1000
Nov  9 16:30:30 debian8 kernel: [    0.991785] pci 0000:00:1c.4: BAR 13: as=
signed [io  0x2000-0x2fff]
Nov  9 16:30:30 debian8 acpid: 1 rule loaded
Nov  9 16:30:30 debian8 kernel: [    0.992008] pci 0000:00:01.0: PCI bridge=
 to [bus 01]
Nov  9 16:30:30 debian8 kernel: [    0.992189] pci 0000:00:01.0:   bridge w=
indow [mem 0xdf000000-0xdf0fffff]
Nov  9 16:30:30 debian8 kernel: [    0.992434] pci 0000:00:1c.0: PCI bridge=
 to [bus 02]
Nov  9 16:30:30 debian8 kernel: [    0.992620] pci 0000:00:1c.1: PCI bridge=
 to [bus 03]
Nov  9 16:30:30 debian8 kernel: [    0.992800] pci 0000:00:1c.1:   bridge w=
indow [io  0xe000-0xefff]
Nov  9 16:30:30 debian8 kernel: [    0.993021] pci 0000:00:1c.1:   bridge w=
indow [mem 0xdef00000-0xdeffffff]
Nov  9 16:30:30 debian8 acpid: waiting for events: event logging is off
Nov  9 16:30:30 debian8 kernel: [    0.993269] pci 0000:05:01.0: PCI bridge=
 to [bus 06]
Nov  9 16:30:30 debian8 kernel: [    0.993459] pci 0000:05:04.0: PCI bridge=
 to [bus 07]
Nov  9 16:30:30 debian8 systemd[1]: Started System Logging Service.
Nov  9 16:30:30 debian8 kernel: [    0.993650] pci 0000:05:05.0: PCI bridge=
 to [bus 08]
Nov  9 16:30:30 debian8 kernel: [    0.993831] pci 0000:05:05.0:   bridge w=
indow [io  0xd000-0xdfff]
Nov  9 16:30:30 debian8 kernel: [    0.994054] pci 0000:05:05.0:   bridge w=
indow [mem 0xded00000-0xdedfffff]
Nov  9 16:30:30 debian8 kernel: [    0.994299] pci 0000:05:05.0:   bridge w=
indow [mem 0xaa100000-0xaa1fffff 64bit pref]
Nov  9 16:30:30 debian8 kernel: [    0.994580] pci 0000:05:06.0: PCI bridge=
 to [bus 09]
Nov  9 16:30:30 debian8 kernel: [    0.994771] pci 0000:05:07.0: PCI bridge=
 to [bus 0a]
Nov  9 16:30:30 debian8 kernel: [    0.994957] pci 0000:05:07.0:   bridge w=
indow [mem 0xde800000-0xdeafffff]
Nov  9 16:30:30 debian8 kernel: [    0.995208] pci 0000:05:08.0: PCI bridge=
 to [bus 0b]
Nov  9 16:30:30 debian8 kernel: [    0.995398] pci 0000:05:09.0: PCI bridge=
 to [bus 0c]
Nov  9 16:30:30 debian8 kernel: [    0.995579] pci 0000:05:09.0:   bridge w=
indow [io  0xc000-0xcfff]
Nov  9 16:30:30 debian8 kernel: [    0.995801] pci 0000:05:09.0:   bridge w=
indow [mem 0xdec00000-0xdecfffff]
Nov  9 16:30:30 debian8 kernel: [    0.996051] pci 0000:04:00.0: PCI bridge=
 to [bus 05-0c]
Nov  9 16:30:30 debian8 kernel: [    0.996241] pci 0000:04:00.0:   bridge w=
indow [io  0xc000-0xdfff]
Nov  9 16:30:30 debian8 kernel: [    0.996463] pci 0000:04:00.0:   bridge w=
indow [mem 0xde800000-0xdedfffff]
Nov  9 16:30:30 debian8 kernel: [    0.996708] pci 0000:04:00.0:   bridge w=
indow [mem 0xaa100000-0xaa1fffff 64bit pref]
Nov  9 16:30:30 debian8 kernel: [    0.996990] pci 0000:00:1c.3: PCI bridge=
 to [bus 04-0c]
Nov  9 16:30:30 debian8 kernel: [    0.997179] pci 0000:00:1c.3:   bridge w=
indow [io  0xc000-0xdfff]
Nov  9 16:30:30 debian8 kernel: [    0.997400] pci 0000:00:1c.3:   bridge w=
indow [mem 0xde800000-0xdeefffff]
Nov  9 16:30:30 debian8 kernel: [    0.997644] pci 0000:00:1c.3:   bridge w=
indow [mem 0xaa100000-0xaa1fffff 64bit pref]
Nov  9 16:30:30 debian8 kernel: [    0.997923] pci 0000:00:1c.4: PCI bridge=
 to [bus 0d-77]
Nov  9 16:30:30 debian8 kernel: [    0.998113] pci 0000:00:1c.4:   bridge w=
indow [io  0x2000-0x2fff]
Nov  9 16:30:30 debian8 kernel: [    0.998333] pci 0000:00:1c.4:   bridge w=
indow [mem 0xb0000000-0xde0fffff]
Nov  9 16:30:30 debian8 kernel: [    0.998578] pci 0000:00:1c.4:   bridge w=
indow [mem 0x60000000-0xa9ffffff 64bit pref]
Nov  9 16:30:30 debian8 kernel: [    0.998860] pci_bus 0000:00: resource 4 =
[io  0x0000-0x0cf7 window]
Nov  9 16:30:30 debian8 kernel: [    0.998861] pci_bus 0000:00: resource 5 =
[io  0x0d00-0xffff window]
Nov  9 16:30:30 debian8 kernel: [    0.998862] pci_bus 0000:00: resource 6 =
[mem 0x000a0000-0x000bffff window]
Nov  9 16:30:30 debian8 kernel: [    0.998862] pci_bus 0000:00: resource 7 =
[mem 0x000d0000-0x000d3fff window]
Nov  9 16:30:30 debian8 kernel: [    0.998863] pci_bus 0000:00: resource 8 =
[mem 0x000d4000-0x000d7fff window]
Nov  9 16:30:30 debian8 kernel: [    0.998863] pci_bus 0000:00: resource 9 =
[mem 0x000d8000-0x000dbfff window]
Nov  9 16:30:30 debian8 kernel: [    0.998864] pci_bus 0000:00: resource 10=
 [mem 0x000dc000-0x000dffff window]
Nov  9 16:30:30 debian8 kernel: [    0.998865] pci_bus 0000:00: resource 11=
 [mem 0x4f200000-0xfeafffff window]
Nov  9 16:30:30 debian8 kernel: [    0.998865] pci_bus 0000:01: resource 1 =
[mem 0xdf000000-0xdf0fffff]
Nov  9 16:30:30 debian8 kernel: [    0.998866] pci_bus 0000:03: resource 0 =
[io  0xe000-0xefff]
Nov  9 16:30:30 debian8 kernel: [    0.998867] pci_bus 0000:03: resource 1 =
[mem 0xdef00000-0xdeffffff]
Nov  9 16:30:30 debian8 kernel: [    0.998867] pci_bus 0000:04: resource 0 =
[io  0xc000-0xdfff]
Nov  9 16:30:30 debian8 kernel: [    0.998868] pci_bus 0000:04: resource 1 =
[mem 0xde800000-0xdeefffff]
Nov  9 16:30:30 debian8 kernel: [    0.998869] pci_bus 0000:04: resource 2 =
[mem 0xaa100000-0xaa1fffff 64bit pref]
Nov  9 16:30:30 debian8 kernel: [    0.998869] pci_bus 0000:05: resource 0 =
[io  0xc000-0xdfff]
Nov  9 16:30:30 debian8 kernel: [    0.998870] pci_bus 0000:05: resource 1 =
[mem 0xde800000-0xdedfffff]
Nov  9 16:30:30 debian8 kernel: [    0.998871] pci_bus 0000:05: resource 2 =
[mem 0xaa100000-0xaa1fffff 64bit pref]
Nov  9 16:30:30 debian8 kernel: [    0.998871] pci_bus 0000:08: resource 0 =
[io  0xd000-0xdfff]
Nov  9 16:30:30 debian8 kernel: [    0.998872] pci_bus 0000:08: resource 1 =
[mem 0xded00000-0xdedfffff]
Nov  9 16:30:30 debian8 kernel: [    0.998873] pci_bus 0000:08: resource 2 =
[mem 0xaa100000-0xaa1fffff 64bit pref]
Nov  9 16:30:30 debian8 kernel: [    0.998874] pci_bus 0000:0a: resource 1 =
[mem 0xde800000-0xdeafffff]
Nov  9 16:30:30 debian8 kernel: [    0.998874] pci_bus 0000:0c: resource 0 =
[io  0xc000-0xcfff]
Nov  9 16:30:30 debian8 kernel: [    0.998875] pci_bus 0000:0c: resource 1 =
[mem 0xdec00000-0xdecfffff]
Nov  9 16:30:30 debian8 kernel: [    0.998876] pci_bus 0000:0d: resource 0 =
[io  0x2000-0x2fff]
Nov  9 16:30:30 debian8 kernel: [    0.998876] pci_bus 0000:0d: resource 1 =
[mem 0xb0000000-0xde0fffff]
Nov  9 16:30:30 debian8 kernel: [    0.998877] pci_bus 0000:0d: resource 2 =
[mem 0x60000000-0xa9ffffff 64bit pref]
Nov  9 16:30:30 debian8 kernel: [    1.078856] NET: Registered protocol fam=
ily 2
Nov  9 16:30:30 debian8 kernel: [    1.094888] TCP established hash table e=
ntries: 32768 (order: 6, 262144 bytes)
Nov  9 16:30:30 debian8 kernel: [    1.095209] TCP bind hash table entries:=
 32768 (order: 7, 524288 bytes)
Nov  9 16:30:30 debian8 kernel: [    1.095545] TCP: Hash tables configured =
(established 32768 bind 32768)
Nov  9 16:30:30 debian8 kernel: [    1.095795] UDP hash table entries: 2048=
 (order: 4, 65536 bytes)
Nov  9 16:30:30 debian8 kernel: [    1.096026] UDP-Lite hash table entries:=
 2048 (order: 4, 65536 bytes)
Nov  9 16:30:30 debian8 kernel: [    1.096300] NET: Registered protocol fam=
ily 1
Nov  9 16:30:30 debian8 kernel: [    1.096467] pci 0000:00:02.0: Video devi=
ce with shadowed ROM at [mem 0x000c0000-0x000dffff]
Nov  9 16:30:30 debian8 kernel: [    1.118905] PCI: CLS mismatch (64 !=3D 1=
28), using 64 bytes
Nov  9 16:30:30 debian8 kernel: [    1.139004] Unpacking initramfs...
Nov  9 16:30:30 debian8 kernel: [    3.234304] Freeing initrd memory: 19091=
2K (ffff988257560000 - ffff988262fd0000)
Nov  9 16:30:30 debian8 kernel: [    3.234572] PCI-DMA: Using software boun=
ce buffering for IO (SWIOTLB)
Nov  9 16:30:30 debian8 kernel: [    3.234813] software IO TLB [mem 0x3636d=
000-0x3a36d000] (64MB) mapped at [ffff98827636d000-ffff98827a36cfff]
Nov  9 16:30:30 debian8 kernel: [    3.235255] RAPL PMU: API unit is 2^-32 =
Joules, 4 fixed counters, 655360 ms ovfl timer
Nov  9 16:30:30 debian8 kernel: [    3.235538] RAPL PMU: hw unit of domain =
pp0-core 2^-14 Joules
Nov  9 16:30:30 debian8 kernel: [    3.235744] RAPL PMU: hw unit of domain =
package 2^-14 Joules
Nov  9 16:30:30 debian8 kernel: [    3.235948] RAPL PMU: hw unit of domain =
dram 2^-14 Joules
Nov  9 16:30:30 debian8 kernel: [    3.236142] RAPL PMU: hw unit of domain =
pp1-gpu 2^-14 Joules
Nov  9 16:30:30 debian8 kernel: [    3.236600] simple-framebuffer simple-fr=
amebuffer.0: framebuffer at 0x50000000, 0x300000 bytes, mapped to 0xffffb6f=
e80800000
Nov  9 16:30:30 debian8 kernel: [    3.236999] simple-framebuffer simple-fr=
amebuffer.0: format=3Da8r8g8b8, mode=3D1024x768x32, linelength=3D4096
Nov  9 16:30:30 debian8 kernel: [    3.238424] Console: switching to colour=
 frame buffer device 128x48
Nov  9 16:30:30 debian8 kernel: [    3.239672] simple-framebuffer simple-fr=
amebuffer.0: fb0: simplefb registered!
Nov  9 16:30:30 debian8 kernel: [    3.258871] futex hash table entries: 20=
48 (order: 5, 131072 bytes)
Nov  9 16:30:30 debian8 kernel: [    3.274750] audit: initializing netlink =
subsys (disabled)
Nov  9 16:30:30 debian8 kernel: [    3.274959] audit: type=3D2000 audit(147=
8705418.264:1): initialized
Nov  9 16:30:30 debian8 kernel: [    3.275579] workingset: timestamp_bits=
=3D40 max_order=3D20 bucket_order=3D0
Nov  9 16:30:30 debian8 kernel: [    3.275818] zbud: loaded
Nov  9 16:30:30 debian8 kernel: [    3.513227] Key type asymmetric register=
ed
Nov  9 16:30:30 debian8 kernel: [    3.513377] Asymmetric key parser 'x509'=
 registered
Nov  9 16:30:30 debian8 kernel: [    3.534741] Block layer SCSI generic (bs=
g) driver version 0.4 loaded (major 251)
Nov  9 16:30:30 debian8 kernel: [    3.535034] io scheduler noop registered
Nov  9 16:30:30 debian8 kernel: [    3.535177] io scheduler deadline regist=
ered
Nov  9 16:30:30 debian8 kernel: [    3.535335] io scheduler cfq registered =
(default)
Nov  9 16:30:30 debian8 kernel: [    3.536951] pci_hotplug: PCI Hot Plug PC=
I Core version: 0.5
Nov  9 16:30:30 debian8 kernel: [    3.537154] pciehp: PCI Express Hot Plug=
 Controller Driver version: 0.4
Nov  9 16:30:30 debian8 kernel: [    3.537399] intel_idle: MWAIT substates:=
 0x42120
Nov  9 16:30:30 debian8 kernel: [    3.537399] intel_idle: v0.4.1 model 0x3C
Nov  9 16:30:30 debian8 kernel: [    3.537589] intel_idle: lapic_timer_reli=
able_states 0xffffffff
Nov  9 16:30:30 debian8 kernel: [    3.537720] GHES: HEST is not enabled!
Nov  9 16:30:30 debian8 kernel: [    3.537887] Serial: 8250/16550 driver, 4=
 ports, IRQ sharing enabled
Nov  9 16:30:30 debian8 kernel: [    3.538380] Linux agpgart interface v0.1=
03
Nov  9 16:30:30 debian8 kernel: [    3.538559] AMD IOMMUv2 driver by Joerg =
Roedel <jroedel@suse.de>
Nov  9 16:30:30 debian8 kernel: [    3.538785] AMD IOMMUv2 functionality no=
t available on this system
Nov  9 16:30:30 debian8 kernel: [    3.539366] i8042: PNP: No PS/2 controll=
er found. Probing ports directly.
Nov  9 16:30:30 debian8 kernel: [    3.541968] serio: i8042 KBD port at 0x6=
0,0x64 irq 1
Nov  9 16:30:30 debian8 kernel: [    3.542150] serio: i8042 AUX port at 0x6=
0,0x64 irq 12
Nov  9 16:30:30 debian8 kernel: [    3.542430] mousedev: PS/2 mouse device =
common for all mice
Nov  9 16:30:30 debian8 kernel: [    3.542657] rtc_cmos 00:02: RTC can wake=
 from S4
Nov  9 16:30:30 debian8 kernel: [    3.542934] rtc_cmos 00:02: rtc core: re=
gistered rtc_cmos as rtc0
Nov  9 16:30:30 debian8 kernel: [    3.543172] rtc_cmos 00:02: alarms up to=
 one month, y3k, 242 bytes nvram, hpet irqs
Nov  9 16:30:30 debian8 kernel: [    3.543450] intel_pstate: Intel P-state =
driver initializing
Nov  9 16:30:30 debian8 kernel: [    3.543953] ledtrig-cpu: registered to i=
ndicate activity on CPUs
Nov  9 16:30:30 debian8 kernel: [    3.606773] NET: Registered protocol fam=
ily 10
Nov  9 16:30:30 debian8 kernel: [    3.626798] mip6: Mobile IPv6
Nov  9 16:30:30 debian8 kernel: [    3.626924] NET: Registered protocol fam=
ily 17
Nov  9 16:30:30 debian8 kernel: [    3.627105] mpls_gso: MPLS GSO support
Nov  9 16:30:30 debian8 kernel: [    3.627858] microcode: sig=3D0x306c3, pf=
=3D0x2, revision=3D0x19
Nov  9 16:30:30 debian8 kernel: [    3.628350] microcode: Microcode Update =
Driver: v2.01 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
Nov  9 16:30:30 debian8 kernel: [    3.629196] registered taskstats version=
 1
Nov  9 16:30:30 debian8 kernel: [    3.629393] zswap: loaded using pool lzo=
/zbud
Nov  9 16:30:30 debian8 kernel: [    3.630938] rtc_cmos 00:02: setting syst=
em clock to 2016-11-09 15:30:18 UTC (1478705418)
Nov  9 16:30:30 debian8 kernel: [    3.631359] PM: Hibernation image not pr=
esent or could not be loaded.
Nov  9 16:30:30 debian8 kernel: [    3.632576] Freeing unused kernel memory=
: 1376K (ffffffffba136000 - ffffffffba28e000)
Nov  9 16:30:30 debian8 kernel: [    3.632874] Write protecting the kernel =
read-only data: 10240k
Nov  9 16:30:30 debian8 kernel: [    3.633337] Freeing unused kernel memory=
: 44K (ffff9883c11f5000 - ffff9883c1200000)
Nov  9 16:30:30 debian8 kernel: [    3.637353] Freeing unused kernel memory=
: 1320K (ffff9883c14b6000 - ffff9883c1600000)
Nov  9 16:30:30 debian8 kernel: [    3.645454] x86/mm: Checked W+X mappings=
: passed, no W+X pages found.
Nov  9 16:30:30 debian8 kernel: [    3.653777] random: systemd-udevd: unini=
tialized urandom read (16 bytes read)
Nov  9 16:30:30 debian8 kernel: [    3.659586] FUJITSU Extended Socket Netw=
ork Device Driver - version 1.1 - Copyright (c) 2015 FUJITSU LIMITED
Nov  9 16:30:30 debian8 kernel: [    3.665227] thermal LNXTHERM:00: registe=
red as thermal_zone0
Nov  9 16:30:30 debian8 kernel: [    3.665454] ACPI: Thermal Zone [TZ00] (2=
8 C)
Nov  9 16:30:30 debian8 kernel: [    3.665871] pps_core: LinuxPPS API ver. =
1 registered
Nov  9 16:30:30 debian8 kernel: [    3.665988] thermal LNXTHERM:01: registe=
red as thermal_zone1
Nov  9 16:30:30 debian8 kernel: [    3.665988] ACPI: Thermal Zone [TZ01] (3=
0 C)
Nov  9 16:30:30 debian8 kernel: [    3.666456] pps_core: Software ver. 5.3.=
6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
Nov  9 16:30:30 debian8 kernel: [    3.668256] PTP clock support registered
Nov  9 16:30:30 debian8 kernel: [    3.671405] r8169 Gigabit Ethernet drive=
r 2.3LK-NAPI loaded
Nov  9 16:30:30 debian8 kernel: [    3.672237] r8169 0000:08:00.0: can't di=
sable ASPM; OS doesn't have ASPM control
Nov  9 16:30:30 debian8 kernel: [    3.674776] SCSI subsystem initialized
Nov  9 16:30:30 debian8 kernel: [    3.675759] e1000e: Intel(R) PRO/1000 Ne=
twork Driver - 3.2.6-k
Nov  9 16:30:30 debian8 kernel: [    3.675818] ACPI: bus type USB registered
Nov  9 16:30:30 debian8 kernel: [    3.675863] usbcore: registered new inte=
rface driver usbfs
Nov  9 16:30:30 debian8 kernel: [    3.675878] usbcore: registered new inte=
rface driver hub
Nov  9 16:30:30 debian8 kernel: [    3.675934] usbcore: registered new devi=
ce driver usb
Nov  9 16:30:30 debian8 kernel: [    3.676797] e1000e: Copyright(c) 1999 - =
2015 Intel Corporation.
Nov  9 16:30:30 debian8 kernel: [    3.677493] e1000e 0000:00:19.0: Interru=
pt Throttling Rate (ints/sec) set to dynamic conservative mode
Nov  9 16:30:30 debian8 kernel: [    3.678883] ehci_hcd: USB 2.0 'Enhanced'=
 Host Controller (EHCI) Driver
Nov  9 16:30:30 debian8 kernel: [    3.680305] libata version 3.00 loaded.
Nov  9 16:30:30 debian8 kernel: [    3.680782] ehci-pci: EHCI PCI platform =
driver
Nov  9 16:30:30 debian8 kernel: [    3.681403] ahci 0000:03:00.0: version 3=
=2E0
Nov  9 16:30:30 debian8 kernel: [    3.681531] ahci 0000:03:00.0: SSS flag =
set, parallel bus scan disabled
Nov  9 16:30:30 debian8 kernel: [    3.681830] ahci 0000:03:00.0: AHCI 0001=
=2E0200 32 slots 2 ports 6 Gbps 0x3 impl SATA mode
Nov  9 16:30:30 debian8 kernel: [    3.682156] ahci 0000:03:00.0: flags: 64=
bit ncq sntf stag led clo pmp pio slum part ccc=20
Nov  9 16:30:30 debian8 kernel: [    3.683055] scsi host0: ahci
Nov  9 16:30:30 debian8 kernel: [    3.683267] scsi host1: ahci
Nov  9 16:30:30 debian8 kernel: [    3.683437] ata1: SATA max UDMA/133 abar=
 m512@0xdef00000 port 0xdef00100 irq 34
Nov  9 16:30:30 debian8 kernel: [    3.683732] ata2: SATA max UDMA/133 abar=
 m512@0xdef00000 port 0xdef00180 irq 34
Nov  9 16:30:30 debian8 kernel: [    3.684142] ahci 0000:0c:00.0: SSS flag =
set, parallel bus scan disabled
Nov  9 16:30:30 debian8 kernel: [    3.684457] ahci 0000:0c:00.0: AHCI 0001=
=2E0200 32 slots 2 ports 6 Gbps 0x3 impl SATA mode
Nov  9 16:30:30 debian8 kernel: [    3.684789] ahci 0000:0c:00.0: flags: 64=
bit ncq sntf stag led clo pmp pio slum part ccc=20
Nov  9 16:30:30 debian8 kernel: [    3.685412] scsi host2: ahci
Nov  9 16:30:30 debian8 kernel: [    3.685610] scsi host3: ahci
Nov  9 16:30:30 debian8 kernel: [    3.685763] ata3: SATA max UDMA/133 abar=
 m512@0xdec00000 port 0xdec00100 irq 35
Nov  9 16:30:30 debian8 kernel: [    3.686026] ata4: SATA max UDMA/133 abar=
 m512@0xdec00000 port 0xdec00180 irq 35
Nov  9 16:30:30 debian8 kernel: [    3.691605] r8169 0000:08:00.0 eth0: RTL=
8168g/8111g at 0xffffb6fe8074e000, 00:e0:4c:68:00:3d, XID 0c000800 IRQ 36
Nov  9 16:30:30 debian8 kernel: [    3.691980] r8169 0000:08:00.0 eth0: jum=
bo features [frames: 9200 bytes, tx checksumming: ko]
Nov  9 16:30:30 debian8 kernel: [    3.770626] e1000e 0000:00:19.0 0000:00:=
19.0 (uninitialized): registered PHC clock
Nov  9 16:30:30 debian8 kernel: [    3.859033] e1000e 0000:00:19.0 eth1: (P=
CI Express:2.5GT/s:Width x1) 88:88:88:88:87:88
Nov  9 16:30:30 debian8 kernel: [    3.859327] e1000e 0000:00:19.0 eth1: In=
tel(R) PRO/1000 Network Connection
Nov  9 16:30:30 debian8 kernel: [    3.859617] e1000e 0000:00:19.0 eth1: MA=
C: 11, PHY: 12, PBA No: FFFFFF-0FF
Nov  9 16:30:30 debian8 kernel: [    3.860020] ehci-pci 0000:00:1a.0: EHCI =
Host Controller
Nov  9 16:30:30 debian8 kernel: [    3.860235] ehci-pci 0000:00:1a.0: new U=
SB bus registered, assigned bus number 1
Nov  9 16:30:30 debian8 kernel: [    3.860516] ehci-pci 0000:00:1a.0: debug=
 port 2
Nov  9 16:30:30 debian8 kernel: [    3.864561] ehci-pci 0000:00:1a.0: cache=
 line size of 64 is not supported
Nov  9 16:30:30 debian8 kernel: [    3.864573] ehci-pci 0000:00:1a.0: irq 1=
6, io mem 0xdf13b000
Nov  9 16:30:30 debian8 kernel: [    3.878733] ehci-pci 0000:00:1a.0: USB 2=
=2E0 started, EHCI 1.00
Nov  9 16:30:30 debian8 kernel: [    3.878969] usb usb1: New USB device fou=
nd, idVendor=3D1d6b, idProduct=3D0002
Nov  9 16:30:30 debian8 kernel: [    3.879213] usb usb1: New USB device str=
ings: Mfr=3D3, Product=3D2, SerialNumber=3D1
Nov  9 16:30:30 debian8 kernel: [    3.879472] usb usb1: Product: EHCI Host=
 Controller
Nov  9 16:30:30 debian8 kernel: [    3.879649] usb usb1: Manufacturer: Linu=
x 4.8.6+ ehci_hcd
Nov  9 16:30:30 debian8 kernel: [    3.879844] usb usb1: SerialNumber: 0000=
:00:1a.0
Nov  9 16:30:30 debian8 kernel: [    3.880120] hub 1-0:1.0: USB hub found
Nov  9 16:30:30 debian8 kernel: [    3.880264] hub 1-0:1.0: 2 ports detected
Nov  9 16:30:30 debian8 kernel: [    3.880550] ehci-pci 0000:00:1d.0: EHCI =
Host Controller
Nov  9 16:30:30 debian8 kernel: [    3.880749] ehci-pci 0000:00:1d.0: new U=
SB bus registered, assigned bus number 2
Nov  9 16:30:30 debian8 kernel: [    3.881019] ehci-pci 0000:00:1d.0: debug=
 port 2
Nov  9 16:30:30 debian8 kernel: [    3.885068] ehci-pci 0000:00:1d.0: cache=
 line size of 64 is not supported
Nov  9 16:30:30 debian8 kernel: [    3.885073] ehci-pci 0000:00:1d.0: irq 2=
3, io mem 0xdf13a000
Nov  9 16:30:30 debian8 kernel: [    3.898738] ehci-pci 0000:00:1d.0: USB 2=
=2E0 started, EHCI 1.00
Nov  9 16:30:30 debian8 kernel: [    3.898989] usb usb2: New USB device fou=
nd, idVendor=3D1d6b, idProduct=3D0002
Nov  9 16:30:30 debian8 kernel: [    3.899241] usb usb2: New USB device str=
ings: Mfr=3D3, Product=3D2, SerialNumber=3D1
Nov  9 16:30:30 debian8 kernel: [    3.899508] usb usb2: Product: EHCI Host=
 Controller
Nov  9 16:30:30 debian8 kernel: [    3.899691] usb usb2: Manufacturer: Linu=
x 4.8.6+ ehci_hcd
Nov  9 16:30:30 debian8 kernel: [    3.899896] usb usb2: SerialNumber: 0000=
:00:1d.0
Nov  9 16:30:30 debian8 kernel: [    3.900229] hub 2-0:1.0: USB hub found
Nov  9 16:30:30 debian8 kernel: [    3.900380] hub 2-0:1.0: 2 ports detected
Nov  9 16:30:30 debian8 kernel: [    3.900807] xhci_hcd 0000:00:14.0: xHCI =
Host Controller
Nov  9 16:30:30 debian8 kernel: [    3.901018] xhci_hcd 0000:00:14.0: new U=
SB bus registered, assigned bus number 3
Nov  9 16:30:30 debian8 kernel: [    3.902370] xhci_hcd 0000:00:14.0: hcc p=
arams 0x200077c1 hci version 0x100 quirks 0x00009810
Nov  9 16:30:30 debian8 kernel: [    3.902685] xhci_hcd 0000:00:14.0: cache=
 line size of 64 is not supported
Nov  9 16:30:30 debian8 kernel: [    3.902787] usb usb3: New USB device fou=
nd, idVendor=3D1d6b, idProduct=3D0002
Nov  9 16:30:30 debian8 kernel: [    3.903029] usb usb3: New USB device str=
ings: Mfr=3D3, Product=3D2, SerialNumber=3D1
Nov  9 16:30:30 debian8 kernel: [    3.903287] usb usb3: Product: xHCI Host=
 Controller
Nov  9 16:30:30 debian8 kernel: [    3.903462] usb usb3: Manufacturer: Linu=
x 4.8.6+ xhci-hcd
Nov  9 16:30:30 debian8 kernel: [    3.903656] usb usb3: SerialNumber: 0000=
:00:14.0
Nov  9 16:30:30 debian8 kernel: [    3.903899] hub 3-0:1.0: USB hub found
Nov  9 16:30:30 debian8 kernel: [    3.904053] hub 3-0:1.0: 14 ports detect=
ed
Nov  9 16:30:30 debian8 kernel: [    3.906330] xhci_hcd 0000:00:14.0: xHCI =
Host Controller
Nov  9 16:30:30 debian8 kernel: [    3.906519] xhci_hcd 0000:00:14.0: new U=
SB bus registered, assigned bus number 4
Nov  9 16:30:30 debian8 kernel: [    3.906852] usb usb4: New USB device fou=
nd, idVendor=3D1d6b, idProduct=3D0003
Nov  9 16:30:30 debian8 kernel: [    3.907094] usb usb4: New USB device str=
ings: Mfr=3D3, Product=3D2, SerialNumber=3D1
Nov  9 16:30:30 debian8 kernel: [    3.907350] usb usb4: Product: xHCI Host=
 Controller
Nov  9 16:30:30 debian8 kernel: [    3.907526] usb usb4: Manufacturer: Linu=
x 4.8.6+ xhci-hcd
Nov  9 16:30:30 debian8 kernel: [    3.907719] usb usb4: SerialNumber: 0000=
:00:14.0
Nov  9 16:30:30 debian8 kernel: [    3.907978] hub 4-0:1.0: USB hub found
Nov  9 16:30:30 debian8 kernel: [    3.908127] hub 4-0:1.0: 6 ports detected
Nov  9 16:30:30 debian8 kernel: [    3.909002] xhci_hcd 0000:01:00.0: xHCI =
Host Controller
Nov  9 16:30:30 debian8 kernel: [    3.909191] xhci_hcd 0000:01:00.0: new U=
SB bus registered, assigned bus number 5
Nov  9 16:30:30 debian8 kernel: [    3.968189] xhci_hcd 0000:01:00.0: hcc p=
arams 0x0200eec1 hci version 0x110 quirks 0x00000010
Nov  9 16:30:30 debian8 kernel: [    3.968570] usb usb5: New USB device fou=
nd, idVendor=3D1d6b, idProduct=3D0002
Nov  9 16:30:30 debian8 kernel: [    3.968812] usb usb5: New USB device str=
ings: Mfr=3D3, Product=3D2, SerialNumber=3D1
Nov  9 16:30:30 debian8 kernel: [    3.969068] usb usb5: Product: xHCI Host=
 Controller
Nov  9 16:30:30 debian8 kernel: [    3.969244] usb usb5: Manufacturer: Linu=
x 4.8.6+ xhci-hcd
Nov  9 16:30:30 debian8 kernel: [    3.969437] usb usb5: SerialNumber: 0000=
:01:00.0
Nov  9 16:30:30 debian8 kernel: [    3.969671] hub 5-0:1.0: USB hub found
Nov  9 16:30:30 debian8 kernel: [    3.969814] hub 5-0:1.0: 2 ports detected
Nov  9 16:30:30 debian8 kernel: [    3.970001] xhci_hcd 0000:01:00.0: xHCI =
Host Controller
Nov  9 16:30:30 debian8 kernel: [    3.970189] xhci_hcd 0000:01:00.0: new U=
SB bus registered, assigned bus number 6
Nov  9 16:30:30 debian8 kernel: [    3.970471] usb usb6: We don't know the =
algorithms for LPM for this host, disabling LPM.
Nov  9 16:30:30 debian8 kernel: [    3.970821] usb usb6: New USB device fou=
nd, idVendor=3D1d6b, idProduct=3D0003
Nov  9 16:30:30 debian8 kernel: [    3.971064] usb usb6: New USB device str=
ings: Mfr=3D3, Product=3D2, SerialNumber=3D1
Nov  9 16:30:30 debian8 kernel: [    3.971322] usb usb6: Product: xHCI Host=
 Controller
Nov  9 16:30:30 debian8 kernel: [    3.971498] usb usb6: Manufacturer: Linu=
x 4.8.6+ xhci-hcd
Nov  9 16:30:30 debian8 kernel: [    3.971692] usb usb6: SerialNumber: 0000=
:01:00.0
Nov  9 16:30:30 debian8 kernel: [    3.971935] hub 6-0:1.0: USB hub found
Nov  9 16:30:30 debian8 kernel: [    3.972078] hub 6-0:1.0: 2 ports detected
Nov  9 16:30:30 debian8 kernel: [    3.997177] ata1: SATA link down (SStatu=
s 0 SControl 300)
Nov  9 16:30:30 debian8 kernel: [    4.001038] ata3: SATA link down (SStatu=
s 0 SControl 300)
Nov  9 16:30:30 debian8 kernel: [    4.206721] usb 1-1: new high-speed USB =
device number 2 using ehci-pci
Nov  9 16:30:30 debian8 kernel: [    4.226721] usb 2-1: new high-speed USB =
device number 2 using ehci-pci
Nov  9 16:30:30 debian8 kernel: [    4.230713] usb 3-3: new high-speed USB =
device number 2 using xhci_hcd
Nov  9 16:30:30 debian8 kernel: [    4.258706] tsc: Refined TSC clocksource=
 calibration: 3398.030 MHz
Nov  9 16:30:30 debian8 kernel: [    4.258936] clocksource: tsc: mask: 0xff=
ffffffffffffff max_cycles: 0x30fb0a05005, max_idle_ns: 440795375639 ns
Nov  9 16:30:30 debian8 kernel: [    4.355123] usb 1-1: New USB device foun=
d, idVendor=3D8087, idProduct=3D8008
Nov  9 16:30:30 debian8 kernel: [    4.355401] usb 1-1: New USB device stri=
ngs: Mfr=3D0, Product=3D0, SerialNumber=3D0
Nov  9 16:30:30 debian8 kernel: [    4.356187] hub 1-1:1.0: USB hub found
Nov  9 16:30:30 debian8 kernel: [    4.356437] hub 1-1:1.0: 6 ports detected
Nov  9 16:30:30 debian8 kernel: [    4.375105] usb 2-1: New USB device foun=
d, idVendor=3D8087, idProduct=3D8000
Nov  9 16:30:30 debian8 kernel: [    4.375370] usb 2-1: New USB device stri=
ngs: Mfr=3D0, Product=3D0, SerialNumber=3D0
Nov  9 16:30:30 debian8 kernel: [    4.375986] hub 2-1:1.0: USB hub found
Nov  9 16:30:30 debian8 kernel: [    4.376176] hub 2-1:1.0: 8 ports detected
Nov  9 16:30:30 debian8 kernel: [    4.396467] usb 3-3: New USB device foun=
d, idVendor=3D174c, idProduct=3D2074
Nov  9 16:30:30 debian8 kernel: [    4.396733] usb 3-3: New USB device stri=
ngs: Mfr=3D2, Product=3D3, SerialNumber=3D0
Nov  9 16:30:30 debian8 kernel: [    4.397012] usb 3-3: Product: ASM107x
Nov  9 16:30:30 debian8 kernel: [    4.397158] usb 3-3: Manufacturer: ASUS =
Tek.
Nov  9 16:30:30 debian8 kernel: [    4.397808] hub 3-3:1.0: USB hub found
Nov  9 16:30:30 debian8 kernel: [    4.398131] hub 3-3:1.0: 4 ports detected
Nov  9 16:30:30 debian8 kernel: [    4.470758] ata2: SATA link up 6.0 Gbps =
(SStatus 133 SControl 300)
Nov  9 16:30:30 debian8 kernel: [    4.471614] ata2.00: ATA-8: ST1000DM003-=
9YN162, CC4B, max UDMA/133
Nov  9 16:30:30 debian8 kernel: [    4.471841] ata2.00: 1953525168 sectors,=
 multi 16: LBA48 NCQ (depth 31/32), AA
Nov  9 16:30:30 debian8 kernel: [    4.472663] ata2.00: configured for UDMA=
/133
Nov  9 16:30:30 debian8 kernel: [    4.473007] scsi 1:0:0:0: Direct-Access =
    ATA      ST1000DM003-9YN1 CC4B PQ: 0 ANSI: 5
Nov  9 16:30:30 debian8 kernel: [    4.511825] sd 1:0:0:0: [sda] 1953525168=
 512-byte logical blocks: (1.00 TB/932 GiB)
Nov  9 16:30:30 debian8 kernel: [    4.512112] sd 1:0:0:0: [sda] 4096-byte =
physical blocks
Nov  9 16:30:30 debian8 kernel: [    4.512349] sd 1:0:0:0: [sda] Write Prot=
ect is off
Nov  9 16:30:30 debian8 kernel: [    4.512524] sd 1:0:0:0: [sda] Mode Sense=
: 00 3a 00 00
Nov  9 16:30:30 debian8 kernel: [    4.512539] sd 1:0:0:0: [sda] Write cach=
e: enabled, read cache: enabled, doesn't support DPO or FUA
Nov  9 16:30:30 debian8 kernel: [    4.526503] usb 4-3: new SuperSpeed USB =
device number 2 using xhci_hcd
Nov  9 16:30:30 debian8 kernel: [    4.551263]  sda: sda1 sda2 sda3 sda4
Nov  9 16:30:30 debian8 kernel: [    4.551900] sd 1:0:0:0: [sda] Attached S=
CSI disk
Nov  9 16:30:30 debian8 kernel: [    4.654059] usb 4-3: New USB device foun=
d, idVendor=3D174c, idProduct=3D3074
Nov  9 16:30:30 debian8 kernel: [    4.654302] usb 4-3: New USB device stri=
ngs: Mfr=3D2, Product=3D3, SerialNumber=3D0
Nov  9 16:30:30 debian8 kernel: [    4.654558] usb 4-3: Product: ASM107x
Nov  9 16:30:30 debian8 kernel: [    4.654698] usb 4-3: Manufacturer: ASUS =
Tek.
Nov  9 16:30:30 debian8 kernel: [    4.710725] usb 3-4: new full-speed USB =
device number 3 using xhci_hcd
Nov  9 16:30:30 debian8 kernel: [    4.714554] hub 4-3:1.0: USB hub found
Nov  9 16:30:30 debian8 kernel: [    4.726679] hub 4-3:1.0: 4 ports detected
Nov  9 16:30:30 debian8 kernel: [    4.825816] ata4: SATA link down (SStatu=
s 0 SControl 300)
Nov  9 16:30:30 debian8 kernel: [    4.827420] sd 1:0:0:0: Attached scsi ge=
neric sg0 type 0
Nov  9 16:30:30 debian8 kernel: [    4.857032] usb 3-4: New USB device foun=
d, idVendor=3D0b05, idProduct=3D17cf
Nov  9 16:30:30 debian8 kernel: [    4.857283] usb 3-4: New USB device stri=
ngs: Mfr=3D1, Product=3D2, SerialNumber=3D3
Nov  9 16:30:30 debian8 kernel: [    4.857549] usb 3-4: Product: BCM20702A0
Nov  9 16:30:30 debian8 kernel: [    4.857698] usb 3-4: Manufacturer: Broad=
com Corp
Nov  9 16:30:30 debian8 kernel: [    4.857872] usb 3-4: SerialNumber: 6C71D=
9497B00
Nov  9 16:30:30 debian8 kernel: [    4.978662] usb 3-5: new low-speed USB d=
evice number 4 using xhci_hcd
Nov  9 16:30:30 debian8 kernel: [    4.992660] random: fast init done
Nov  9 16:30:30 debian8 kernel: [    5.124224] usb 3-5: New USB device foun=
d, idVendor=3D04b3, idProduct=3D3025
Nov  9 16:30:30 debian8 kernel: [    5.124467] usb 3-5: New USB device stri=
ngs: Mfr=3D1, Product=3D2, SerialNumber=3D0
Nov  9 16:30:30 debian8 kernel: [    5.124723] usb 3-5: Product: USB NetVis=
ta Full Width Keyboard
Nov  9 16:30:30 debian8 kernel: [    5.124934] usb 3-5: Manufacturer: CHICO=
NY
Nov  9 16:30:30 debian8 kernel: [    5.126552] hidraw: raw HID events drive=
r (C) Jiri Kosina
Nov  9 16:30:30 debian8 kernel: [    5.129361] usbcore: registered new inte=
rface driver usbhid
Nov  9 16:30:30 debian8 kernel: [    5.129569] usbhid: USB HID core driver
Nov  9 16:30:30 debian8 kernel: [    5.130092] input: CHICONY USB NetVista =
Full Width Keyboard as /devices/pci0000:00/0000:00:14.0/usb3/3-5/3-5:1.0/00=
03:04B3:3025.0001/input/input3
Nov  9 16:30:30 debian8 kernel: [    5.186794] hid-generic 0003:04B3:3025.0=
001: input,hidraw0: USB HID v1.10 Keyboard [CHICONY USB NetVista Full Width=
 Keyboard] on usb-0000:00:14.0-5/input0
Nov  9 16:30:30 debian8 kernel: [    5.195652] PM: Starting manual resume f=
rom disk
Nov  9 16:30:30 debian8 kernel: [    5.195825] PM: Hibernation image partit=
ion 8:3 present
Nov  9 16:30:30 debian8 kernel: [    5.195825] PM: Looking for hibernation =
image.
Nov  9 16:30:30 debian8 kernel: [    5.196068] PM: Image not found (code -2=
2)
Nov  9 16:30:30 debian8 kernel: [    5.196069] PM: Hibernation image not pr=
esent or could not be loaded.
Nov  9 16:30:30 debian8 kernel: [    5.242671] usb 3-6: new low-speed USB d=
evice number 5 using xhci_hcd
Nov  9 16:30:30 debian8 kernel: [    5.282874] clocksource: Switched to clo=
cksource tsc
Nov  9 16:30:30 debian8 kernel: [    5.386118] usb 3-6: New USB device foun=
d, idVendor=3D17ef, idProduct=3D6019
Nov  9 16:30:30 debian8 kernel: [    5.386387] usb 3-6: New USB device stri=
ngs: Mfr=3D0, Product=3D2, SerialNumber=3D0
Nov  9 16:30:30 debian8 kernel: [    5.386701] usb 3-6: Product: Lenovo Opt=
ical USB Mouse
Nov  9 16:30:30 debian8 kernel: [    5.390458] input: Lenovo Optical USB Mo=
use as /devices/pci0000:00/0000:00:14.0/usb3/3-6/3-6:1.0/0003:17EF:6019.000=
2/input/input4
Nov  9 16:30:30 debian8 kernel: [    5.391071] hid-generic 0003:17EF:6019.0=
002: input,hidraw1: USB HID v1.11 Mouse [Lenovo Optical USB Mouse] on usb-0=
000:00:14.0-6/input0
Nov  9 16:30:30 debian8 kernel: [    5.538686] EXT4-fs (sda2): mounted file=
system with ordered data mode. Opts: (null)
Nov  9 16:30:30 debian8 kernel: [    7.085908] lp: driver loaded but no dev=
ices found
Nov  9 16:30:30 debian8 kernel: [    7.175486] ppdev: user-space parallel p=
ort driver
Nov  9 16:30:30 debian8 kernel: [    7.253918] fuse init (API version 7.25)
Nov  9 16:30:30 debian8 kernel: [    7.799453] random: crng init done
Nov  9 16:30:30 debian8 kernel: [    8.205477] input: Power Button as /devi=
ces/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input5
Nov  9 16:30:30 debian8 kernel: [    8.205785] ACPI: Power Button [PWRB]
Nov  9 16:30:30 debian8 kernel: [    8.205966] input: Power Button as /devi=
ces/LNXSYSTM:00/LNXPWRBN:00/input/input6
Nov  9 16:30:30 debian8 kernel: [    8.206235] ACPI: Power Button [PWRF]
Nov  9 16:30:30 debian8 kernel: [    8.276995] wmi: Mapper loaded
Nov  9 16:30:30 debian8 kernel: [    8.299164] EFI Variables Facility v0.08=
 2004-May-17
Nov  9 16:30:30 debian8 kernel: [    8.303729] pstore: using zlib compressi=
on
Nov  9 16:30:30 debian8 kernel: [    8.303882] pstore: Registered efi as pe=
rsistent store backend
Nov  9 16:30:30 debian8 kernel: [    8.539759] EXT4-fs (sda2): re-mounted. =
Opts: errors=3Dremount-ro
Nov  9 16:30:30 debian8 kernel: [    8.552815] e1000e 0000:00:19.0 eth4: re=
named from eth1
Nov  9 16:30:30 debian8 kernel: [    8.619147] i801_smbus 0000:00:1f.3: SMB=
us using PCI interrupt
Nov  9 16:30:30 debian8 kernel: [    8.798750] input: PC Speaker as /device=
s/platform/pcspkr/input/input7
Nov  9 16:30:30 debian8 kernel: [    8.994456] [drm] Initialized drm 1.1.0 =
20060810
Nov  9 16:30:30 debian8 kernel: [    9.114052] shpchp: Standard Hot Plug PC=
I Controller Driver version: 0.4
Nov  9 16:30:30 debian8 kernel: [    9.205423] asus_wmi: ASUS WMI generic d=
river loaded
Nov  9 16:30:30 debian8 kernel: [    9.303106] iTCO_vendor_support: vendor-=
support=3D0
Nov  9 16:30:30 debian8 kernel: [    9.426361] asus_wmi: Initialization: 0x0
Nov  9 16:30:30 debian8 kernel: [    9.426532] asus_wmi: BIOS WMI version: =
0.9
Nov  9 16:30:30 debian8 kernel: [    9.426707] asus_wmi: SFUN value: 0x0
Nov  9 16:30:30 debian8 kernel: [    9.427063] input: Eee PC WMI hotkeys as=
 /devices/platform/eeepc-wmi/input/input8
Nov  9 16:30:30 debian8 kernel: [    9.427396] asus_wmi: Number of fans: 1
Nov  9 16:30:30 debian8 kernel: [    9.597077] iTCO_wdt: Intel TCO WatchDog=
 Timer Driver v1.11
Nov  9 16:30:30 debian8 kernel: [    9.597311] iTCO_wdt: Found a Lynx Point=
 TCO device (Version=3D2, TCOBASE=3D0x1860)
Nov  9 16:30:30 debian8 kernel: [    9.597635] iTCO_wdt: initialized. heart=
beat=3D30 sec (nowayout=3D0)
Nov  9 16:30:30 debian8 kernel: [    9.648510] r8169 0000:08:00.0 eth5: ren=
amed from eth0
Nov  9 16:30:30 debian8 kernel: [    9.651479] AVX2 version of gcm_enc/dec =
engaged.
Nov  9 16:30:30 debian8 kernel: [    9.651648] AES CTR mode by8 optimizatio=
n enabled
Nov  9 16:30:30 debian8 kernel: [    9.886501] [drm] Memory usable by graph=
ics device =3D 2048M
Nov  9 16:30:30 debian8 kernel: [    9.886705] checking generic (50000000 3=
00000) vs hw (50000000 10000000)
Nov  9 16:30:30 debian8 kernel: [    9.886706] fb: switching to inteldrmfb =
=66rom simple
Nov  9 16:30:30 debian8 kernel: [    9.886907] Console: switching to colour=
 dummy device 80x25
Nov  9 16:30:30 debian8 kernel: [    9.887168] [drm] Replacing VGA console =
driver
Nov  9 16:30:30 debian8 kernel: [    9.893574] [drm] Supports vblank timest=
amp caching Rev 2 (21.10.2013).
Nov  9 16:30:30 debian8 kernel: [    9.893815] [drm] Driver supports precis=
e vblank timestamp query.
Nov  9 16:30:30 debian8 kernel: [    9.896222] vgaarb: device changed decod=
es: PCI:0000:00:02.0,olddecodes=3Dio+mem,decodes=3Dio+mem:owns=3Dio+mem
Nov  9 16:30:30 debian8 kernel: [    9.915390] ACPI: Video Device [GFX0] (m=
ulti-head: yes  rom: no  post: no)
Nov  9 16:30:30 debian8 kernel: [    9.915719] input: Video Bus as /devices=
/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/LNXVIDEO:00/input/input9
Nov  9 16:30:30 debian8 kernel: [    9.916158] [drm] Initialized i915 1.6.0=
 20160711 for 0000:00:02.0 on minor 0
Nov  9 16:30:30 debian8 kernel: [    9.931670] fbcon: inteldrmfb (fb0) is p=
rimary device
Nov  9 16:30:30 debian8 kernel: [    9.971882] Console: switching to colour=
 frame buffer device 240x75
Nov  9 16:30:30 debian8 kernel: [    9.985025] bcma: bus0: Found chip with =
id 0x4352, rev 0x03 and package 0x00
Nov  9 16:30:30 debian8 kernel: [    9.985055] bcma: bus0: Core 0 found: Ch=
ipCommon (manuf 0x4BF, id 0x800, rev 0x2B, class 0x0)
Nov  9 16:30:30 debian8 kernel: [    9.985071] bcma: bus0: Core 1 found: IE=
EE 802.11 (manuf 0x4BF, id 0x812, rev 0x2A, class 0x0)
Nov  9 16:30:30 debian8 kernel: [    9.985102] bcma: bus0: Core 2 found: AR=
M CR4 (manuf 0x4BF, id 0x83E, rev 0x02, class 0x0)
Nov  9 16:30:30 debian8 kernel: [    9.985135] bcma: bus0: Core 3 found: PC=
Ie Gen2 (manuf 0x4BF, id 0x83C, rev 0x01, class 0x0)
Nov  9 16:30:30 debian8 kernel: [    9.985151] bcma: bus0: Core 4 found: US=
B 2.0 Device (manuf 0x4BF, id 0x81A, rev 0x11, class 0x0)
Nov  9 16:30:30 debian8 kernel: [   10.018208] bcma: Unsupported SPROM revi=
sion: 11
Nov  9 16:30:30 debian8 kernel: [   10.018209] bcma: bus0: Invalid SPROM re=
ad from the PCIe card, trying to use fallback SPROM
Nov  9 16:30:30 debian8 kernel: [   10.018209] bcma: bus0: Using fallback S=
PROM failed (err -2)
Nov  9 16:30:30 debian8 kernel: [   10.018210] bcma: bus0: No SPROM availab=
le
Nov  9 16:30:30 debian8 kernel: [   10.018728] Error: Driver 'pcspkr' is al=
ready registered, aborting...
Nov  9 16:30:30 debian8 kernel: [   10.020262] bcma: bus0: Bus registered
Nov  9 16:30:30 debian8 kernel: [   10.020773] i915 0000:00:02.0: fb0: inte=
ldrmfb frame buffer device
Nov  9 16:30:30 debian8 kernel: [   10.344412] Bluetooth: Core ver 2.21
Nov  9 16:30:30 debian8 kernel: [   10.344555] NET: Registered protocol fam=
ily 31
Nov  9 16:30:30 debian8 kernel: [   10.344716] Bluetooth: HCI device and co=
nnection manager initialized
Nov  9 16:30:30 debian8 kernel: [   10.344945] Bluetooth: HCI socket layer =
initialized
Nov  9 16:30:30 debian8 kernel: [   10.345123] Bluetooth: L2CAP socket laye=
r initialized
Nov  9 16:30:30 debian8 kernel: [   10.345309] Bluetooth: SCO socket layer =
initialized
Nov  9 16:30:30 debian8 kernel: [   10.463781] Adding 4163580k swap on /dev=
/sda3.  Priority:-1 extents:1 across:4163580k FS
Nov  9 16:30:30 debian8 kernel: [   10.622841] usbcore: registered new inte=
rface driver btusb
Nov  9 16:30:30 debian8 kernel: [   10.627247] Bluetooth: hci0: BCM: chip i=
d 63
Nov  9 16:30:30 debian8 kernel: [   10.643256] Bluetooth: hci0: debian8
Nov  9 16:30:30 debian8 kernel: [   10.644254] Bluetooth: hci0: BCM20702A1 =
(001.002.014) build 0000
Nov  9 16:30:30 debian8 kernel: [   10.653809] bluetooth hci0: Direct firmw=
are load for brcm/BCM20702A1-0b05-17cf.hcd failed with error -2
Nov  9 16:30:30 debian8 kernel: [   10.654144] Bluetooth: hci0: BCM: Patch =
brcm/BCM20702A1-0b05-17cf.hcd not found
Nov  9 16:30:30 debian8 kernel: [   11.086033] snd_hda_intel 0000:00:03.0: =
bound 0000:00:02.0 (ops i915_audio_component_bind_ops [i915])
Nov  9 16:30:30 debian8 kernel: [   11.113762] EXT4-fs (sda4): mounted file=
system with ordered data mode. Opts: (null)
Nov  9 16:30:30 debian8 kernel: [   11.309420] input: HDA Intel HDMI HDMI/D=
P,pcm=3D3 as /devices/pci0000:00/0000:00:03.0/sound/card0/input10
Nov  9 16:30:30 debian8 kernel: [   11.309824] input: HDA Intel HDMI HDMI/D=
P,pcm=3D7 as /devices/pci0000:00/0000:00:03.0/sound/card0/input11
Nov  9 16:30:30 debian8 kernel: [   11.310198] input: HDA Intel HDMI HDMI/D=
P,pcm=3D8 as /devices/pci0000:00/0000:00:03.0/sound/card0/input12
Nov  9 16:30:30 debian8 kernel: [   11.418077] snd_hda_codec_realtek hdaudi=
oC1D0: ALC1150: SKU not ready 0x00000000
Nov  9 16:30:30 debian8 kernel: [   11.418907] snd_hda_codec_realtek hdaudi=
oC1D0: autoconfig for ALC1150: line_outs=3D4 (0x14/0x15/0x16/0x17/0x0) type=
:line
Nov  9 16:30:30 debian8 kernel: [   11.419285] snd_hda_codec_realtek hdaudi=
oC1D0:    speaker_outs=3D0 (0x0/0x0/0x0/0x0/0x0)
Nov  9 16:30:30 debian8 kernel: [   11.419566] snd_hda_codec_realtek hdaudi=
oC1D0:    hp_outs=3D1 (0x1b/0x0/0x0/0x0/0x0)
Nov  9 16:30:30 debian8 kernel: [   11.419844] snd_hda_codec_realtek hdaudi=
oC1D0:    mono: mono_out=3D0x0
Nov  9 16:30:30 debian8 kernel: [   11.420071] snd_hda_codec_realtek hdaudi=
oC1D0:    dig-out=3D0x11/0x1e
Nov  9 16:30:30 debian8 kernel: [   11.420295] snd_hda_codec_realtek hdaudi=
oC1D0:    inputs:
Nov  9 16:30:30 debian8 kernel: [   11.420490] snd_hda_codec_realtek hdaudi=
oC1D0:      Front Mic=3D0x19
Nov  9 16:30:30 debian8 kernel: [   11.420711] snd_hda_codec_realtek hdaudi=
oC1D0:      Rear Mic=3D0x18
Nov  9 16:30:30 debian8 kernel: [   11.420938] snd_hda_codec_realtek hdaudi=
oC1D0:      Line=3D0x1a
Nov  9 16:30:30 debian8 kernel: [   11.432840] input: HDA Digital PCBeep as=
 /devices/pci0000:00/0000:00:1b.0/sound/card1/input13
Nov  9 16:30:30 debian8 kernel: [   11.433740] input: HDA Intel PCH Front M=
ic as /devices/pci0000:00/0000:00:1b.0/sound/card1/input14
Nov  9 16:30:30 debian8 kernel: [   11.434096] input: HDA Intel PCH Rear Mi=
c as /devices/pci0000:00/0000:00:1b.0/sound/card1/input15
Nov  9 16:30:30 debian8 kernel: [   11.434485] input: HDA Intel PCH Line as=
 /devices/pci0000:00/0000:00:1b.0/sound/card1/input16
Nov  9 16:30:30 debian8 kernel: [   11.434870] input: HDA Intel PCH Line Ou=
t Front as /devices/pci0000:00/0000:00:1b.0/sound/card1/input17
Nov  9 16:30:30 debian8 kernel: [   11.435283] input: HDA Intel PCH Line Ou=
t Surround as /devices/pci0000:00/0000:00:1b.0/sound/card1/input18
Nov  9 16:30:30 debian8 kernel: [   11.435701] input: HDA Intel PCH Line Ou=
t CLFE as /devices/pci0000:00/0000:00:1b.0/sound/card1/input19
Nov  9 16:30:30 debian8 kernel: [   11.436112] input: HDA Intel PCH Line Ou=
t Side as /devices/pci0000:00/0000:00:1b.0/sound/card1/input20
Nov  9 16:30:30 debian8 kernel: [   11.436507] input: HDA Intel PCH Front H=
eadphone as /devices/pci0000:00/0000:00:1b.0/sound/card1/input21
Nov  9 16:30:30 debian8 kernel: [   12.270467] intel_rapl: Found RAPL domai=
n package
Nov  9 16:30:30 debian8 kernel: [   12.270649] intel_rapl: Found RAPL domai=
n core
Nov  9 16:30:30 debian8 kernel: [   12.270813] intel_rapl: Found RAPL domai=
n uncore
Nov  9 16:30:30 debian8 kernel: [   12.270982] intel_rapl: Found RAPL domai=
n dram
Nov  9 16:30:30 debian8 kernel: [   12.385687] b43-phy0: Broadcom 4352 WLAN=
 found (core revision 42)
Nov  9 16:30:30 debian8 kernel: [   12.386248] b43-phy0 ERROR: FOUND UNSUPP=
ORTED PHY (Analog 12, Type 11 (AC), Revision 1)
Nov  9 16:30:30 debian8 kernel: [   12.386542] b43: probe of bcma0:1 failed=
 with error -95
Nov  9 16:30:30 debian8 kernel: [   12.386742] Broadcom 43xx driver loaded =
[ Features: PNLS ]
Nov  9 16:30:30 debian8 kernel: [   12.886267] RPC: Registered named UNIX s=
ocket transport module.
Nov  9 16:30:30 debian8 kernel: [   12.886483] RPC: Registered udp transpor=
t module.
Nov  9 16:30:30 debian8 kernel: [   12.886654] RPC: Registered tcp transpor=
t module.
Nov  9 16:30:30 debian8 kernel: [   12.886825] RPC: Registered tcp NFSv4.1 =
backchannel transport module.
Nov  9 16:30:30 debian8 kernel: [   12.930288] FS-Cache: Loaded
Nov  9 16:30:30 debian8 kernel: [   13.037241] FS-Cache: Netfs 'nfs' regist=
ered for caching
Nov  9 16:30:30 debian8 kernel: [   13.161992] Installing knfsd (copyright =
(C) 1996 okir@monad.swb.de).
Nov  9 16:30:30 debian8 kernel: [   15.001250] Bluetooth: BNEP (Ethernet Em=
ulation) ver 1.3
Nov  9 16:30:30 debian8 kernel: [   15.001446] Bluetooth: BNEP filters: pro=
tocol multicast
Nov  9 16:30:30 debian8 kernel: [   15.001637] Bluetooth: BNEP socket layer=
 initialized
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> NetworkManager (version=
 0.9.10.0) is starting...
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> Read config: /etc/Netwo=
rkManager/NetworkManager.conf
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> WEXT support is enabled
Nov  9 16:30:30 debian8 polkitd[868]: started daemon version 0.105 using au=
thority implementation `local' version `0.105'
Nov  9 16:30:30 debian8 dbus[586]: [system] Successfully activated service =
'org.freedesktop.PolicyKit1'
Nov  9 16:30:30 debian8 systemd[1]: Started Authenticate and Authorize User=
s to Run Privileged Tasks.
Nov  9 16:30:30 debian8 accounts-daemon[560]: started daemon version 0.6.37
Nov  9 16:30:30 debian8 systemd[1]: Started Accounts Service.
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> init!
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> update_system_hostname
Nov  9 16:30:30 debian8 NetworkManager[570]: <info>       interface-parser:=
 parsing file /etc/network/interfaces
Nov  9 16:30:30 debian8 NetworkManager[570]: <info>       interface-parser:=
 source line includes interfaces file(s) /etc/network/interfaces.d/*
Nov  9 16:30:30 debian8 NetworkManager[570]: <warn> interfaces file /etc/ne=
twork/interfaces.d/* doesn't exist
Nov  9 16:30:30 debian8 NetworkManager[570]: <warn> Can't parse iface line =
'iface eth0 dhcp'
Nov  9 16:30:30 debian8 NetworkManager[570]: <info>       interface-parser:=
 finished parsing file /etc/network/interfaces
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> management mode: unmana=
ged
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> devices added (path: /s=
ys/devices/pci0000:00/0000:00:19.0/net/eth4, iface: eth4)
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> device added (path: /sy=
s/devices/pci0000:00/0000:00:19.0/net/eth4, iface: eth4): no ifupdown confi=
guration found.
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> devices added (path: /s=
ys/devices/pci0000:00/0000:00:1c.3/0000:04:00.0/0000:05:05.0/0000:08:00.0/n=
et/eth5, iface: eth5)
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> device added (path: /sy=
s/devices/pci0000:00/0000:00:1c.3/0000:04:00.0/0000:05:05.0/0000:08:00.0/ne=
t/eth5, iface: eth5): no ifupdown configuration found.
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> devices added (path: /s=
ys/devices/virtual/net/lo, iface: lo)
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> device added (path: /sy=
s/devices/virtual/net/lo, iface: lo): no ifupdown configuration found.
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> end _init.
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> Loaded plugin ifupdown:=
 (C) 2008 Canonical Ltd.  To report bugs please use the NetworkManager mail=
ing list.
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> Loaded plugin keyfile: =
(c) 2007 - 2013 Red Hat, Inc.  To report bugs please use the NetworkManager=
 mailing list.
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> (17085600) ... get_conn=
ections.
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> (17085600) ... get_conn=
ections (managed=3Dfalse): return empty list.
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> new connection /etc/Net=
workManager/system-connections/Wired connection 1
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> get unmanaged devices c=
ount: 0
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> monitoring kernel firmw=
are directory '/lib/firmware'.
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> monitoring ifupdown sta=
te file '/run/network/ifstate'.
Nov  9 16:30:30 debian8 systemd[1]: Started Light Display Manager.
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> WiFi hardware radio set=
 enabled
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> WWAN hardware radio set=
 enabled
Nov  9 16:30:30 debian8 rsyslogd-2007: action 'action 17' suspended, next r=
etry is Wed Nov  9 16:31:00 2016 [try http://www.rsyslog.com/e/2007 ]
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> Loaded device plugin: /=
usr/lib/x86_64-linux-gnu/NetworkManager/libnm-device-plugin-bluetooth.so
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> Loaded device plugin: /=
usr/lib/x86_64-linux-gnu/NetworkManager/libnm-device-plugin-wifi.so
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> Loaded device plugin: /=
usr/lib/x86_64-linux-gnu/NetworkManager/libnm-device-plugin-adsl.so
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> Loaded device plugin: /=
usr/lib/x86_64-linux-gnu/NetworkManager/libnm-device-plugin-wwan.so
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> WiFi enabled by radio k=
illswitch; enabled by state file
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> WWAN enabled by radio k=
illswitch; enabled by state file
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> WiMAX enabled by radio =
killswitch; enabled by state file
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> Networking is enabled b=
y state file
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> (lo): link connected
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> (lo): carrier is ON
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> (lo): new Generic devic=
e (driver: 'unknown' ifindex: 1)
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> (lo): exported as /org/=
freedesktop/NetworkManager/Devices/0
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> (eth5): carrier is OFF
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> (eth5): new Ethernet de=
vice (driver: 'r8169' ifindex: 2)
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> (eth5): exported as /or=
g/freedesktop/NetworkManager/Devices/1
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> (eth5): device state ch=
ange: unmanaged -> unavailable (reason 'managed') [10 20 2]
Nov  9 16:30:30 debian8 systemd[1]: Started Network Manager.
Nov  9 16:30:30 debian8 kernel: [   15.936554] r8169 0000:08:00.0: Direct f=
irmware load for rtl_nic/rtl8168g-2.fw failed with error -2
Nov  9 16:30:30 debian8 kernel: [   15.936878] r8169 0000:08:00.0 eth5: una=
ble to load firmware patch rtl_nic/rtl8168g-2.fw (-2)
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> (eth5): preparing device
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> (eth4): carrier is OFF
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> (eth4): new Ethernet de=
vice (driver: 'e1000e' ifindex: 3)
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> (eth4): exported as /or=
g/freedesktop/NetworkManager/Devices/2
Nov  9 16:30:30 debian8 NetworkManager[570]: <info> (eth4): device state ch=
ange: unmanaged -> unavailable (reason 'managed') [10 20 2]
Nov  9 16:30:30 debian8 kernel: [   15.952676] r8169 0000:08:00.0 eth5: lin=
k down
Nov  9 16:30:30 debian8 kernel: [   15.952679] r8169 0000:08:00.0 eth5: lin=
k down
Nov  9 16:30:30 debian8 systemd[1]: Started Modem Manager.
Nov  9 16:30:31 debian8 NetworkManager[570]: <info> (eth4): preparing device
Nov  9 16:30:31 debian8 NetworkManager[570]: <info> use BlueZ version 5
Nov  9 16:30:31 debian8 NetworkManager[570]: <info> ModemManager available =
in the bus
Nov  9 16:30:31 debian8 exim4[574]: Starting MTA: exim4.
Nov  9 16:30:31 debian8 systemd[1]: Started LSB: exim Mail Transport Agent.
Nov  9 16:30:32 debian8 systemd[1]: Starting user-117.slice.
Nov  9 16:30:32 debian8 systemd[1]: Created slice user-117.slice.
Nov  9 16:30:32 debian8 ModemManager[563]: <warn>  Couldn't find support fo=
r device at '/sys/devices/pci0000:00/0000:00:19.0': not supported by any pl=
ugin
Nov  9 16:30:32 debian8 ModemManager[563]: <warn>  Couldn't find support fo=
r device at '/sys/devices/pci0000:00/0000:00:1c.3/0000:04:00.0/0000:05:05.0=
/0000:08:00.0': not supported by any plugin
Nov  9 16:30:32 debian8 systemd[1]: Starting User Manager for UID 117...
Nov  9 16:30:32 debian8 systemd[1]: Starting Session c1 of user lightdm.
Nov  9 16:30:32 debian8 systemd[1]: Started Session c1 of user lightdm.
Nov  9 16:30:33 debian8 systemd[1]: Started LSB: start Samba daemons for th=
e AD DC.
Nov  9 16:30:33 debian8 nmbd[573]: Starting NetBIOS name server: nmbd.
Nov  9 16:30:33 debian8 systemd[1]: Started LSB: start Samba NetBIOS namese=
rver (nmbd).
Nov  9 16:30:33 debian8 systemd[916]: Starting Paths.
Nov  9 16:30:33 debian8 systemd[916]: Reached target Paths.
Nov  9 16:30:33 debian8 systemd[916]: Starting Timers.
Nov  9 16:30:33 debian8 systemd[916]: Reached target Timers.
Nov  9 16:30:33 debian8 systemd[916]: Starting Sockets.
Nov  9 16:30:33 debian8 systemd[916]: Reached target Sockets.
Nov  9 16:30:33 debian8 systemd[916]: Starting Basic System.
Nov  9 16:30:33 debian8 systemd[916]: Reached target Basic System.
Nov  9 16:30:33 debian8 systemd[1]: Starting LSB: start Samba SMB/CIFS daem=
on (smbd)...
Nov  9 16:30:33 debian8 systemd[916]: Starting Default.
Nov  9 16:30:33 debian8 systemd[916]: Reached target Default.
Nov  9 16:30:33 debian8 systemd[916]: Startup finished in 90ms.
Nov  9 16:30:33 debian8 systemd[1]: Started User Manager for UID 117.
Nov  9 16:30:33 debian8 lightdm[873]: ** (lightdm:873): WARNING **: Error u=
sing VT_ACTIVATE 7 on /dev/console: Input/output error
Nov  9 16:30:33 debian8 lightdm[873]: ** (lightdm:873): WARNING **: Error u=
sing VT_WAITACTIVE 7 on /dev/console: Input/output error
Nov  9 16:30:33 debian8 smbd[925]: Starting SMB/CIFS daemon: smbd.
Nov  9 16:30:33 debian8 systemd[1]: Started LSB: start Samba SMB/CIFS daemo=
n (smbd).
Nov  9 16:30:33 debian8 systemd[1]: Starting Multi-User System.
Nov  9 16:30:33 debian8 systemd[1]: Reached target Multi-User System.
Nov  9 16:30:33 debian8 systemd[1]: Starting Graphical Interface.
Nov  9 16:30:33 debian8 systemd[1]: Reached target Graphical Interface.
Nov  9 16:30:33 debian8 systemd[1]: Starting Update UTMP about System Runle=
vel Changes...
Nov  9 16:30:33 debian8 systemd[1]: Started Update UTMP about System Runlev=
el Changes.
Nov  9 16:30:33 debian8 systemd[1]: Startup finished in 5.805s (kernel) + 1=
2.824s (userspace) =3D 18.629s.
Nov  9 16:30:33 debian8 NetworkManager[570]: <info> (eth5): link connected
Nov  9 16:30:33 debian8 NetworkManager[570]: <info> (eth5): device state ch=
ange: unavailable -> disconnected (reason 'carrier-changed') [20 30 40]
Nov  9 16:30:33 debian8 NetworkManager[570]: <info> Auto-activating connect=
ion 'Wired connection 1'.
Nov  9 16:30:33 debian8 NetworkManager[570]: <info> Activation (eth5) start=
ing connection 'Wired connection 1'
Nov  9 16:30:33 debian8 NetworkManager[570]: <info> Activation (eth5) Stage=
 1 of 5 (Device Prepare) scheduled...
Nov  9 16:30:33 debian8 NetworkManager[570]: <info> Activation (eth5) Stage=
 1 of 5 (Device Prepare) started...
Nov  9 16:30:33 debian8 NetworkManager[570]: <info> (eth5): device state ch=
ange: disconnected -> prepare (reason 'none') [30 40 0]
Nov  9 16:30:33 debian8 NetworkManager[570]: <info> NetworkManager state is=
 now CONNECTING
Nov  9 16:30:33 debian8 NetworkManager[570]: <info> Activation (eth5) Stage=
 2 of 5 (Device Configure) scheduled...
Nov  9 16:30:33 debian8 NetworkManager[570]: <info> Activation (eth5) Stage=
 1 of 5 (Device Prepare) complete.
Nov  9 16:30:33 debian8 NetworkManager[570]: <info> Activation (eth5) Stage=
 2 of 5 (Device Configure) starting...
Nov  9 16:30:33 debian8 NetworkManager[570]: <info> (eth5): device state ch=
ange: prepare -> config (reason 'none') [40 50 0]
Nov  9 16:30:33 debian8 NetworkManager[570]: <info> Activation (eth5) Stage=
 2 of 5 (Device Configure) successful.
Nov  9 16:30:33 debian8 NetworkManager[570]: <info> Activation (eth5) Stage=
 3 of 5 (IP Configure Start) scheduled.
Nov  9 16:30:33 debian8 NetworkManager[570]: <info> Activation (eth5) Stage=
 2 of 5 (Device Configure) complete.
Nov  9 16:30:33 debian8 NetworkManager[570]: <info> Activation (eth5) Stage=
 3 of 5 (IP Configure Start) started...
Nov  9 16:30:33 debian8 NetworkManager[570]: <info> (eth5): device state ch=
ange: config -> ip-config (reason 'none') [50 70 0]
Nov  9 16:30:33 debian8 kernel: [   18.931173] r8169 0000:08:00.0 eth5: lin=
k up
Nov  9 16:30:33 debian8 NetworkManager[570]: <info> Activation (eth5) Begin=
ning DHCPv4 transaction (timeout in 45 seconds)
Nov  9 16:30:33 debian8 NetworkManager[570]: <info> dhclient started with p=
id 944
Nov  9 16:30:33 debian8 NetworkManager[570]: <info> Activation (eth5) Stage=
 3 of 5 (IP Configure Start) complete.
Nov  9 16:30:34 debian8 NetworkManager[570]: <info> (eth5): DHCPv4 state ch=
anged nbi -> preinit
Nov  9 16:30:34 debian8 dhclient: DHCPREQUEST on eth5 to 255.255.255.255 po=
rt 67
Nov  9 16:30:34 debian8 dhclient: DHCPACK from 10.21.59.1
Nov  9 16:30:34 debian8 NetworkManager[570]: <info> (eth5): DHCPv4 state ch=
anged preinit -> reboot
Nov  9 16:30:34 debian8 NetworkManager[570]: <info>   address 10.21.59.167
Nov  9 16:30:34 debian8 NetworkManager[570]: <info>   plen 24 (255.255.255.=
0)
Nov  9 16:30:34 debian8 NetworkManager[570]: <info>   gateway 10.21.59.1
Nov  9 16:30:34 debian8 NetworkManager[570]: <info>   server identifier 10.=
21.62.9
Nov  9 16:30:34 debian8 NetworkManager[570]: <info>   lease time 14400
Nov  9 16:30:34 debian8 NetworkManager[570]: <info>   hostname 'debian8'
Nov  9 16:30:34 debian8 NetworkManager[570]: <info>   nameserver '10.21.62.=
9'
Nov  9 16:30:34 debian8 NetworkManager[570]: <info>   nameserver '10.21.62.=
10'
Nov  9 16:30:34 debian8 NetworkManager[570]: <info>   domain name 'lacie.co=
m'
Nov  9 16:30:34 debian8 NetworkManager[570]: <info> Activation (eth5) Stage=
 5 of 5 (IPv4 Configure Commit) scheduled...
Nov  9 16:30:34 debian8 NetworkManager[570]: <info> Activation (eth5) Stage=
 5 of 5 (IPv4 Commit) started...
Nov  9 16:30:34 debian8 avahi-daemon[582]: Joining mDNS multicast group on =
interface eth5.IPv4 with address 10.21.59.167.
Nov  9 16:30:34 debian8 avahi-daemon[582]: New relevant interface eth5.IPv4=
 for mDNS.
Nov  9 16:30:34 debian8 avahi-daemon[582]: Registering new address record f=
or 10.21.59.167 on eth5.IPv4.
Nov  9 16:30:34 debian8 NetworkManager[570]: <info> (eth5): device state ch=
ange: ip-config -> ip-check (reason 'none') [70 80 0]
Nov  9 16:30:34 debian8 NetworkManager[570]: <info> Activation (eth5) Stage=
 5 of 5 (IPv4 Commit) complete.
Nov  9 16:30:34 debian8 NetworkManager[570]: <info> (eth5): device state ch=
ange: ip-check -> secondaries (reason 'none') [80 90 0]
Nov  9 16:30:34 debian8 NetworkManager[570]: <info> (eth5): device state ch=
ange: secondaries -> activated (reason 'none') [90 100 0]
Nov  9 16:30:34 debian8 NetworkManager[570]: <info> NetworkManager state is=
 now CONNECTED_LOCAL
Nov  9 16:30:34 debian8 dhclient: bound to 10.21.59.167 -- renewal in 7049 =
seconds.
Nov  9 16:30:34 debian8 NetworkManager[570]: <info> NetworkManager state is=
 now CONNECTED_GLOBAL
Nov  9 16:30:34 debian8 NetworkManager[570]: <info> Policy set 'Wired conne=
ction 1' (eth5) as default for IPv4 routing and DNS.
Nov  9 16:30:34 debian8 NetworkManager[570]: <info> Activation (eth5) succe=
ssful, device activated.
Nov  9 16:30:34 debian8 dbus[586]: [system] Activating via systemd: service=
 name=3D'org.freedesktop.nm_dispatcher' unit=3D'dbus-org.freedesktop.nm-dis=
patcher.service'
Nov  9 16:30:34 debian8 systemd[1]: Starting Network Manager Script Dispatc=
her Service...
Nov  9 16:30:34 debian8 dbus[586]: [system] Successfully activated service =
'org.freedesktop.nm_dispatcher'
Nov  9 16:30:34 debian8 systemd[1]: Started Network Manager Script Dispatch=
er Service.
Nov  9 16:30:34 debian8 nm-dispatcher: Dispatching action 'up' for eth5
Nov  9 16:30:34 debian8 org.a11y.Bus[953]: Activating service name=3D'org.a=
11y.atspi.Registry'
Nov  9 16:30:34 debian8 org.a11y.Bus[953]: Successfully activated service '=
org.a11y.atspi.Registry'
Nov  9 16:30:34 debian8 org.a11y.atspi.Registry[973]: SpiRegistry daemon is=
 running with well-known name - org.a11y.atspi.Registry
Nov  9 16:30:34 debian8 systemd[1]: Reloading OpenBSD Secure Shell server.
Nov  9 16:30:35 debian8 systemd[1]: Reloaded OpenBSD Secure Shell server.
Nov  9 16:30:35 debian8 avahi-daemon[582]: Joining mDNS multicast group on =
interface eth5.IPv6 with address fe80::2e0:4cff:fe68:3d.
Nov  9 16:30:35 debian8 avahi-daemon[582]: New relevant interface eth5.IPv6=
 for mDNS.
Nov  9 16:30:35 debian8 avahi-daemon[582]: Registering new address record f=
or fe80::2e0:4cff:fe68:3d on eth5.*.
Nov  9 16:30:38 debian8 NetworkManager[570]: <info> startup complete
Nov  9 16:31:43 debian8 systemd[1]: Starting user-1001.slice.
Nov  9 16:31:43 debian8 systemd[1]: Created slice user-1001.slice.
Nov  9 16:31:43 debian8 systemd[1]: Starting User Manager for UID 1001...
Nov  9 16:31:43 debian8 systemd[1]: Starting Session 1 of user sguinot.
Nov  9 16:31:43 debian8 systemd[1]: Started Session 1 of user sguinot.
Nov  9 16:31:43 debian8 systemd[1035]: Starting Paths.
Nov  9 16:31:43 debian8 systemd[1035]: Reached target Paths.
Nov  9 16:31:43 debian8 systemd[1035]: Starting Timers.
Nov  9 16:31:43 debian8 systemd[1035]: Reached target Timers.
Nov  9 16:31:43 debian8 systemd[1035]: Starting Sockets.
Nov  9 16:31:43 debian8 systemd[1035]: Reached target Sockets.
Nov  9 16:31:43 debian8 systemd[1035]: Starting Basic System.
Nov  9 16:31:43 debian8 systemd[1035]: Reached target Basic System.
Nov  9 16:31:43 debian8 systemd[1035]: Starting Default.
Nov  9 16:31:43 debian8 systemd[1035]: Reached target Default.
Nov  9 16:31:43 debian8 systemd[1035]: Startup finished in 17ms.
Nov  9 16:31:43 debian8 systemd[1]: Started User Manager for UID 1001.
Nov  9 16:32:37 debian8 kernel: [  142.351927] pci 0000:0d:00.0: [8086:156d=
] type 01 class 0x060400
Nov  9 16:32:37 debian8 kernel: [  142.352079] pci 0000:0d:00.0: supports D=
1 D2
Nov  9 16:32:37 debian8 kernel: [  142.352082] pci 0000:0d:00.0: PME# suppo=
rted from D0 D1 D2 D3hot D3cold
Nov  9 16:32:37 debian8 kernel: [  142.352154] pci 0000:0d:00.0: System wak=
eup disabled by ACPI
Nov  9 16:32:37 debian8 kernel: [  142.363957] pci 0000:0e:00.0: [8086:156d=
] type 01 class 0x060400
Nov  9 16:32:37 debian8 kernel: [  142.364106] pci 0000:0e:00.0: supports D=
1 D2
Nov  9 16:32:37 debian8 kernel: [  142.364109] pci 0000:0e:00.0: PME# suppo=
rted from D0 D1 D2 D3hot D3cold
Nov  9 16:32:37 debian8 kernel: [  142.364231] pci 0000:0e:03.0: [8086:156d=
] type 01 class 0x060400
Nov  9 16:32:37 debian8 kernel: [  142.364372] pci 0000:0e:03.0: supports D=
1 D2
Nov  9 16:32:37 debian8 kernel: [  142.364374] pci 0000:0e:03.0: PME# suppo=
rted from D0 D1 D2 D3hot D3cold
Nov  9 16:32:37 debian8 kernel: [  142.364482] pci 0000:0e:04.0: [8086:156d=
] type 01 class 0x060400
Nov  9 16:32:37 debian8 kernel: [  142.364621] pci 0000:0e:04.0: supports D=
1 D2
Nov  9 16:32:37 debian8 kernel: [  142.364623] pci 0000:0e:04.0: PME# suppo=
rted from D0 D1 D2 D3hot D3cold
Nov  9 16:32:37 debian8 kernel: [  142.364725] pci 0000:0e:05.0: [8086:156d=
] type 01 class 0x060400
Nov  9 16:32:37 debian8 kernel: [  142.364865] pci 0000:0e:05.0: supports D=
1 D2
Nov  9 16:32:37 debian8 kernel: [  142.364866] pci 0000:0e:05.0: PME# suppo=
rted from D0 D1 D2 D3hot D3cold
Nov  9 16:32:37 debian8 kernel: [  142.364968] pci 0000:0e:06.0: [8086:156d=
] type 01 class 0x060400
Nov  9 16:32:37 debian8 kernel: [  142.365107] pci 0000:0e:06.0: supports D=
1 D2
Nov  9 16:32:37 debian8 kernel: [  142.365109] pci 0000:0e:06.0: PME# suppo=
rted from D0 D1 D2 D3hot D3cold
Nov  9 16:32:37 debian8 kernel: [  142.365233] pci 0000:0d:00.0: PCI bridge=
 to [bus 0e-77]
Nov  9 16:32:37 debian8 kernel: [  142.365450] pci 0000:0d:00.0:   bridge w=
indow [mem 0xb0000000-0xde0fffff]
Nov  9 16:32:37 debian8 kernel: [  142.365458] pci 0000:0d:00.0:   bridge w=
indow [mem 0x60000000-0xa9ffffff 64bit pref]
Nov  9 16:32:37 debian8 kernel: [  142.365545] pci 0000:0f:00.0: [8086:156c=
] type 00 class 0x088000
Nov  9 16:32:37 debian8 kernel: [  142.365571] pci 0000:0f:00.0: reg 0x10: =
[mem 0xde000000-0xde03ffff]
Nov  9 16:32:37 debian8 kernel: [  142.365586] pci 0000:0f:00.0: reg 0x14: =
[mem 0xde040000-0xde040fff]
Nov  9 16:32:37 debian8 kernel: [  142.365767] pci 0000:0f:00.0: supports D=
1 D2
Nov  9 16:32:37 debian8 kernel: [  142.365769] pci 0000:0f:00.0: PME# suppo=
rted from D0 D1 D2 D3hot D3cold
Nov  9 16:32:37 debian8 kernel: [  142.365894] pci 0000:0e:00.0: PCI bridge=
 to [bus 0f]
Nov  9 16:32:37 debian8 kernel: [  142.366106] pci 0000:0e:00.0:   bridge w=
indow [mem 0xde000000-0xde0fffff]
Nov  9 16:32:37 debian8 kernel: [  142.366167] pci 0000:0e:03.0: PCI bridge=
 to [bus 10-3a]
Nov  9 16:32:37 debian8 kernel: [  142.366371] pci 0000:0e:03.0:   bridge w=
indow [mem 0xb0000000-0xbfffffff]
Nov  9 16:32:37 debian8 kernel: [  142.366377] pci 0000:0e:03.0:   bridge w=
indow [mem 0x60000000-0x7fffffff 64bit pref]
Nov  9 16:32:37 debian8 kernel: [  142.366430] pci 0000:0e:04.0: PCI bridge=
 to [bus 3b-43]
Nov  9 16:32:37 debian8 kernel: [  142.366634] pci 0000:0e:04.0:   bridge w=
indow [mem 0xc0000000-0xc7ffffff]
Nov  9 16:32:37 debian8 kernel: [  142.366641] pci 0000:0e:04.0:   bridge w=
indow [mem 0x80000000-0x87ffffff 64bit pref]
Nov  9 16:32:37 debian8 kernel: [  142.366694] pci 0000:0e:05.0: PCI bridge=
 to [bus 44-6e]
Nov  9 16:32:37 debian8 kernel: [  142.366898] pci 0000:0e:05.0:   bridge w=
indow [mem 0xc8000000-0xd5ffffff]
Nov  9 16:32:37 debian8 kernel: [  142.366905] pci 0000:0e:05.0:   bridge w=
indow [mem 0x90000000-0xa9ffffff 64bit pref]
Nov  9 16:32:37 debian8 kernel: [  142.366957] pci 0000:0e:06.0: PCI bridge=
 to [bus 6f-77]
Nov  9 16:32:37 debian8 kernel: [  142.367161] pci 0000:0e:06.0:   bridge w=
indow [mem 0xd6000000-0xddffffff]
Nov  9 16:32:37 debian8 kernel: [  142.367168] pci 0000:0e:06.0:   bridge w=
indow [mem 0x88000000-0x8fffffff 64bit pref]
Nov  9 16:32:37 debian8 kernel: [  142.367206] pci_bus 0000:0e: Allocating =
resources
Nov  9 16:32:37 debian8 kernel: [  142.367238] pci 0000:0e:00.0: bridge win=
dow [io  0x1000-0x0fff] to [bus 0f] add_size 1000
Nov  9 16:32:37 debian8 kernel: [  142.367240] pci 0000:0e:00.0: bridge win=
dow [mem 0x00100000-0x000fffff 64bit pref] to [bus 0f] add_size 200000 add_=
align 100000
Nov  9 16:32:37 debian8 kernel: [  142.367251] pci 0000:0e:03.0: bridge win=
dow [io  0x1000-0x0fff] to [bus 10-3a] add_size 1000
Nov  9 16:32:37 debian8 kernel: [  142.367261] pci 0000:0e:04.0: bridge win=
dow [io  0x1000-0x0fff] to [bus 3b-43] add_size 1000
Nov  9 16:32:37 debian8 kernel: [  142.367271] pci 0000:0e:05.0: bridge win=
dow [io  0x1000-0x0fff] to [bus 44-6e] add_size 1000
Nov  9 16:32:37 debian8 kernel: [  142.367281] pci 0000:0e:06.0: bridge win=
dow [io  0x1000-0x0fff] to [bus 6f-77] add_size 1000
Nov  9 16:32:37 debian8 kernel: [  142.367291] pci 0000:0e:00.0: res[13]=3D=
[io  0x1000-0x0fff] res_to_dev_res add_size 1000 min_align 1000
Nov  9 16:32:37 debian8 kernel: [  142.367292] pci 0000:0e:03.0: res[13]=3D=
[io  0x1000-0x0fff] res_to_dev_res add_size 1000 min_align 1000
Nov  9 16:32:37 debian8 kernel: [  142.367294] pci 0000:0e:04.0: res[13]=3D=
[io  0x1000-0x0fff] res_to_dev_res add_size 1000 min_align 1000
Nov  9 16:32:37 debian8 kernel: [  142.367295] pci 0000:0e:05.0: res[13]=3D=
[io  0x1000-0x0fff] res_to_dev_res add_size 1000 min_align 1000
Nov  9 16:32:37 debian8 kernel: [  142.367296] pci 0000:0e:06.0: res[13]=3D=
[io  0x1000-0x0fff] res_to_dev_res add_size 1000 min_align 1000
Nov  9 16:32:37 debian8 kernel: [  142.367298] pci 0000:0d:00.0: bridge win=
dow [io  0x1000-0x0fff] to [bus 0e-77] add_size 5000
Nov  9 16:32:37 debian8 kernel: [  142.367300] pci 0000:0d:00.0: res[13]=3D=
[io  0x1000-0x0fff] res_to_dev_res add_size 5000 min_align 1000
Nov  9 16:32:37 debian8 kernel: [  142.367301] pci 0000:0d:00.0: res[13]=3D=
[io  0x1000-0x5fff] res_to_dev_res add_size 5000 min_align 1000
Nov  9 16:32:37 debian8 kernel: [  142.367304] pci 0000:0d:00.0: BAR 13: no=
 space for [io  size 0x5000]
Nov  9 16:32:37 debian8 kernel: [  142.367540] pci 0000:0d:00.0: BAR 13: fa=
iled to assign [io  size 0x5000]
Nov  9 16:32:37 debian8 kernel: [  142.367821] pci 0000:0d:00.0: BAR 13: no=
 space for [io  size 0x5000]
Nov  9 16:32:37 debian8 kernel: [  142.368054] pci 0000:0d:00.0: BAR 13: fa=
iled to assign [io  size 0x5000]
Nov  9 16:32:37 debian8 kernel: [  142.368307] pci 0000:0e:00.0: res[15]=3D=
[mem 0x00100000-0x000fffff 64bit pref] res_to_dev_res add_size 200000 min_a=
lign 100000
Nov  9 16:32:37 debian8 kernel: [  142.368308] pci 0000:0e:00.0: res[15]=3D=
[mem 0x00100000-0x002fffff 64bit pref] res_to_dev_res add_size 200000 min_a=
lign 100000
Nov  9 16:32:37 debian8 kernel: [  142.368309] pci 0000:0e:00.0: res[13]=3D=
[io  0x1000-0x0fff] res_to_dev_res add_size 1000 min_align 1000
Nov  9 16:32:37 debian8 kernel: [  142.368310] pci 0000:0e:00.0: res[13]=3D=
[io  0x1000-0x1fff] res_to_dev_res add_size 1000 min_align 1000
Nov  9 16:32:37 debian8 kernel: [  142.368311] pci 0000:0e:03.0: res[13]=3D=
[io  0x1000-0x0fff] res_to_dev_res add_size 1000 min_align 1000
Nov  9 16:32:37 debian8 kernel: [  142.368311] pci 0000:0e:03.0: res[13]=3D=
[io  0x1000-0x1fff] res_to_dev_res add_size 1000 min_align 1000
Nov  9 16:32:37 debian8 kernel: [  142.368312] pci 0000:0e:04.0: res[13]=3D=
[io  0x1000-0x0fff] res_to_dev_res add_size 1000 min_align 1000
Nov  9 16:32:37 debian8 kernel: [  142.368313] pci 0000:0e:04.0: res[13]=3D=
[io  0x1000-0x1fff] res_to_dev_res add_size 1000 min_align 1000
Nov  9 16:32:37 debian8 kernel: [  142.368314] pci 0000:0e:05.0: res[13]=3D=
[io  0x1000-0x0fff] res_to_dev_res add_size 1000 min_align 1000
Nov  9 16:32:37 debian8 kernel: [  142.368315] pci 0000:0e:05.0: res[13]=3D=
[io  0x1000-0x1fff] res_to_dev_res add_size 1000 min_align 1000
Nov  9 16:32:37 debian8 kernel: [  142.368317] pci 0000:0e:06.0: res[13]=3D=
[io  0x1000-0x0fff] res_to_dev_res add_size 1000 min_align 1000
Nov  9 16:32:37 debian8 kernel: [  142.368318] pci 0000:0e:06.0: res[13]=3D=
[io  0x1000-0x1fff] res_to_dev_res add_size 1000 min_align 1000
Nov  9 16:32:37 debian8 kernel: [  142.368321] pci 0000:0e:00.0: BAR 15: no=
 space for [mem size 0x00200000 64bit pref]
Nov  9 16:32:37 debian8 kernel: [  142.368606] pci 0000:0e:00.0: BAR 15: fa=
iled to assign [mem size 0x00200000 64bit pref]
Nov  9 16:32:37 debian8 kernel: [  142.368897] pci 0000:0e:00.0: BAR 13: no=
 space for [io  size 0x1000]
Nov  9 16:32:37 debian8 kernel: [  142.369128] pci 0000:0e:00.0: BAR 13: fa=
iled to assign [io  size 0x1000]
Nov  9 16:32:37 debian8 kernel: [  142.369373] pci 0000:0e:03.0: BAR 13: no=
 space for [io  size 0x1000]
Nov  9 16:32:37 debian8 kernel: [  142.369604] pci 0000:0e:03.0: BAR 13: fa=
iled to assign [io  size 0x1000]
Nov  9 16:32:37 debian8 kernel: [  142.369848] pci 0000:0e:04.0: BAR 13: no=
 space for [io  size 0x1000]
Nov  9 16:32:37 debian8 kernel: [  142.370080] pci 0000:0e:04.0: BAR 13: fa=
iled to assign [io  size 0x1000]
Nov  9 16:32:37 debian8 kernel: [  142.370324] pci 0000:0e:05.0: BAR 13: no=
 space for [io  size 0x1000]
Nov  9 16:32:37 debian8 kernel: [  142.370555] pci 0000:0e:05.0: BAR 13: fa=
iled to assign [io  size 0x1000]
Nov  9 16:32:37 debian8 kernel: [  142.370800] pci 0000:0e:06.0: BAR 13: no=
 space for [io  size 0x1000]
Nov  9 16:32:37 debian8 kernel: [  142.371031] pci 0000:0e:06.0: BAR 13: fa=
iled to assign [io  size 0x1000]
Nov  9 16:32:37 debian8 kernel: [  142.371275] pci 0000:0e:06.0: BAR 13: no=
 space for [io  size 0x1000]
Nov  9 16:32:37 debian8 kernel: [  142.371507] pci 0000:0e:06.0: BAR 13: fa=
iled to assign [io  size 0x1000]
Nov  9 16:32:37 debian8 kernel: [  142.371751] pci 0000:0e:05.0: BAR 13: no=
 space for [io  size 0x1000]
Nov  9 16:32:37 debian8 kernel: [  142.371987] pci 0000:0e:05.0: BAR 13: fa=
iled to assign [io  size 0x1000]
Nov  9 16:32:37 debian8 kernel: [  142.372231] pci 0000:0e:04.0: BAR 13: no=
 space for [io  size 0x1000]
Nov  9 16:32:37 debian8 kernel: [  142.372462] pci 0000:0e:04.0: BAR 13: fa=
iled to assign [io  size 0x1000]
Nov  9 16:32:37 debian8 kernel: [  142.372706] pci 0000:0e:03.0: BAR 13: no=
 space for [io  size 0x1000]
Nov  9 16:32:37 debian8 kernel: [  142.372938] pci 0000:0e:03.0: BAR 13: fa=
iled to assign [io  size 0x1000]
Nov  9 16:32:37 debian8 kernel: [  142.373182] pci 0000:0e:00.0: BAR 15: no=
 space for [mem size 0x00200000 64bit pref]
Nov  9 16:32:37 debian8 kernel: [  142.373460] pci 0000:0e:00.0: BAR 15: fa=
iled to assign [mem size 0x00200000 64bit pref]
Nov  9 16:32:37 debian8 kernel: [  142.373750] pci 0000:0e:00.0: BAR 13: no=
 space for [io  size 0x1000]
Nov  9 16:32:37 debian8 kernel: [  142.373981] pci 0000:0e:00.0: BAR 13: fa=
iled to assign [io  size 0x1000]
Nov  9 16:32:37 debian8 kernel: [  142.374225] pci 0000:0e:00.0: PCI bridge=
 to [bus 0f]
Nov  9 16:32:37 debian8 kernel: [  142.374412] pci 0000:0e:00.0:   bridge w=
indow [mem 0xde000000-0xde0fffff]
Nov  9 16:32:37 debian8 kernel: [  142.374667] pci 0000:0e:03.0: PCI bridge=
 to [bus 10-3a]
Nov  9 16:32:37 debian8 kernel: [  142.374863] pci 0000:0e:03.0:   bridge w=
indow [mem 0xb0000000-0xbfffffff]
Nov  9 16:32:37 debian8 kernel: [  142.375112] pci 0000:0e:03.0:   bridge w=
indow [mem 0x60000000-0x7fffffff 64bit pref]
Nov  9 16:32:37 debian8 kernel: [  142.375398] pci 0000:0e:04.0: PCI bridge=
 to [bus 3b-43]
Nov  9 16:32:37 debian8 kernel: [  142.375593] pci 0000:0e:04.0:   bridge w=
indow [mem 0xc0000000-0xc7ffffff]
Nov  9 16:32:37 debian8 kernel: [  142.375858] pci 0000:0e:04.0:   bridge w=
indow [mem 0x80000000-0x87ffffff 64bit pref]
Nov  9 16:32:37 debian8 kernel: [  142.376140] pci 0000:0e:05.0: PCI bridge=
 to [bus 44-6e]
Nov  9 16:32:37 debian8 kernel: [  142.376333] pci 0000:0e:05.0:   bridge w=
indow [mem 0xc8000000-0xd5ffffff]
Nov  9 16:32:37 debian8 kernel: [  142.376578] pci 0000:0e:05.0:   bridge w=
indow [mem 0x90000000-0xa9ffffff 64bit pref]
Nov  9 16:32:37 debian8 kernel: [  142.376860] pci 0000:0e:06.0: PCI bridge=
 to [bus 6f-77]
Nov  9 16:32:37 debian8 kernel: [  142.377052] pci 0000:0e:06.0:   bridge w=
indow [mem 0xd6000000-0xddffffff]
Nov  9 16:32:37 debian8 kernel: [  142.377298] pci 0000:0e:06.0:   bridge w=
indow [mem 0x88000000-0x8fffffff 64bit pref]
Nov  9 16:32:37 debian8 kernel: [  142.377580] pci 0000:0d:00.0: PCI bridge=
 to [bus 0e-77]
Nov  9 16:32:37 debian8 kernel: [  142.377772] pci 0000:0d:00.0:   bridge w=
indow [mem 0xb0000000-0xde0fffff]
Nov  9 16:32:37 debian8 kernel: [  142.378018] pci 0000:0d:00.0:   bridge w=
indow [mem 0x60000000-0xa9ffffff 64bit pref]
Nov  9 16:32:37 debian8 systemd[1]: Expecting device sys-module-thunderbolt=
=2Edevice...
Nov  9 16:32:37 debian8 systemd[1]: Starting Thunderbolt Manager...
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: Thunderbolt daemon versio=
n: 16.1.54.1-source      Thread: 140713088374592, func main line 72 (/home/=
sguinot/thunderbolt-software-daemon.git/daemon/ThunderboltService/Linux/thu=
nderbolt.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: Thunderbolt module versio=
n: 16.1.55.1      Thread: 140713088374592, func main line 73 (/home/sguinot=
/thunderbolt-software-daemon.git/daemon/ThunderboltService/Linux/thunderbol=
t.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: Starting initialization  =
    Thread: 140713088374592, func main line 74 (/home/sguinot/thunderbolt-s=
oftware-daemon.git/daemon/ThunderboltService/Linux/thunderbolt.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: subscribing driver      T=
hread: 140713088374592, func driver_subscribe line 145 (/home/sguinot/thund=
erbolt-software-daemon.git/daemon/ThunderboltService/Linux/src/GenlWrapper.=
cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: GenlWrapper::send_message=
_sync entry, sending netlink message: command only      Thread: 14071308837=
4592, func send_message_sync line 456 (/home/sguinot/thunderbolt-software-d=
aemon.git/daemon/ThunderboltService/Linux/src/GenlWrapper.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Debug: netlink message was allo=
cated      Thread: 140713088374592, func alloc_message line 134 (/home/sgui=
not/thunderbolt-software-daemon.git/daemon/ThunderboltService/Linux/src/Gen=
lWrapper.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: GenlWrapper::send_message=
_sync(struct nl_msg* msg) entry      Thread: 140713088374592, func send_mes=
sage_sync line 475 (/home/sguinot/thunderbolt-software-daemon.git/daemon/Th=
underboltService/Linux/src/GenlWrapper.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Send Message:
Nov  9 16:32:37 debian8 thunderboltd[1081]: --------------------------   BE=
GIN NETLINK MESSAGE ---------------------------
Nov  9 16:32:37 debian8 thunderboltd[1081]: [NETLINK HEADER] 16 octets
Nov  9 16:32:37 debian8 thunderboltd[1081]: .nlmsg_len =3D 24
Nov  9 16:32:37 debian8 thunderboltd[1081]: .type =3D 24 <0x18>
Nov  9 16:32:37 debian8 thunderboltd[1081]: .flags =3D 0 <>
Nov  9 16:32:37 debian8 thunderboltd[1081]: .seq =3D 0
Nov  9 16:32:37 debian8 thunderboltd[1081]: .port =3D 0
Nov  9 16:32:37 debian8 thunderboltd[1081]: [PAYLOAD] 8 octets
Nov  9 16:32:37 debian8 thunderboltd[1081]: 01 01 00 00 00 00 00 00        =
                 ........
Nov  9 16:32:37 debian8 thunderboltd[1081]: ---------------------------  EN=
D NETLINK MESSAGE   ---------------------------
Nov  9 16:32:37 debian8 systemd[1]: Started Thunderbolt Manager.
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: Netlink ACK received     =
  Thread: 140713062659840, func cb_ack line 260 (/home/sguinot/thunderbolt-=
software-daemon.git/daemon/ThunderboltService/Linux/src/GenlWrapper.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: GenlWrapper::send_message=
_sync(struct nl_msg* msg) exit      Thread: 140713088374592, func send_mess=
age_sync line 495 (/home/sguinot/thunderbolt-software-daemon.git/daemon/Thu=
nderboltService/Linux/src/GenlWrapper.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Debug: netlink message was free=
      Thread: 140713088374592, func operator() line 117 (/home/sguinot/thun=
derbolt-software-daemon.git/daemon/ThunderboltService/Linux/src/GenlWrapper=
=2Ecpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: GenlWrapper::send_message=
_sync exit, sending netlink message: command only      Thread: 140713088374=
592, func send_message_sync line 465 (/home/sguinot/thunderbolt-software-da=
emon.git/daemon/ThunderboltService/Linux/src/GenlWrapper.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: GenlWrapper::register_eve=
nts_callback entry      Thread: 140713088374592, func register_events_callb=
ack line 237 (/home/sguinot/thunderbolt-software-daemon.git/daemon/Thunderb=
oltService/Linux/src/GenlWrapper.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: GenlWrapper::register_eve=
nts_callback exit      Thread: 140713088374592, func register_events_callba=
ck line 239 (/home/sguinot/thunderbolt-software-daemon.git/daemon/Thunderbo=
ltService/Linux/src/GenlWrapper.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: GenlWrapper::cb_valid ent=
ry, message arrived      Thread: 140713062659840, func cb_valid line 270 (/=
home/sguinot/thunderbolt-software-daemon.git/daemon/ThunderboltService/Linu=
x/src/GenlWrapper.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: --------------------------   BE=
GIN NETLINK MESSAGE ---------------------------
Nov  9 16:32:37 debian8 thunderboltd[1081]: [NETLINK HEADER] 16 octets
Nov  9 16:32:37 debian8 thunderboltd[1081]: .nlmsg_len =3D 48
Nov  9 16:32:37 debian8 thunderboltd[1081]: .type =3D 24 <0x18>
Nov  9 16:32:37 debian8 thunderboltd[1081]: .flags =3D 0 <>
Nov  9 16:32:37 debian8 thunderboltd[1081]: .seq =3D 0
Nov  9 16:32:37 debian8 thunderboltd[1081]: .port =3D 1081
Nov  9 16:32:37 debian8 thunderboltd[1081]: [GENERIC NETLINK HEADER] 4 octe=
ts
Nov  9 16:32:37 debian8 thunderboltd[1081]: .cmd =3D 5
Nov  9 16:32:37 debian8 thunderboltd[1081]: .version =3D 1
Nov  9 16:32:37 debian8 thunderboltd[1081]: .unused =3D 0
Nov  9 16:32:37 debian8 thunderboltd[1081]: [PAYLOAD] 28 octets
Nov  9 16:32:37 debian8 thunderboltd[1081]: 6c 15 00 0f 08 00 07 00 0c 00 0=
0 00 10 00 09 00 l...............
Nov  9 16:32:37 debian8 thunderboltd[1081]: 01 00 0a 03 00 00 0a 50 3e fa a=
d aa             .......P>...
Nov  9 16:32:37 debian8 thunderboltd[1081]: ---------------------------  EN=
D NETLINK MESSAGE   ---------------------------
Nov  9 16:32:37 debian8 thunderboltd[1081]: Debug: validate netlink message=
: PASS      Thread: 140713062659840, func cb_valid line 291 (/home/sguinot/=
thunderbolt-software-daemon.git/daemon/ThunderboltService/Linux/src/GenlWra=
pper.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Debug: LinuxControllerCommandSe=
nder::OnEvent entry, PDF: 12      Thread: 140713062659840, func OnEvent lin=
e 63 (/home/sguinot/thunderbolt-software-daemon.git/daemon/ThunderboltServi=
ce/Linux/src/LinuxControllerCommandSender.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Debug: Message from FW: PDF_FW_=
TO_SW_RESPONSE, Controller: f00156c      Thread: 140713062659840, func OnEv=
ent line 79 (/home/sguinot/thunderbolt-software-daemon.git/daemon/Thunderbo=
ltService/Linux/src/LinuxControllerCommandSender.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: FW response: DRIVER_READY=
_RESPONSE, Controller: 0f00156c      Thread: 140713062659840, func HandleFw=
ToSwResponse line 42 (/home/sguinot/thunderbolt-software-daemon.git/daemon/=
ThunderboltService/Linux/src/MessageFromFwEvent.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: New controller detected: =
0f00156c       Thread: 140713062659840, func OnDriverReadyResponse line 103=
 (/home/sguinot/thunderbolt-software-daemon.git/daemon/ThunderboltService/S=
hared/src/ConnectionManagerBase.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Debug: Create new controller cl=
ass      Thread: 140713062659840, func OnDriverReadyResponse line 107 (/hom=
e/sguinot/thunderbolt-software-daemon.git/daemon/ThunderboltService/Shared/=
src/ConnectionManagerBase.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: GetGenerationFromControll=
erID devID=3D156c      Thread: 140713062659840, func GetGenerationFromContr=
ollerID line 136 (/home/sguinot/thunderbolt-software-daemon.git/daemon/Thun=
derboltService/Shared/src/Utils.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: GetNomOfPortsFromControll=
erID devID=3D156c      Thread: 140713062659840, func GetNomOfPortsFromContr=
ollerID line 113 (/home/sguinot/thunderbolt-software-daemon.git/daemon/Thun=
derboltService/Shared/src/Utils.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: Controller device ID: 156=
C, TBT generation: 2, port count: 2, security level: 0      Thread: 1407130=
62659840, func OnDriverReadyResponse line 121 (/home/sguinot/thunderbolt-so=
ftware-daemon.git/daemon/ThunderboltService/Shared/src/ConnectionManagerBas=
e.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: Controller settings: Cert=
ified only: False, Override first depth: True, Allow dock at any depth: Fal=
se      Thread: 140713062659840, func OnDriverReadyResponse line 124 (/home=
/sguinot/thunderbolt-software-daemon.git/daemon/ThunderboltService/Shared/s=
rc/ConnectionManagerBase.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: Netlink message received =
     Thread: 140713062659840, func OnEvent line 116 (/home/sguinot/thunderb=
olt-software-daemon.git/daemon/ThunderboltService/Linux/src/LinuxController=
CommandSender.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Debug: LinuxControllerCommandSe=
nder::OnEvent exit, PDF: 12      Thread: 140713062659840, func OnEvent line=
 121 (/home/sguinot/thunderbolt-software-daemon.git/daemon/ThunderboltServi=
ce/Linux/src/LinuxControllerCommandSender.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: GenlWrapper::cb_valid exi=
t, message arrived      Thread: 140713062659840, func cb_valid line 362 (/h=
ome/sguinot/thunderbolt-software-daemon.git/daemon/ThunderboltService/Linux=
/src/GenlWrapper.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: GenlWrapper::send_message=
_sync entry, sending netlink message: command only      Thread: 14071305426=
7136, func send_message_sync line 456 (/home/sguinot/thunderbolt-software-d=
aemon.git/daemon/ThunderboltService/Linux/src/GenlWrapper.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Debug: netlink message was allo=
cated      Thread: 140713054267136, func alloc_message line 134 (/home/sgui=
not/thunderbolt-software-daemon.git/daemon/ThunderboltService/Linux/src/Gen=
lWrapper.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: GenlWrapper::send_message=
_sync(struct nl_msg* msg) entry      Thread: 140713054267136, func send_mes=
sage_sync line 475 (/home/sguinot/thunderbolt-software-daemon.git/daemon/Th=
underboltService/Linux/src/GenlWrapper.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Send Message:
Nov  9 16:32:37 debian8 thunderboltd[1081]: --------------------------   BE=
GIN NETLINK MESSAGE ---------------------------
Nov  9 16:32:37 debian8 thunderboltd[1081]: [NETLINK HEADER] 16 octets
Nov  9 16:32:37 debian8 thunderboltd[1081]: .nlmsg_len =3D 24
Nov  9 16:32:37 debian8 thunderboltd[1081]: .type =3D 24 <0x18>
Nov  9 16:32:37 debian8 thunderboltd[1081]: .flags =3D 0 <>
Nov  9 16:32:37 debian8 thunderboltd[1081]: .seq =3D 0
Nov  9 16:32:37 debian8 thunderboltd[1081]: .port =3D 0
Nov  9 16:32:37 debian8 thunderboltd[1081]: [PAYLOAD] 8 octets
Nov  9 16:32:37 debian8 thunderboltd[1081]: 03 01 00 00 6c 15 00 0f        =
                 ....l...
Nov  9 16:32:37 debian8 thunderboltd[1081]: ---------------------------  EN=
D NETLINK MESSAGE   ---------------------------
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: GenlWrapper::cb_valid ent=
ry, message arrived      Thread: 140713062659840, func cb_valid line 270 (/=
home/sguinot/thunderbolt-software-daemon.git/daemon/ThunderboltService/Linu=
x/src/GenlWrapper.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: --------------------------   BE=
GIN NETLINK MESSAGE ---------------------------
Nov  9 16:32:37 debian8 thunderboltd[1081]: [NETLINK HEADER] 16 octets
Nov  9 16:32:37 debian8 thunderboltd[1081]: .nlmsg_len =3D 64
Nov  9 16:32:37 debian8 thunderboltd[1081]: .type =3D 24 <0x18>
Nov  9 16:32:37 debian8 thunderboltd[1081]: .flags =3D 0 <>
Nov  9 16:32:37 debian8 thunderboltd[1081]: .seq =3D 1478705559
Nov  9 16:32:37 debian8 thunderboltd[1081]: .port =3D 1081
Nov  9 16:32:37 debian8 thunderboltd[1081]: [GENERIC NETLINK HEADER] 4 octe=
ts
Nov  9 16:32:37 debian8 thunderboltd[1081]: .cmd =3D 3
Nov  9 16:32:37 debian8 thunderboltd[1081]: .version =3D 1
Nov  9 16:32:37 debian8 thunderboltd[1081]: .unused =3D 0
Nov  9 16:32:37 debian8 thunderboltd[1081]: [PAYLOAD] 44 octets
Nov  9 16:32:37 debian8 thunderboltd[1081]: 6c 15 00 0f 0e 00 01 00 31 36 2=
e 31 2e 35 35 2e l.......16.1.55.
Nov  9 16:32:37 debian8 thunderboltd[1081]: 31 00 00 00 06 00 02 00 0a 00 0=
0 00 05 00 03 00 1...............
Nov  9 16:32:37 debian8 thunderboltd[1081]: 02 00 00 00 05 00 04 00 05 00 0=
0 00             ............
Nov  9 16:32:37 debian8 thunderboltd[1081]: ---------------------------  EN=
D NETLINK MESSAGE   ---------------------------
Nov  9 16:32:37 debian8 thunderboltd[1081]: Debug: validate netlink message=
: PASS      Thread: 140713062659840, func cb_valid line 291 (/home/sguinot/=
thunderbolt-software-daemon.git/daemon/ThunderboltService/Linux/src/GenlWra=
pper.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Debug: LinuxControllerCommandSe=
nder::OnEvent entry, PDF: -1      Thread: 140713062659840, func OnEvent lin=
e 63 (/home/sguinot/thunderbolt-software-daemon.git/daemon/ThunderboltServi=
ce/Linux/src/LinuxControllerCommandSender.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: Netlink message received =
=66rom Driver      Thread: 140713062659840, func OnEvent line 99 (/home/sgu=
inot/thunderbolt-software-daemon.git/daemon/ThunderboltService/Linux/src/Li=
nuxControllerCommandSender.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: GetGenerationFromControll=
erID devID=3D156c      Thread: 140713062659840, func GetGenerationFromContr=
ollerID line 136 (/home/sguinot/thunderbolt-software-daemon.git/daemon/Thun=
derboltService/Shared/src/Utils.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: GetNomOfPortsFromControll=
erID devID=3D156c      Thread: 140713062659840, func GetNomOfPortsFromContr=
ollerID line 113 (/home/sguinot/thunderbolt-software-daemon.git/daemon/Thun=
derboltService/Shared/src/Utils.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: Netlink message received =
     Thread: 140713062659840, func OnEvent line 116 (/home/sguinot/thunderb=
olt-software-daemon.git/daemon/ThunderboltService/Linux/src/LinuxController=
CommandSender.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Debug: LinuxControllerCommandSe=
nder::OnEvent exit, PDF: -1      Thread: 140713062659840, func OnEvent line=
 121 (/home/sguinot/thunderbolt-software-daemon.git/daemon/ThunderboltServi=
ce/Linux/src/LinuxControllerCommandSender.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: GenlWrapper::cb_valid exi=
t, message arrived      Thread: 140713062659840, func cb_valid line 362 (/h=
ome/sguinot/thunderbolt-software-daemon.git/daemon/ThunderboltService/Linux=
/src/GenlWrapper.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: Netlink ACK received     =
  Thread: 140713062659840, func cb_ack line 260 (/home/sguinot/thunderbolt-=
software-daemon.git/daemon/ThunderboltService/Linux/src/GenlWrapper.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: GenlWrapper::send_message=
_sync(struct nl_msg* msg) exit      Thread: 140713054267136, func send_mess=
age_sync line 495 (/home/sguinot/thunderbolt-software-daemon.git/daemon/Thu=
nderboltService/Linux/src/GenlWrapper.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Debug: netlink message was free=
      Thread: 140713054267136, func operator() line 117 (/home/sguinot/thun=
derbolt-software-daemon.git/daemon/ThunderboltService/Linux/src/GenlWrapper=
=2Ecpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: GenlWrapper::send_message=
_sync exit, sending netlink message: command only      Thread: 140713054267=
136, func send_message_sync line 465 (/home/sguinot/thunderbolt-software-da=
emon.git/daemon/ThunderboltService/Linux/src/GenlWrapper.cpp)
Nov  9 16:32:37 debian8 thunderboltd[1081]: Info: Daemon is running...     =
 Thread: 140713088374592, func main line 89 (/home/sguinot/thunderbolt-soft=
ware-daemon.git/daemon/ThunderboltService/Linux/thunderbolt.cpp)

--kadn00tgSopKmJ1H--

--mYYhpFXgKVw71fwr
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlgjNHAACgkQgtp0PDeOcDqszgCeNBmHZnM8TVjuU6wZWd8wiwVY
85IAmgI8874jdWlMh74Wrl0poUqrB/1V
=JIYc
-----END PGP SIGNATURE-----

--mYYhpFXgKVw71fwr--
