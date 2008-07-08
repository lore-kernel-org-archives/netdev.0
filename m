From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 11/25] ixgb: update readme text
Date: Tue, 08 Jul 2008 15:51:57 -0700
Message-ID: <20080708225157.6925.18516.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15354 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753144AbYGHWwD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:52:03 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 Documentation/networking/ixgb.txt |  419 ++++++++++++++++++++++++++++-=
--------
 1 files changed, 320 insertions(+), 99 deletions(-)

diff --git a/Documentation/networking/ixgb.txt b/Documentation/networki=
ng/ixgb.txt
index 7c98277..a0d0ffb 100644
--- a/Documentation/networking/ixgb.txt
+++ b/Documentation/networking/ixgb.txt
@@ -1,7 +1,7 @@
-Linux* Base Driver for the Intel(R) PRO/10GbE Family of Adapters
-=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+Linux Base Driver for 10 Gigabit Intel(R) Network Connection
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
-November 17, 2004
+October 9, 2007
=20
=20
 Contents
@@ -9,94 +9,151 @@ Contents
=20
 - In This Release
 - Identifying Your Adapter
+- Building and Installation
 - Command Line Parameters
 - Improving Performance
+- Additional Configurations
+- Known Issues/Troubleshooting
 - Support
=20
=20
+
 In This Release
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
-This file describes the Linux* Base Driver for the Intel(R) PRO/10GbE =
=46amily=20
-of Adapters, version 1.0.x. =20
+This file describes the ixgb Linux Base Driver for the 10 Gigabit Inte=
l(R)
+Network Connection.  This driver includes support for Itanium(R)2-base=
d
+systems.
+
+For questions related to hardware requirements, refer to the documenta=
tion
+supplied with your 10 Gigabit adapter.  All hardware requirements list=
ed apply
+to use with Linux.
+
+The following features are available in this kernel:
+ - Native VLANs
+ - Channel Bonding (teaming)
+ - SNMP
+
+Channel Bonding documentation can be found in the Linux kernel source:
+/Documentation/networking/bonding.txt
+
+The driver information previously displayed in the /proc filesystem is=
 not
+supported in this release.  Alternatively, you can use ethtool (versio=
n 1.6
+or later), lspci, and ifconfig to obtain the same information.
+
+Instructions on updating ethtool can be found in the section "Addition=
al
+Configurations" later in this document.
=20
-For questions related to hardware requirements, refer to the documenta=
tion=20
-supplied with your Intel PRO/10GbE adapter. All hardware requirements =
listed=20
-apply to use with Linux.
=20
 Identifying Your Adapter
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
-To verify your Intel adapter is supported, find the board ID number on=
 the=20
-adapter. Look for a label that has a barcode and a number in the forma=
t =20
-A12345-001.=20
+The following Intel network adapters are compatible with the drivers i=
n this
+release:
+
+Controller  Adapter Name                 Physical Layer
+----------  ------------                 --------------
+82597EX     Intel(R) PRO/10GbE LR/SR/CX4 10G Base-LR (1310 nm optical =
fiber)
+            Server Adapters              10G Base-SR (850 nm optical f=
iber)
+                                         10G Base-CX4(twin-axial coppe=
r cabling)
+
+For more information on how to identify your adapter, go to the Adapte=
r &
+Driver ID Guide at:
+
+    http://support.intel.com/support/network/sb/CS-012904.htm
+
+
+Building and Installation
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
+
+select m for "Intel(R) PRO/10GbE support" located at:
+      Location:
+        -> Device Drivers
+          -> Network device support (NETDEVICES [=3Dy])
+            -> Ethernet (10000 Mbit) (NETDEV_10000 [=3Dy])
+1. make modules && make modules_install
+
+2. Load the module:
+
+=C2=A0=C2=A0=C2=A0=C2=A0modprobe ixgb <parameter>=3D<value>
+
+   The insmod command can be used if the full
+   path to the driver module is specified.  For example:
+
+     insmod /lib/modules/<KERNEL VERSION>/kernel/drivers/net/ixgb/ixgb=
=2Eko
+
+   With 2.6 based kernels also make sure that older ixgb drivers are
+   removed from the kernel, before loading the new module:
=20
-Use the above information and the Adapter & Driver ID Guide at:
+     rmmod ixgb; modprobe ixgb
=20
-  http://support.intel.com/support/network/adapter/pro100/21397.htm
+3. Assign an IP address to the interface by entering the following, wh=
ere
+   x is the interface number:
=20
-For the latest Intel network drivers for Linux, go to:
+     ifconfig ethx <IP_address>
+
+4. Verify that the interface works. Enter the following, where <IP_add=
ress>
+   is the IP address for another machine on the same subnet as the int=
erface
+   that is being tested:
+
+     ping  <IP_address>
=20
-    http://downloadfinder.intel.com/scripts-df/support_intel.asp
=20
 Command Line Parameters
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
-If the driver is built as a module, the  following optional parameters=
 are=20
-used by entering them on the command line with the modprobe or insmod =
command
-using this syntax:
+If the driver is built as a module, the  following optional parameters=
 are
+used by entering them on the command line with the modprobe command us=
ing
+this syntax:
=20
      modprobe ixgb [<option>=3D<VAL1>,<VAL2>,...]
=20
-     insmod ixgb [<option>=3D<VAL1>,<VAL2>,...]
+For example, with two 10GbE PCI adapters, entering:
=20
-For example, with two PRO/10GbE PCI adapters, entering:
+     modprobe ixgb TxDescriptors=3D80,128
=20
-    insmod ixgb TxDescriptors=3D80,128
-
-loads the ixgb driver with 80 TX resources for the first adapter and 1=
28 TX=20
+loads the ixgb driver with 80 TX resources for the first adapter and 1=
28 TX
 resources for the second adapter.
=20
 The default value for each parameter is generally the recommended sett=
ing,
-unless otherwise noted. Also, if the driver is statically built into t=
he
-kernel, the driver is loaded with the default values for all the param=
eters.
-Ethtool can be used to change some of the parameters at runtime.
+unless otherwise noted.
=20
 FlowControl
 Valid Range: 0-3 (0=3Dnone, 1=3DRx only, 2=3DTx only, 3=3DRx&Tx)
 Default: Read from the EEPROM
-         If EEPROM is not detected, default is 3
-    This parameter controls the automatic generation(Tx) and response(=
Rx) to=20
-    Ethernet PAUSE frames.
+         If EEPROM is not detected, default is 1
+    This parameter controls the automatic generation(Tx) and response(=
Rx) to
+    Ethernet PAUSE frames.  There are hardware bugs associated with en=
abling
+    Tx flow control so beware.
=20
 RxDescriptors
 Valid Range: 64-512
 Default Value: 512
-    This value is the number of receive descriptors allocated by the d=
river.=20
-    Increasing this value allows the driver to buffer more incoming pa=
ckets.=20
-    Each descriptor is 16 bytes.  A receive buffer is also allocated f=
or=20
-    each descriptor and can be either 2048, 4056, 8192, or 16384 bytes=
,=20
-    depending on the MTU setting. When the MTU size is 1500 or less, t=
he=20
+    This value is the number of receive descriptors allocated by the d=
river.
+    Increasing this value allows the driver to buffer more incoming pa=
ckets.
+    Each descriptor is 16 bytes.  A receive buffer is also allocated f=
or
+    each descriptor and can be either 2048, 4056, 8192, or 16384 bytes=
,
+    depending on the MTU setting.  When the MTU size is 1500 or less, =
the
     receive buffer size is 2048 bytes. When the MTU is greater than 15=
00 the
-    receive buffer size will be either 4056, 8192, or 16384 bytes. The=
=20
+    receive buffer size will be either 4056, 8192, or 16384 bytes.  Th=
e
     maximum MTU size is 16114.
=20
 RxIntDelay
 Valid Range: 0-65535 (0=3Doff)
-Default Value: 6
-    This value delays the generation of receive interrupts in units of=
=20
-    0.8192 microseconds.  Receive interrupt reduction can improve CPU=20
-    efficiency if properly tuned for specific network traffic. Increas=
ing=20
-    this value adds extra latency to frame reception and can end up=20
-    decreasing the throughput of TCP traffic. If the system is reporti=
ng=20
-    dropped receives, this value may be set too high, causing the driv=
er to=20
+Default Value: 72
+    This value delays the generation of receive interrupts in units of
+    0.8192 microseconds.  Receive interrupt reduction can improve CPU
+    efficiency if properly tuned for specific network traffic.  Increa=
sing
+    this value adds extra latency to frame reception and can end up
+    decreasing the throughput of TCP traffic.  If the system is report=
ing
+    dropped receives, this value may be set too high, causing the driv=
er to
     run out of available receive descriptors.
=20
 TxDescriptors
 Valid Range: 64-4096
 Default Value: 256
     This value is the number of transmit descriptors allocated by the =
driver.
-    Increasing this value allows the driver to queue more transmits. E=
ach=20
+    Increasing this value allows the driver to queue more transmits.  =
Each
     descriptor is 16 bytes.
=20
 XsumRX
@@ -105,51 +162,49 @@ Default Value: 1
     A value of '1' indicates that the driver should enable IP checksum
     offload for received packets (both UDP and TCP) to the adapter har=
dware.
=20
-XsumTX
-Valid Range: 0-1
-Default Value: 1
-    A value of '1' indicates that the driver should enable IP checksum
-    offload for transmitted packets (both UDP and TCP) to the adapter=20
-    hardware.
=20
 Improving Performance
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
-With the Intel PRO/10 GbE adapter, the default Linux configuration wil=
l very=20
-likely limit the total available throughput artificially.  There is a =
set of=20
-things that when applied together increase the ability of Linux to tra=
nsmit=20
-and receive data.  The following enhancements were originally acquired=
 from
-settings published at http://www.spec.org/web99 for various submitted =
results=20
-using Linux.
+With the 10 Gigabit server adapters, the default Linux configuration w=
ill
+very likely limit the total available throughput artificially.  There =
is a set
+of configuration changes that, when applied together, will increase th=
e ability
+of Linux to transmit and receive data.  The following enhancements wer=
e
+originally acquired from settings published at http://www.spec.org/web=
99/ for
+various submitted results using Linux.
=20
-NOTE: These changes are only suggestions, and serve as a starting poin=
t for=20
-tuning your network performance.
+NOTE: These changes are only suggestions, and serve as a starting poin=
t for
+      tuning your network performance.
=20
 The changes are made in three major ways, listed in order of greatest =
effect:
-- Use ifconfig to modify the mtu (maximum transmission unit) and the t=
xqueuelen=20
+- Use ifconfig to modify the mtu (maximum transmission unit) and the t=
xqueuelen
   parameter.
 - Use sysctl to modify /proc parameters (essentially kernel tuning)
-- Use setpci to modify the MMRBC field in PCI-X configuration space to=
 increase=20
+- Use setpci to modify the MMRBC field in PCI-X configuration space to=
 increase
   transmit burst lengths on the bus.
=20
-NOTE: setpci modifies the adapter's configuration registers to allow i=
t to read=20
-up to 4k bytes at a time (for transmits).  However, for some systems t=
he=20
-behavior after modifying this register may be undefined (possibly erro=
rs of some=20
-kind). A power-cycle, hard reset or explicitly setting the e6 register=
 back to=20
-22 (setpci -d 8086:1048 e6.b=3D22) may be required to get back to a st=
able=20
-configuration.
+NOTE: setpci modifies the adapter's configuration registers to allow i=
t to read
+up to 4k bytes at a time (for transmits).  However, for some systems t=
he
+behavior after modifying this register may be undefined (possibly erro=
rs of
+some kind).  A power-cycle, hard reset or explicitly setting the e6 re=
gister
+back to 22 (setpci -d 8086:1a48 e6.b=3D22) may be required to get back=
 to a
+stable configuration.
=20
 - COPY these lines and paste them into ixgb_perf.sh:
 #!/bin/bash
-echo "configuring network performance , edit this file to change the i=
nterface"
+echo "configuring network performance , edit this file to change the i=
nterface
+or device ID of 10GbE card"
 # set mmrbc to 4k reads, modify only Intel 10GbE device IDs
-setpci -d 8086:1048 e6.b=3D2e
-# set the MTU (max transmission unit) - it requires your switch and cl=
ients to change too!
+# replace 1a48 with appropriate 10GbE device's ID installed on the sys=
tem,
+# if needed.
+setpci -d 8086:1a48 e6.b=3D2e
+# set the MTU (max transmission unit) - it requires your switch and cl=
ients
+# to change as well.
 # set the txqueuelen
 # your ixgb adapter should be loaded as eth1 for this to work, change =
if needed
 ifconfig eth1 mtu 9000 txqueuelen 1000 up
-# call the sysctl utility to modify /proc/sys entries=20
-sysctl -p ./sysctl_ixgb.conf=20
+# call the sysctl utility to modify /proc/sys entries
+sysctl -p ./sysctl_ixgb.conf
 - END ixgb_perf.sh
=20
 - COPY these lines and paste them into sysctl_ixgb.conf:
@@ -159,54 +214,220 @@ sysctl -p ./sysctl_ixgb.conf
 # several network benchmark tests, your mileage may vary
=20
 ### IPV4 specific settings
-net.ipv4.tcp_timestamps =3D 0 # turns TCP timestamp support off, defau=
lt 1, reduces CPU use
-net.ipv4.tcp_sack =3D 0 # turn SACK support off, default on
-# on systems with a VERY fast bus -> memory interface this is the big =
gainer=20
-net.ipv4.tcp_rmem =3D 10000000 10000000 10000000 # sets min/default/ma=
x TCP read buffer, default 4096 87380 174760
-net.ipv4.tcp_wmem =3D 10000000 10000000 10000000 # sets min/pressure/m=
ax TCP write buffer, default 4096 16384 131072
-net.ipv4.tcp_mem =3D 10000000 10000000 10000000 # sets min/pressure/ma=
x TCP buffer space, default 31744 32256 32768
+# turn TCP timestamp support off, default 1, reduces CPU use
+net.ipv4.tcp_timestamps =3D 0
+# turn SACK support off, default on
+# on systems with a VERY fast bus -> memory interface this is the big =
gainer
+net.ipv4.tcp_sack =3D 0
+# set min/default/max TCP read buffer, default 4096 87380 174760
+net.ipv4.tcp_rmem =3D 10000000 10000000 10000000
+# set min/pressure/max TCP write buffer, default 4096 16384 131072
+net.ipv4.tcp_wmem =3D 10000000 10000000 10000000
+# set min/pressure/max TCP buffer space, default 31744 32256 32768
+net.ipv4.tcp_mem =3D 10000000 10000000 10000000
=20
 ### CORE settings (mostly for socket and UDP effect)
-net.core.rmem_max =3D 524287 # maximum receive socket buffer size, def=
ault 131071
-net.core.wmem_max =3D 524287 # maximum send socket buffer size, defaul=
t 131071
-net.core.rmem_default =3D 524287 # default receive socket buffer size,=
 default 65535
-net.core.wmem_default =3D 524287 # default send socket buffer size, de=
fault 65535
-net.core.optmem_max =3D 524287 # maximum amount of option memory buffe=
rs, default 10240
-net.core.netdev_max_backlog =3D 300000 # number of unprocessed input p=
ackets before kernel starts dropping them, default 300
+# set maximum receive socket buffer size, default 131071
+net.core.rmem_max =3D 524287
+# set maximum send socket buffer size, default 131071
+net.core.wmem_max =3D 524287
+# set default receive socket buffer size, default 65535
+net.core.rmem_default =3D 524287
+# set default send socket buffer size, default 65535
+net.core.wmem_default =3D 524287
+# set maximum amount of option memory buffers, default 10240
+net.core.optmem_max =3D 524287
+# set number of unprocessed input packets before kernel starts droppin=
g them; default 300
+net.core.netdev_max_backlog =3D 300000
 - END sysctl_ixgb.conf
=20
-Edit the ixgb_perf.sh script if necessary to change eth1 to whatever i=
nterface=20
-your ixgb driver is using.
+Edit the ixgb_perf.sh script if necessary to change eth1 to whatever i=
nterface
+your ixgb driver is using and/or replace '1a48' with appropriate 10GbE=
 device's
+ID installed on the system.
=20
-NOTE: Unless these scripts are added to the boot process, these change=
s will=20
-only last only until the next system reboot.
+NOTE: Unless these scripts are added to the boot process, these change=
s will
+      only last only until the next system reboot.
=20
=20
 Resolving Slow UDP Traffic
 --------------------------
+If your server does not seem to be able to receive UDP traffic as fast=
 as it
+can receive TCP traffic, it could be because Linux, by default, does n=
ot set
+the network stack buffers as large as they need to be to support high =
UDP
+transfer rates.  One way to alleviate this problem is to allow more me=
mory to
+be used by the IP stack to store incoming data.
=20
-If your server does not seem to be able to receive UDP traffic as fast=
 as it=20
-can receive TCP traffic, it could be because Linux, by default, does n=
ot set=20
-the network stack buffers as large as they need to be to support high =
UDP=20
-transfer rates. One way to alleviate this problem is to allow more mem=
ory to=20
-be used by the IP stack to store incoming data.=20
-
-For instance, use the commands:=20
+For instance, use the commands:
     sysctl -w net.core.rmem_max=3D262143
 and
     sysctl -w net.core.rmem_default=3D262143
-to increase the read buffer memory max and default to 262143 (256k - 1=
) from=20
-defaults of max=3D131071 (128k - 1) and default=3D65535 (64k - 1). The=
se variables=20
-will increase the amount of memory used by the network stack for recei=
ves, and=20
+to increase the read buffer memory max and default to 262143 (256k - 1=
) from
+defaults of max=3D131071 (128k - 1) and default=3D65535 (64k - 1).  Th=
ese variables
+will increase the amount of memory used by the network stack for recei=
ves, and
 can be increased significantly more if necessary for your application.
=20
+
+Additional Configurations
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
+
+  Configuring the Driver on Different Distributions
+  -------------------------------------------------
+  Configuring a network driver to load properly when the system is sta=
rted is
+  distribution dependent. Typically, the configuration process involve=
s adding
+  an alias line to /etc/modprobe.conf as well as editing other system =
startup
+  scripts and/or configuration files.  Many popular Linux distribution=
s ship
+  with tools to make these changes for you.  To learn the proper way t=
o
+  configure a network device for your system, refer to your distributi=
on
+  documentation.  If during this process you are asked for the driver =
or module
+  name, the name for the Linux Base Driver for the Intel 10GbE Family =
of
+  Adapters is ixgb.
+
+  Viewing Link Messages
+  ---------------------
+  Link messages will not be displayed to the console if the distributi=
on is
+  restricting system messages. In order to see network driver link mes=
sages on
+  your console, set dmesg to eight by entering the following:
+
+       dmesg -n 8
+
+  NOTE: This setting is not saved across reboots.
+
+
+  Jumbo Frames
+  ------------
+  The driver supports Jumbo Frames for all adapters. Jumbo Frames supp=
ort is
+  enabled by changing the MTU to a value larger than the default of 15=
00.
+  The maximum value for the MTU is 16114.  Use the ifconfig command to
+  increase the MTU size.  For example:
+
+        ifconfig ethx mtu 9000 up
+
+  The maximum MTU setting for Jumbo Frames is 16114.  This value coinc=
ides
+  with the maximum Jumbo Frames size of 16128.
+
+
+  Ethtool
+  -------
+  The driver utilizes the ethtool interface for driver configuration a=
nd
+  diagnostics, as well as displaying statistical information.  Ethtool
+  version 1.6 or later is required for this functionality.
+
+  The latest release of ethtool can be found from
+  http://sourceforge.net/projects/gkernel
+
+  NOTE: Ethtool 1.6 only supports a limited set of ethtool options. Su=
pport
+        for a more complete ethtool feature set can be enabled by upgr=
ading
+        to the latest version.
+
+
+  NAPI
+  ----
+
+  NAPI (Rx polling mode) is supported in the ixgb driver.  NAPI is ena=
bled
+  or disabled based on the configuration of the kernel.  see CONFIG_IX=
GB_NAPI
+
+  See www.cyberus.ca/~hadi/usenix-paper.tgz for more information on NA=
PI.
+
+
+Known Issues/Troubleshooting
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
+
+  NOTE: After installing the driver, if your Intel Network Connection =
is not
+  working, verify in the "In This Release" section of the readme that =
you have
+  installed the correct driver.
+
+  Intel(R) PRO/10GbE CX4 Server Adapter Cable Interoperability Issue w=
ith
+  Fujitsu XENPAK Module in SmartBits Chassis
+  --------------------------------------------------------------------=
-
+  Excessive CRC errors may be observed if the Intel(R) PRO/10GbE CX4
+  Server adapter is connected to a Fujitsu XENPAK CX4 module in a Smar=
tBits
+  chassis using 15 m/24AWG cable assemblies manufactured by Fujitsu or=
 Leoni.
+  The CRC errors may be received either by the Intel(R) PRO/10GbE CX4
+  Server adapter or the SmartBits. If this situation occurs using a di=
fferent
+  cable assembly may resolve the issue.
+
+  CX4 Server Adapter Cable Interoperability Issues with HP Procurve 34=
00cl
+  Switch Port
+  --------------------------------------------------------------------=
----
+  Excessive CRC errors may be observed if the Intel(R) PRO/10GbE CX4 S=
erver
+  adapter is connected to an HP Procurve 3400cl switch port using shor=
t cables
+  (1 m or shorter). If this situation occurs, using a longer cable may=
 resolve
+  the issue.
+
+  Excessive CRC errors may be observed using Fujitsu 24AWG cable assem=
blies that
+  Are 10 m or longer or where using a Leoni 15 m/24AWG cable assembly.=
 The CRC
+  errors may be received either by the CX4 Server adapter or at the sw=
itch. If
+  this situation occurs, using a different cable assembly may resolve =
the issue.
+
+
+  Jumbo Frames System Requirement
+  -------------------------------
+  Memory allocation failures have been observed on Linux systems with =
64 MB
+  of RAM or less that are running Jumbo Frames.  If you are using Jumb=
o
+  Frames, your system may require more than the advertised minimum
+  requirement of 64 MB of system memory.
+
+
+  Performance Degradation with Jumbo Frames
+  -----------------------------------------
+  Degradation in throughput performance may be observed in some Jumbo =
frames
+  environments.  If this is observed, increasing the application's soc=
ket buffer
+  size and/or increasing the /proc/sys/net/ipv4/tcp_*mem entry values =
may help.
+  See the specific application manual and /usr/src/linux*/Documentatio=
n/
+  networking/ip-sysctl.txt for more details.
+
+
+  Allocating Rx Buffers when Using Jumbo Frames
+  ---------------------------------------------
+  Allocating Rx buffers when using Jumbo Frames on 2.6.x kernels may f=
ail if
+  the available memory is heavily fragmented. This issue may be seen w=
ith PCI-X
+  adapters or with packet split disabled. This can be reduced or elimi=
nated
+  by changing the amount of available memory for receive buffer alloca=
tion, by
+  increasing /proc/sys/vm/min_free_kbytes.
+
+
+  Multiple Interfaces on Same Ethernet Broadcast Network
+  ------------------------------------------------------
+  Due to the default ARP behavior on Linux, it is not possible to have
+  one system on two IP networks in the same Ethernet broadcast domain
+  (non-partitioned switch) behave as expected.  All Ethernet interface=
s
+  will respond to IP traffic for any IP address assigned to the system=
=2E
+  This results in unbalanced receive traffic.
+
+  If you have multiple interfaces in a server, do either of the follow=
ing:
+
+  - Turn on ARP filtering by entering:
+      echo 1 > /proc/sys/net/ipv4/conf/all/arp_filter
+
+  - Install the interfaces in separate broadcast domains - either in
+    different switches or in a switch partitioned to VLANs.
+
+
+  UDP Stress Test Dropped Packet Issue
+  --------------------------------------
+  Under small packets UDP stress test with 10GbE driver, the Linux sys=
tem
+  may drop UDP packets due to the fullness of socket buffers. You may =
want
+  to change the driver's Flow Control variables to the minimum value f=
or
+  controlling packet reception.
+
+
+  Tx Hangs Possible Under Stress
+  ------------------------------
+  Under stress conditions, if TX hangs occur, turning off TSO
+  "ethtool -K eth0 tso off" may resolve the problem.
+
+
 Support
 =3D=3D=3D=3D=3D=3D=3D
=20
-For general information and support, go to the Intel support website a=
t:
+For general information, go to the Intel support website at:
=20
     http://support.intel.com
=20
+or the Intel Wired Networking project hosted by Sourceforge at:
+
+    http://sourceforge.net/projects/e1000
+
 If an issue is identified with the released source code on the support=
ed
-kernel with a supported adapter, email the specific information relate=
d to=20
-the issue to linux.nics@intel.com.
+kernel with a supported adapter, email the specific information relate=
d
+to the issue to e1000-devel@lists.sf.net

