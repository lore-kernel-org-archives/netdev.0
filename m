From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Tue, 10 Jul 2007 14:39:53 -0400
Message-ID: <20070710183953.GA8898@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:33708 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751043AbXGJSjz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 14:39:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Various minor updates.  The only thing of note is sk98lin driver removal.

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 Documentation/feature-removal-schedule.txt |    8 -
 Documentation/networking/00-INDEX          |    3 -
 Documentation/networking/sk98lin.txt       |  568 --
 MAINTAINERS                                |    7 +
 drivers/misc/eeprom_93cx6.c                |    6 +-
 drivers/net/3c59x.c                        |    2 +-
 drivers/net/8390.h                         |   11 +
 drivers/net/Kconfig                        |  116 +-
 drivers/net/Makefile                       |    4 +-
 drivers/net/atari_pamsnet.c                |   62 +-
 drivers/net/atl1/atl1_main.c               |    3 +-
 drivers/net/ax88796.c                      |  952 ++++
 drivers/net/bonding/bond_main.c            |   16 +-
 drivers/net/bonding/bonding.h              |    2 -
 drivers/net/cxgb3/cxgb3_main.c             |    5 +-
 drivers/net/e100.c                         |   12 +-
 drivers/net/ehea/ehea.h                    |    8 +-
 drivers/net/ehea/ehea_main.c               |   23 +-
 drivers/net/ioc3-eth.c                     |   41 +-
 drivers/net/macmace.c                      |    2 +-
 drivers/net/myri10ge/myri10ge.c            |    3 +-
 drivers/net/netxen/netxen_nic.h            |  103 -
 drivers/net/netxen/netxen_nic_main.c       |   97 +
 drivers/net/pcmcia/pcnet_cs.c              |    1 +
 drivers/net/phy/marvell.c                  |  123 +-
 drivers/net/ps3_gelic_net.c                | 1576 ++++++
 drivers/net/ps3_gelic_net.h                |  239 +
 drivers/net/rrunner.c                      |    2 +-
 drivers/net/s2io.c                         |    2 +-
 drivers/net/sis900.c                       |    2 +-
 drivers/net/sk98lin/Makefile               |   87 -
 drivers/net/sk98lin/h/lm80.h               |  179 -
 drivers/net/sk98lin/h/skaddr.h             |  285 -
 drivers/net/sk98lin/h/skcsum.h             |  213 -
 drivers/net/sk98lin/h/skdebug.h            |   74 -
 drivers/net/sk98lin/h/skdrv1st.h           |  188 -
 drivers/net/sk98lin/h/skdrv2nd.h           |  447 --
 drivers/net/sk98lin/h/skerror.h            |   55 -
 drivers/net/sk98lin/h/skgedrv.h            |   51 -
 drivers/net/sk98lin/h/skgehw.h             | 2126 -------
 drivers/net/sk98lin/h/skgehwt.h            |   48 -
 drivers/net/sk98lin/h/skgei2c.h            |  210 -
 drivers/net/sk98lin/h/skgeinit.h           |  797 ---
 drivers/net/sk98lin/h/skgepnm2.h           |  334 --
 drivers/net/sk98lin/h/skgepnmi.h           |  962 ----
 drivers/net/sk98lin/h/skgesirq.h           |  110 -
 drivers/net/sk98lin/h/ski2c.h              |  174 -
 drivers/net/sk98lin/h/skqueue.h            |   94 -
 drivers/net/sk98lin/h/skrlmt.h             |  438 --
 drivers/net/sk98lin/h/sktimer.h            |   63 -
 drivers/net/sk98lin/h/sktypes.h            |   69 -
 drivers/net/sk98lin/h/skversion.h          |   38 -
 drivers/net/sk98lin/h/skvpd.h              |  248 -
 drivers/net/sk98lin/h/xmac_ii.h            | 1579 ------
 drivers/net/sk98lin/skaddr.c               | 1788 ------
 drivers/net/sk98lin/skdim.c                |  742 ---
 drivers/net/sk98lin/skethtool.c            |  628 ---
 drivers/net/sk98lin/skge.c                 | 5211 ------------------
 drivers/net/sk98lin/skgehwt.c              |  171 -
 drivers/net/sk98lin/skgeinit.c             | 2005 -------
 drivers/net/sk98lin/skgemib.c              | 1075 ----
 drivers/net/sk98lin/skgepnmi.c             | 8210 ----------------------------
 drivers/net/sk98lin/skgesirq.c             | 2229 --------
 drivers/net/sk98lin/ski2c.c                | 1296 -----
 drivers/net/sk98lin/sklm80.c               |  141 -
 drivers/net/sk98lin/skqueue.c              |  179 -
 drivers/net/sk98lin/skrlmt.c               | 3257 -----------
 drivers/net/sk98lin/sktimer.c              |  250 -
 drivers/net/sk98lin/skvpd.c                | 1091 ----
 drivers/net/sk98lin/skxmac2.c              | 4160 --------------
 drivers/net/sky2.c                         |  449 ++-
 drivers/net/sky2.h                         |    4 +
 drivers/net/spider_net.c                   |   59 +-
 drivers/net/sunhme.c                       |    2 +-
 drivers/net/tokenring/3c359.c              |    2 +-
 drivers/net/ucc_geth.c                     |    2 +-
 drivers/net/usb/usbnet.c                   |    2 +-
 include/net/ax88796.h                      |   27 +
 net/ipv6/addrconf.c                        |    3 +
 79 files changed, 3531 insertions(+), 42320 deletions(-)
 delete mode 100644 Documentation/networking/sk98lin.txt
 create mode 100644 drivers/net/ax88796.c
 create mode 100644 drivers/net/ps3_gelic_net.c
 create mode 100644 drivers/net/ps3_gelic_net.h
 delete mode 100644 drivers/net/sk98lin/Makefile
 delete mode 100644 drivers/net/sk98lin/h/lm80.h
 delete mode 100644 drivers/net/sk98lin/h/skaddr.h
 delete mode 100644 drivers/net/sk98lin/h/skcsum.h
 delete mode 100644 drivers/net/sk98lin/h/skdebug.h
 delete mode 100644 drivers/net/sk98lin/h/skdrv1st.h
 delete mode 100644 drivers/net/sk98lin/h/skdrv2nd.h
 delete mode 100644 drivers/net/sk98lin/h/skerror.h
 delete mode 100644 drivers/net/sk98lin/h/skgedrv.h
 delete mode 100644 drivers/net/sk98lin/h/skgehw.h
 delete mode 100644 drivers/net/sk98lin/h/skgehwt.h
 delete mode 100644 drivers/net/sk98lin/h/skgei2c.h
 delete mode 100644 drivers/net/sk98lin/h/skgeinit.h
 delete mode 100644 drivers/net/sk98lin/h/skgepnm2.h
 delete mode 100644 drivers/net/sk98lin/h/skgepnmi.h
 delete mode 100644 drivers/net/sk98lin/h/skgesirq.h
 delete mode 100644 drivers/net/sk98lin/h/ski2c.h
 delete mode 100644 drivers/net/sk98lin/h/skqueue.h
 delete mode 100644 drivers/net/sk98lin/h/skrlmt.h
 delete mode 100644 drivers/net/sk98lin/h/sktimer.h
 delete mode 100644 drivers/net/sk98lin/h/sktypes.h
 delete mode 100644 drivers/net/sk98lin/h/skversion.h
 delete mode 100644 drivers/net/sk98lin/h/skvpd.h
 delete mode 100644 drivers/net/sk98lin/h/xmac_ii.h
 delete mode 100644 drivers/net/sk98lin/skaddr.c
 delete mode 100644 drivers/net/sk98lin/skdim.c
 delete mode 100644 drivers/net/sk98lin/skethtool.c
 delete mode 100644 drivers/net/sk98lin/skge.c
 delete mode 100644 drivers/net/sk98lin/skgehwt.c
 delete mode 100644 drivers/net/sk98lin/skgeinit.c
 delete mode 100644 drivers/net/sk98lin/skgemib.c
 delete mode 100644 drivers/net/sk98lin/skgepnmi.c
 delete mode 100644 drivers/net/sk98lin/skgesirq.c
 delete mode 100644 drivers/net/sk98lin/ski2c.c
 delete mode 100644 drivers/net/sk98lin/sklm80.c
 delete mode 100644 drivers/net/sk98lin/skqueue.c
 delete mode 100644 drivers/net/sk98lin/skrlmt.c
 delete mode 100644 drivers/net/sk98lin/sktimer.c
 delete mode 100644 drivers/net/sk98lin/skvpd.c
 delete mode 100644 drivers/net/sk98lin/skxmac2.c
 create mode 100644 include/net/ax88796.h

Adrian Bunk (5):
      sis900_mii_probe() must be __devinit
      tokenring/3c359.c:xl_init() must be __devinit
      rrunner.c:rr_init() must be __devinit
      sunhme.c:quattro_pci_find() must be __devinit
      bonding/bond_main.c: make 2 functions static

Alan Cox (1):
      IOC3: Switch to pci refcounting safe APIs

Alexey Dobriyan (2):
      macmace: use "unsigned long flags;"
      atl1: remove write-only var in tx handler

Ben Dooks (1):
      AX88796 network driver

David Graham (1):
      e100: Fix Tyan motherboard e100 not receiving IPMI commands

Francois Romieu (1):
      eeprom_93cx6: shorten pulse timing to match spec (bis)

Ishizaki Kou (1):
      spidernet: improve interrupt handling

Jan-Bernd Themann (1):
      eHEA: Capability flag for DLPAR support

Jay Vosburgh (1):
      bonding / ipv6: no addrconf for slaves separately from master

Jeff Garzik (2):
      Remove sk98lin ethernet driver.
      [netdrvr] Fix dependencies for ax88796 ne2k clone driver

Marcin Juszkiewicz (1):
      PCMCIA: add Socket Ethernet card into pcnet_cs

Masakazu Mokuno (1):
      ps3: gigabit ethernet driver for PS3, take3

Olof Johansson (2):
      phylib: cleanup marvell.c a bit
      phylib: Add Marvell 88E1112 phy id

Peter Korsgaard (1):
      Cleanup usbnet_probe() return value handling

Rolf Eike Beer (1):
      Fix typo in drivers/net/s2io.c

Steffen Klassert (1):
      3cSOHO100-TX needs EXTRA_PREAMBLE

Stephen Hemminger (13):
      sky2: restore workarounds for lost interrupts
      sky2: carrier management
      sky2: debug interface
      sky2: check for more work before leaving NAPI
      sky2: receive fill
      sky2: unmark as EXPERIMENTAL
      sky2: add support for read/write of EEPROM
      sky2: check drop truncated packets
      sky2: use roundup() macro
      sky2: use upper_32_bits() macro
      sky2: remove some leftover debug messages
      sky2: 1.16 version
      netxen: deinline and sparse fix

Timur Tabi (1):
      QE Ethernet driver writes to wrong register to mask interrupts

Yoann Padioleau (1):
      atari_pamsnet.c: old declaration ritchie style fix

vignesh babu (2):
      use is_power_of_2() in cxgb3/cxgb3_main.c
      Use is_power_of_2() in myri10ge/myri10ge.c

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 51b369e..3a159da 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -248,14 +248,6 @@ Who:	Len Brown <len.brown@intel.com>
 
 ---------------------------
 
-What:   sk98lin network driver
-When:   July 2007
-Why:    In kernel tree version of driver is unmaintained. Sk98lin driver
-	replaced by the skge driver. 
-Who:    Stephen Hemminger <shemminger@osdl.org>
-
----------------------------
-
 What:	Compaq touchscreen device emulation
 When:	Oct 2007
 Files:	drivers/input/tsdev.c
diff --git a/Documentation/networking/00-INDEX b/Documentation/networking/00-INDEX
index 153d84d..d63f480 100644
--- a/Documentation/networking/00-INDEX
+++ b/Documentation/networking/00-INDEX
@@ -96,9 +96,6 @@ routing.txt
 	- the new routing mechanism
 shaper.txt
 	- info on the module that can shape/limit transmitted traffic.
-sk98lin.txt
-	- Marvell Yukon Chipset / SysKonnect SK-98xx compliant Gigabit
-	  Ethernet Adapter family driver info
 skfp.txt
 	- SysKonnect FDDI (SK-5xxx, Compaq Netelligent) driver info.
 smc9.txt
diff --git a/Documentation/networking/sk98lin.txt b/Documentation/networking/sk98lin.txt
deleted file mode 100644
index 8590a95..0000000
--- a/Documentation/networking/sk98lin.txt
+++ /dev/null
@@ -1,568 +0,0 @@
-(C)Copyright 1999-2004 Marvell(R).
-All rights reserved
-===========================================================================
-
-sk98lin.txt created 13-Feb-2004
-
-Readme File for sk98lin v6.23
-Marvell Yukon/SysKonnect SK-98xx Gigabit Ethernet Adapter family driver for LINUX
-
-This file contains
- 1  Overview
- 2  Required Files
- 3  Installation
-    3.1  Driver Installation
-    3.2  Inclusion of adapter at system start
- 4  Driver Parameters
-    4.1  Per-Port Parameters
-    4.2  Adapter Parameters
- 5  Large Frame Support
- 6  VLAN and Link Aggregation Support (IEEE 802.1, 802.1q, 802.3ad)
- 7  Troubleshooting
-
-===========================================================================
-
-
-1  Overview
-===========
-
-The sk98lin driver supports the Marvell Yukon and SysKonnect 
-SK-98xx/SK-95xx compliant Gigabit Ethernet Adapter on Linux. It has 
-been tested with Linux on Intel/x86 machines.
-***
-
-
-2  Required Files
-=================
-
-The linux kernel source.
-No additional files required.
-***
-
-
-3  Installation
-===============
-
-It is recommended to download the latest version of the driver from the 
-SysKonnect web site www.syskonnect.com. If you have downloaded the latest
-driver, the Linux kernel has to be patched before the driver can be 
-installed. For details on how to patch a Linux kernel, refer to the 
-patch.txt file.
-
-3.1  Driver Installation
-------------------------
-
-The following steps describe the actions that are required to install
-the driver and to start it manually. These steps should be carried
-out for the initial driver setup. Once confirmed to be ok, they can
-be included in the system start.
-
-NOTE 1: To perform the following tasks you need 'root' access.
-
-NOTE 2: In case of problems, please read the section "Troubleshooting" 
-        below.
-
-The driver can either be integrated into the kernel or it can be compiled 
-as a module. Select the appropriate option during the kernel 
-configuration.
-
-Compile/use the driver as a module
-----------------------------------
-To compile the driver, go to the directory /usr/src/linux and
-execute the command "make menuconfig" or "make xconfig" and proceed as 
-follows:
-
-To integrate the driver permanently into the kernel, proceed as follows:
-
-1. Select the menu "Network device support" and then "Ethernet(1000Mbit)"
-2. Mark "Marvell Yukon Chipset / SysKonnect SK-98xx family support" 
-   with (*) 
-3. Build a new kernel when the configuration of the above options is 
-   finished.
-4. Install the new kernel.
-5. Reboot your system.
-
-To use the driver as a module, proceed as follows:
-
-1. Enable 'loadable module support' in the kernel.
-2. For automatic driver start, enable the 'Kernel module loader'.
-3. Select the menu "Network device support" and then "Ethernet(1000Mbit)"
-4. Mark "Marvell Yukon Chipset / SysKonnect SK-98xx family support" 
-   with (M)
-5. Execute the command "make modules".
-6. Execute the command "make modules_install".
-   The appropriate modules will be installed.
-7. Reboot your system.
-
-
-Load the module manually
-------------------------
-To load the module manually, proceed as follows:
-
-1. Enter "modprobe sk98lin".
-2. If a Marvell Yukon or SysKonnect SK-98xx adapter is installed in 
-   your computer and you have a /proc file system, execute the command:
-   "ls /proc/net/sk98lin/" 
-   This should produce an output containing a line with the following 
-   format:
-   eth0   eth1  ...
-   which indicates that your adapter has been found and initialized.
-   
-   NOTE 1: If you have more than one Marvell Yukon or SysKonnect SK-98xx 
-           adapter installed, the adapters will be listed as 'eth0', 
-                   'eth1', 'eth2', etc.
-                   For each adapter, repeat steps 3 and 4 below.
-
-   NOTE 2: If you have other Ethernet adapters installed, your Marvell
-           Yukon or SysKonnect SK-98xx adapter will be mapped to the 
-                   next available number, e.g. 'eth1'. The mapping is executed 
-                   automatically.
-           The module installation message (displayed either in a system
-           log file or on the console) prints a line for each adapter 
-           found containing the corresponding 'ethX'.
-
-3. Select an IP address and assign it to the respective adapter by 
-   entering:
-   ifconfig eth0 <ip-address>
-   With this command, the adapter is connected to the Ethernet. 
-   
-   SK-98xx Gigabit Ethernet Server Adapters: The yellow LED on the adapter 
-   is now active, the link status LED of the primary port is active and 
-   the link status LED of the secondary port (on dual port adapters) is 
-   blinking (if the ports are connected to a switch or hub).
-   SK-98xx V2.0 Gigabit Ethernet Adapters: The link status LED is active.
-   In addition, you will receive a status message on the console stating
-   "ethX: network connection up using port Y" and showing the selected 
-   connection parameters (x stands for the ethernet device number 
-   (0,1,2, etc), y stands for the port name (A or B)).
-
-   NOTE: If you are in doubt about IP addresses, ask your network
-         administrator for assistance.
-  
-4. Your adapter should now be fully operational.
-   Use 'ping <otherstation>' to verify the connection to other computers 
-   on your network.
-5. To check the adapter configuration view /proc/net/sk98lin/[devicename].
-   For example by executing:    
-   "cat /proc/net/sk98lin/eth0" 
-
-Unload the module
------------------
-To stop and unload the driver modules, proceed as follows:
-
-1. Execute the command "ifconfig eth0 down".
-2. Execute the command "rmmod sk98lin".
-
-3.2  Inclusion of adapter at system start
------------------------------------------
-
-Since a large number of different Linux distributions are 
-available, we are unable to describe a general installation procedure
-for the driver module.
-Because the driver is now integrated in the kernel, installation should
-be easy, using the standard mechanism of your distribution.
-Refer to the distribution's manual for installation of ethernet adapters.
-
-***
-
-4  Driver Parameters
-====================
-
-Parameters can be set at the command line after the module has been 
-loaded with the command 'modprobe'.
-In some distributions, the configuration tools are able to pass parameters
-to the driver module.
-
-If you use the kernel module loader, you can set driver parameters
-in the file /etc/modprobe.conf (or /etc/modules.conf in 2.4 or earlier).
-To set the driver parameters in this file, proceed as follows:
-
-1. Insert a line of the form :
-   options sk98lin ...
-   For "...", the same syntax is required as described for the command
-   line parameters of modprobe below.
-2. To activate the new parameters, either reboot your computer
-   or 
-   unload and reload the driver.
-   The syntax of the driver parameters is:
-
-        modprobe sk98lin parameter=value1[,value2[,value3...]]
-
-   where value1 refers to the first adapter, value2 to the second etc.
-
-NOTE: All parameters are case sensitive. Write them exactly as shown 
-      below.
-
-Example:
-Suppose you have two adapters. You want to set auto-negotiation
-on the first adapter to ON and on the second adapter to OFF.
-You also want to set DuplexCapabilities on the first adapter
-to FULL, and on the second adapter to HALF.
-Then, you must enter:
-
-        modprobe sk98lin AutoNeg_A=On,Off DupCap_A=Full,Half
-
-NOTE: The number of adapters that can be configured this way is
-      limited in the driver (file skge.c, constant SK_MAX_CARD_PARAM).
-      The current limit is 16. If you happen to install
-      more adapters, adjust this and recompile.
-
-
-4.1  Per-Port Parameters
-------------------------
-
-These settings are available for each port on the adapter.
-In the following description, '?' stands for the port for
-which you set the parameter (A or B).
-
-Speed
------
-Parameter:    Speed_?
-Values:       10, 100, 1000, Auto
-Default:      Auto
-
-This parameter is used to set the speed capabilities. It is only valid 
-for the SK-98xx V2.0 copper adapters.
-Usually, the speed is negotiated between the two ports during link 
-establishment. If this fails, a port can be forced to a specific setting
-with this parameter.
-
-Auto-Negotiation
-----------------
-Parameter:    AutoNeg_?
-Values:       On, Off, Sense
-Default:      On
-  
-The "Sense"-mode automatically detects whether the link partner supports
-auto-negotiation or not.
-
-Duplex Capabilities
--------------------
-Parameter:    DupCap_?
-Values:       Half, Full, Both
-Default:      Both
-
-This parameters is only relevant if auto-negotiation for this port is 
-not set to "Sense". If auto-negotiation is set to "On", all three values
-are possible. If it is set to "Off", only "Full" and "Half" are allowed.
-This parameter is useful if your link partner does not support all
-possible combinations.
-
-Flow Control
-------------
-Parameter:    FlowCtrl_?
-Values:       Sym, SymOrRem, LocSend, None
-Default:      SymOrRem
-
-This parameter can be used to set the flow control capabilities the 
-port reports during auto-negotiation. It can be set for each port 
-individually.
-Possible modes:
-   -- Sym      = Symmetric: both link partners are allowed to send 
-                  PAUSE frames
-   -- SymOrRem = SymmetricOrRemote: both or only remote partner 
-                  are allowed to send PAUSE frames
-   -- LocSend  = LocalSend: only local link partner is allowed 
-                  to send PAUSE frames
-   -- None     = no link partner is allowed to send PAUSE frames
-  
-NOTE: This parameter is ignored if auto-negotiation is set to "Off".
-
-Role in Master-Slave-Negotiation (1000Base-T only)
---------------------------------------------------
-Parameter:    Role_?
-Values:       Auto, Master, Slave
-Default:      Auto
-
-This parameter is only valid for the SK-9821 and SK-9822 adapters.
-For two 1000Base-T ports to communicate, one must take the role of the
-master (providing timing information), while the other must be the 
-slave. Usually, this is negotiated between the two ports during link 
-establishment. If this fails, a port can be forced to a specific setting
-with this parameter.
-
-
-4.2  Adapter Parameters
------------------------
-
-Connection Type (SK-98xx V2.0 copper adapters only)
----------------
-Parameter:    ConType
-Values:       Auto, 100FD, 100HD, 10FD, 10HD
-Default:      Auto
-
-The parameter 'ConType' is a combination of all five per-port parameters
-within one single parameter. This simplifies the configuration of both ports
-of an adapter card! The different values of this variable reflect the most 
-meaningful combinations of port parameters.
-
-The following table shows the values of 'ConType' and the corresponding
-combinations of the per-port parameters:
-
-    ConType   |  DupCap   AutoNeg   FlowCtrl   Role             Speed
-    ----------+------------------------------------------------------
-    Auto      |  Both     On        SymOrRem   Auto             Auto
-    100FD     |  Full     Off       None       Auto (ignored)   100
-    100HD     |  Half     Off       None       Auto (ignored)   100
-    10FD      |  Full     Off       None       Auto (ignored)   10
-    10HD      |  Half     Off       None       Auto (ignored)   10
-
-Stating any other port parameter together with this 'ConType' variable
-will result in a merged configuration of those settings. This due to 
-the fact, that the per-port parameters (e.g. Speed_? ) have a higher
-priority than the combined variable 'ConType'.
-
-NOTE: This parameter is always used on both ports of the adapter card.
-
-Interrupt Moderation
---------------------
-Parameter:    Moderation
-Values:       None, Static, Dynamic
-Default:      None
-
-Interrupt moderation is employed to limit the maximum number of interrupts
-the driver has to serve. That is, one or more interrupts (which indicate any
-transmit or receive packet to be processed) are queued until the driver 
-processes them. When queued interrupts are to be served, is determined by the
-'IntsPerSec' parameter, which is explained later below.
-
-Possible modes:
-
-   -- None - No interrupt moderation is applied on the adapter card. 
-      Therefore, each transmit or receive interrupt is served immediately
-      as soon as it appears on the interrupt line of the adapter card.
-
-   -- Static - Interrupt moderation is applied on the adapter card. 
-      All transmit and receive interrupts are queued until a complete
-      moderation interval ends. If such a moderation interval ends, all
-      queued interrupts are processed in one big bunch without any delay.
-      The term 'static' reflects the fact, that interrupt moderation is
-      always enabled, regardless how much network load is currently 
-      passing via a particular interface. In addition, the duration of
-      the moderation interval has a fixed length that never changes while
-      the driver is operational.
-
-   -- Dynamic - Interrupt moderation might be applied on the adapter card,
-      depending on the load of the system. If the driver detects that the
-      system load is too high, the driver tries to shield the system against 
-      too much network load by enabling interrupt moderation. If - at a later
-      time - the CPU utilization decreases again (or if the network load is 
-      negligible) the interrupt moderation will automatically be disabled.
-
-Interrupt moderation should be used when the driver has to handle one or more
-interfaces with a high network load, which - as a consequence - leads also to a
-high CPU utilization. When moderation is applied in such high network load 
-situations, CPU load might be reduced by 20-30%.
-
-NOTE: The drawback of using interrupt moderation is an increase of the round-
-trip-time (RTT), due to the queueing and serving of interrupts at dedicated
-moderation times.
-
-Interrupts per second
----------------------
-Parameter:    IntsPerSec
-Values:       30...40000 (interrupts per second)
-Default:      2000
-
-This parameter is only used if either static or dynamic interrupt moderation
-is used on a network adapter card. Using this parameter if no moderation is
-applied will lead to no action performed.
-
-This parameter determines the length of any interrupt moderation interval. 
-Assuming that static interrupt moderation is to be used, an 'IntsPerSec' 
-parameter value of 2000 will lead to an interrupt moderation interval of
-500 microseconds. 
-
-NOTE: The duration of the moderation interval is to be chosen with care.
-At first glance, selecting a very long duration (e.g. only 100 interrupts per 
-second) seems to be meaningful, but the increase of packet-processing delay 
-is tremendous. On the other hand, selecting a very short moderation time might
-compensate the use of any moderation being applied.
-
-
-Preferred Port
---------------
-Parameter:    PrefPort
-Values:       A, B
-Default:      A
-
-This is used to force the preferred port to A or B (on dual-port network 
-adapters). The preferred port is the one that is used if both are detected
-as fully functional.
-
-RLMT Mode (Redundant Link Management Technology)
-------------------------------------------------
-Parameter:    RlmtMode
-Values:       CheckLinkState,CheckLocalPort, CheckSeg, DualNet
-Default:      CheckLinkState
-
-RLMT monitors the status of the port. If the link of the active port 
-fails, RLMT switches immediately to the standby link. The virtual link is 
-maintained as long as at least one 'physical' link is up. 
-
-Possible modes:
-
-   -- CheckLinkState - Check link state only: RLMT uses the link state
-      reported by the adapter hardware for each individual port to 
-      determine whether a port can be used for all network traffic or 
-      not.
-
-   -- CheckLocalPort - In this mode, RLMT monitors the network path 
-      between the two ports of an adapter by regularly exchanging packets
-      between them. This mode requires a network configuration in which 
-      the two ports are able to "see" each other (i.e. there must not be 
-      any router between the ports).
-
-   -- CheckSeg - Check local port and segmentation: This mode supports the
-      same functions as the CheckLocalPort mode and additionally checks 
-      network segmentation between the ports. Therefore, this mode is only
-      to be used if Gigabit Ethernet switches are installed on the network
-      that have been configured to use the Spanning Tree protocol. 
-
-   -- DualNet - In this mode, ports A and B are used as separate devices. 
-      If you have a dual port adapter, port A will be configured as eth0 
-      and port B as eth1. Both ports can be used independently with 
-      distinct IP addresses. The preferred port setting is not used. 
-      RLMT is turned off.
-   
-NOTE: RLMT modes CLP and CLPSS are designed to operate in configurations 
-      where a network path between the ports on one adapter exists. 
-      Moreover, they are not designed to work where adapters are connected
-      back-to-back.
-***
-
-
-5  Large Frame Support
-======================
-
-The driver supports large frames (also called jumbo frames). Using large 
-frames can result in an improved throughput if transferring large amounts 
-of data.
-To enable large frames, set the MTU (maximum transfer unit) of the 
-interface to the desired value (up to 9000), execute the following 
-command:
-      ifconfig eth0 mtu 9000
-This will only work if you have two adapters connected back-to-back
-or if you use a switch that supports large frames. When using a switch, 
-it should be configured to allow large frames and auto-negotiation should  
-be set to OFF. The setting must be configured on all adapters that can be 
-reached by the large frames. If one adapter is not set to receive large 
-frames, it will simply drop them.
-
-You can switch back to the standard ethernet frame size by executing the 
-following command:
-      ifconfig eth0 mtu 1500
-
-To permanently configure this setting, add a script with the 'ifconfig' 
-line to the system startup sequence (named something like "S99sk98lin" 
-in /etc/rc.d/rc2.d).
-***
-
-
-6  VLAN and Link Aggregation Support (IEEE 802.1, 802.1q, 802.3ad)
-==================================================================
-
-The Marvell Yukon/SysKonnect Linux drivers are able to support VLAN and 
-Link Aggregation according to IEEE standards 802.1, 802.1q, and 802.3ad. 
-These features are only available after installation of open source 
-modules available on the Internet:
-For VLAN go to: http://www.candelatech.com/~greear/vlan.html
-For Link Aggregation go to: http://www.st.rim.or.jp/~yumo
-
-NOTE: SysKonnect GmbH does not offer any support for these open source 
-      modules and does not take the responsibility for any kind of 
-      failures or problems arising in connection with these modules.
-
-NOTE: Configuring Link Aggregation on a SysKonnect dual link adapter may 
-      cause problems when unloading the driver.
-
-
-7  Troubleshooting
-==================
-
-If any problems occur during the installation process, check the 
-following list:
-
-
-Problem:  The SK-98xx adapter cannot be found by the driver.
-Solution: In /proc/pci search for the following entry:
-             'Ethernet controller: SysKonnect SK-98xx ...'
-          If this entry exists, the SK-98xx or SK-98xx V2.0 adapter has 
-          been found by the system and should be operational.
-          If this entry does not exist or if the file '/proc/pci' is not 
-          found, there may be a hardware problem or the PCI support may 
-          not be enabled in your kernel.
-          The adapter can be checked using the diagnostics program which 
-          is available on the SysKonnect web site:
-          www.syskonnect.com
-          
-          Some COMPAQ machines have problems dealing with PCI under Linux.
-          This problem is described in the 'PCI howto' document
-          (included in some distributions or available from the
-          web, e.g. at 'www.linux.org'). 
-
-
-Problem:  Programs such as 'ifconfig' or 'route' cannot be found or the 
-          error message 'Operation not permitted' is displayed.
-Reason:   You are not logged in as user 'root'.
-Solution: Logout and login as 'root' or change to 'root' via 'su'.
-
-
-Problem:  Upon use of the command 'ping <address>' the message
-          "ping: sendto: Network is unreachable" is displayed.
-Reason:   Your route is not set correctly.
-Solution: If you are using RedHat, you probably forgot to set up the 
-          route in the 'network configuration'.
-          Check the existing routes with the 'route' command and check 
-          if an entry for 'eth0' exists, and if so, if it is set correctly.
-
-
-Problem:  The driver can be started, the adapter is connected to the 
-          network, but you cannot receive or transmit any packets; 
-          e.g. 'ping' does not work.
-Reason:   There is an incorrect route in your routing table.
-Solution: Check the routing table with the command 'route' and read the 
-          manual help pages dealing with routes (enter 'man route').
-
-NOTE: Although the 2.2.x kernel versions generate the routing entry 
-      automatically, problems of this kind may occur here as well. We've 
-      come across a situation in which the driver started correctly at 
-      system start, but after the driver has been removed and reloaded,
-      the route of the adapter's network pointed to the 'dummy0'device 
-      and had to be corrected manually.
-
-
-Problem:  Your computer should act as a router between multiple 
-          IP subnetworks (using multiple adapters), but computers in 
-          other subnetworks cannot be reached.
-Reason:   Either the router's kernel is not configured for IP forwarding 
-          or the routing table and gateway configuration of at least one 
-          computer is not working.
-
-Problem:  Upon driver start, the following error message is displayed:
-          "eth0: -- ERROR --
-          Class: internal Software error
-          Nr:    0xcc
-          Msg:   SkGeInitPort() cannot init running ports"
-Reason:   You are using a driver compiled for single processor machines 
-          on a multiprocessor machine with SMP (Symmetric MultiProcessor) 
-          kernel.
-Solution: Configure your kernel appropriately and recompile the kernel or
-          the modules.
-
-
-
-If your problem is not listed here, please contact SysKonnect's technical
-support for help (linux@syskonnect.de).
-When contacting our technical support, please ensure that the following 
-information is available:
-- System Manufacturer and HW Informations (CPU, Memory... )
-- PCI-Boards in your system
-- Distribution
-- Kernel version
-- Driver version
-***
-
-
-
-***End of Readme File***
diff --git a/MAINTAINERS b/MAINTAINERS
index 2c1dfb2..0223d6d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2930,6 +2930,13 @@ M:	mikpe@it.uu.se
 L:	linux-ide@vger.kernel.org
 S:	Maintained
 
+PS3 NETWORK SUPPORT
+P:	Masakazu Mokuno
+M:	mokuno@sm.sony.co.jp
+L:	netdev@vger.kernel.org
+L:	cbe-oss-dev@ozlabs.org
+S:	Supported
+
 PS3 PLATFORM SUPPORT
 P:	Geoff Levand
 M:	geoffrey.levand@am.sony.com
diff --git a/drivers/misc/eeprom_93cx6.c b/drivers/misc/eeprom_93cx6.c
index ac515b0..ea55654 100644
--- a/drivers/misc/eeprom_93cx6.c
+++ b/drivers/misc/eeprom_93cx6.c
@@ -55,10 +55,10 @@ static inline void eeprom_93cx6_pulse_low(struct eeprom_93cx6 *eeprom)
 
 	/*
 	 * Add a short delay for the pulse to work.
-	 * According to the specifications the minimal time
-	 * should be 450ns so a 1us delay is sufficient.
+	 * According to the specifications the "maximum minimum"
+	 * time should be 450ns.
 	 */
-	udelay(1);
+	ndelay(450);
 }
 
 static void eeprom_93cx6_startup(struct eeprom_93cx6 *eeprom)
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index f26ca33..6deb20f 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -324,7 +324,7 @@ static struct vortex_chip_info {
 	{"3c980C Python-T",
 	 PCI_USES_MASTER, IS_CYCLONE|HAS_NWAY|HAS_HWCKSM, 128, },
 	{"3cSOHO100-TX Hurricane",
-	 PCI_USES_MASTER, IS_CYCLONE|HAS_NWAY|HAS_HWCKSM, 128, },
+	 PCI_USES_MASTER, IS_CYCLONE|HAS_NWAY|HAS_HWCKSM|EXTRA_PREAMBLE, 128, },
 	{"3c555 Laptop Hurricane",
 	 PCI_USES_MASTER, IS_CYCLONE|EEPROM_8BIT|HAS_HWCKSM, 128, },
 	{"3c556 Laptop Tornado",
diff --git a/drivers/net/8390.h b/drivers/net/8390.h
index 414de5b..04ddec0 100644
--- a/drivers/net/8390.h
+++ b/drivers/net/8390.h
@@ -73,6 +73,9 @@ struct ei_device {
 	u32 *reg_offset;		/* Register mapping table */
 	spinlock_t page_lock;		/* Page register locks */
 	unsigned long priv;		/* Private field to store bus IDs etc. */
+#ifdef AX88796_PLATFORM
+	unsigned char rxcr_base;	/* default value for RXCR */
+#endif
 };
 
 /* The maximum number of 8390 interrupt service routines called per IRQ. */
@@ -86,11 +89,19 @@ struct ei_device {
 /* Some generic ethernet register configurations. */
 #define E8390_TX_IRQ_MASK	0xa	/* For register EN0_ISR */
 #define E8390_RX_IRQ_MASK	0x5
+
+#ifdef AX88796_PLATFORM
+#define E8390_RXCONFIG		(ei_status.rxcr_base | 0x04)
+#define E8390_RXOFF		(ei_status.rxcr_base | 0x20)
+#else
 #define E8390_RXCONFIG		0x4	/* EN0_RXCR: broadcasts, no multicast,errors */
 #define E8390_RXOFF		0x20	/* EN0_RXCR: Accept no packets */
+#endif
+
 #define E8390_TXCONFIG		0x00	/* EN0_TXCR: Normal transmit mode */
 #define E8390_TXOFF		0x02	/* EN0_TXCR: Transmitter off */
 
+
 /*  Register accessed at EN_CMD, the 8390 base addr.  */
 #define E8390_STOP	0x01	/* Stop and reset the chip */
 #define E8390_START	0x02	/* Start the chip, clear reset */
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 5cc3d51..ec84684 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -197,6 +197,15 @@ config MACB
 
 source "drivers/net/arm/Kconfig"
 
+config AX88796
+	tristate "ASIX AX88796 NE2000 clone support"
+	depends on ARM || MIPS
+	select CRC32
+	select MII
+	help
+	  AX88796 driver, using platform bus to provide
+	  chip detection and resources
+
 config MACE
 	tristate "MACE (Power Mac ethernet) support"
 	depends on PPC_PMAC && PPC32
@@ -2105,7 +2114,7 @@ config SKGE
 	  with better performance and more complete ethtool support.
 
 	  It does not support the link failover and network management 
-	  features that "portable" vendor supplied sk98lin driver does.
+	  features available in the hardware.
 
 	  This driver supports adapters based on the original Yukon chipset:
 	  Marvell 88E8001, Belkin F5D5005, CNet GigaCard, DLink DGE-530T,
@@ -2118,7 +2127,7 @@ config SKGE
 	  will be called skge.  This is recommended.
 
 config SKY2
-	tristate "SysKonnect Yukon2 support (EXPERIMENTAL)"
+	tristate "SysKonnect Yukon2 support"
 	depends on PCI
 	select CRC32
 	---help---
@@ -2133,92 +2142,15 @@ config SKY2
 	  To compile this driver as a module, choose M here: the module
 	  will be called sky2.  This is recommended.
 
-config SK98LIN
-	tristate "Marvell Yukon Chipset / SysKonnect SK-98xx Support (DEPRECATED)"
-	depends on PCI
-	---help---
-	  Say Y here if you have a Marvell Yukon or SysKonnect SK-98xx/SK-95xx
-	  compliant Gigabit Ethernet Adapter.
-
-	  This driver supports the original Yukon chipset. This driver is
-	  deprecated and will be removed from the kernel in the near future,
-	  it has been replaced by the skge driver. skge is cleaner and
-	  seems to work better.
+config SKY2_DEBUG
+       bool "Debugging interface"
+       depends on SKY2 && DEBUG_FS
+       help
+	 This option adds the ability to dump driver state for debugging.
+	 The file debugfs/sky2/ethX displays the state of the internal
+	 transmit and receive rings.
 
-	  This driver does not support the newer Yukon2 chipset. A separate
-	  driver, sky2, is provided to support Yukon2-based adapters.
-
-	  The following adapters are supported by this driver:
-	    - 3Com 3C940 Gigabit LOM Ethernet Adapter
-	    - 3Com 3C941 Gigabit LOM Ethernet Adapter
-	    - Allied Telesyn AT-2970LX Gigabit Ethernet Adapter
-	    - Allied Telesyn AT-2970LX/2SC Gigabit Ethernet Adapter
-	    - Allied Telesyn AT-2970SX Gigabit Ethernet Adapter
-	    - Allied Telesyn AT-2970SX/2SC Gigabit Ethernet Adapter
-	    - Allied Telesyn AT-2970TX Gigabit Ethernet Adapter
-	    - Allied Telesyn AT-2970TX/2TX Gigabit Ethernet Adapter
-	    - Allied Telesyn AT-2971SX Gigabit Ethernet Adapter
-	    - Allied Telesyn AT-2971T Gigabit Ethernet Adapter
-	    - Belkin Gigabit Desktop Card 10/100/1000Base-T Adapter, Copper RJ-45
-	    - EG1032 v2 Instant Gigabit Network Adapter
-	    - EG1064 v2 Instant Gigabit Network Adapter
-	    - Marvell 88E8001 Gigabit LOM Ethernet Adapter (Abit)
-	    - Marvell 88E8001 Gigabit LOM Ethernet Adapter (Albatron)
-	    - Marvell 88E8001 Gigabit LOM Ethernet Adapter (Asus)
-	    - Marvell 88E8001 Gigabit LOM Ethernet Adapter (ECS)
-	    - Marvell 88E8001 Gigabit LOM Ethernet Adapter (Epox)
-	    - Marvell 88E8001 Gigabit LOM Ethernet Adapter (Foxconn)
-	    - Marvell 88E8001 Gigabit LOM Ethernet Adapter (Gigabyte)
-	    - Marvell 88E8001 Gigabit LOM Ethernet Adapter (Iwill)
-	    - Marvell 88E8050 Gigabit LOM Ethernet Adapter (Intel)
-	    - Marvell RDK-8001 Adapter
-	    - Marvell RDK-8002 Adapter
-	    - Marvell RDK-8003 Adapter
-	    - Marvell RDK-8004 Adapter
-	    - Marvell RDK-8006 Adapter
-	    - Marvell RDK-8007 Adapter
-	    - Marvell RDK-8008 Adapter
-	    - Marvell RDK-8009 Adapter
-	    - Marvell RDK-8010 Adapter
-	    - Marvell RDK-8011 Adapter
-	    - Marvell RDK-8012 Adapter
-	    - Marvell RDK-8052 Adapter
-	    - Marvell Yukon Gigabit Ethernet 10/100/1000Base-T Adapter (32 bit)
-	    - Marvell Yukon Gigabit Ethernet 10/100/1000Base-T Adapter (64 bit)
-	    - N-Way PCI-Bus Giga-Card 1000/100/10Mbps(L)
-	    - SK-9521 10/100/1000Base-T Adapter
-	    - SK-9521 V2.0 10/100/1000Base-T Adapter
-	    - SK-9821 Gigabit Ethernet Server Adapter (SK-NET GE-T)
-	    - SK-9821 V2.0 Gigabit Ethernet 10/100/1000Base-T Adapter
-	    - SK-9822 Gigabit Ethernet Server Adapter (SK-NET GE-T dual link)
-	    - SK-9841 Gigabit Ethernet Server Adapter (SK-NET GE-LX)
-	    - SK-9841 V2.0 Gigabit Ethernet 1000Base-LX Adapter
-	    - SK-9842 Gigabit Ethernet Server Adapter (SK-NET GE-LX dual link)
-	    - SK-9843 Gigabit Ethernet Server Adapter (SK-NET GE-SX)
-	    - SK-9843 V2.0 Gigabit Ethernet 1000Base-SX Adapter
-	    - SK-9844 Gigabit Ethernet Server Adapter (SK-NET GE-SX dual link)
-	    - SK-9851 V2.0 Gigabit Ethernet 1000Base-SX Adapter
-	    - SK-9861 Gigabit Ethernet Server Adapter (SK-NET GE-SX Volition)
-	    - SK-9861 V2.0 Gigabit Ethernet 1000Base-SX Adapter
-	    - SK-9862 Gigabit Ethernet Server Adapter (SK-NET GE-SX Volition dual link)
-	    - SK-9871 Gigabit Ethernet Server Adapter (SK-NET GE-ZX)
-	    - SK-9871 V2.0 Gigabit Ethernet 1000Base-ZX Adapter
-	    - SK-9872 Gigabit Ethernet Server Adapter (SK-NET GE-ZX dual link)
-	    - SMC EZ Card 1000 (SMC9452TXV.2)
-	  
-	  The adapters support Jumbo Frames.
-	  The dual link adapters support link-failover and dual port features.
-	  Both Marvell Yukon and SysKonnect SK-98xx/SK-95xx adapters support 
-	  the scatter-gather functionality with sendfile(). Please refer to 
-	  <file:Documentation/networking/sk98lin.txt> for more information about
-	  optional driver parameters.
-	  Questions concerning this driver may be addressed to:
-	      <linux@syskonnect.de>
-	  
-	  If you want to compile this driver as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/kbuild/modules.txt>. The module will
-	  be called sk98lin. This is recommended.
+	 If unsure, say N.
 
 config VIA_VELOCITY
 	tristate "VIA Velocity support"
@@ -2268,6 +2200,16 @@ config TSI108_ETH
 	     To compile this driver as a module, choose M here: the module
 	     will be called tsi108_eth.
 
+config GELIC_NET
+	tristate "PS3 Gigabit Ethernet driver"
+	depends on PPC_PS3
+	help
+	  This driver supports the network device on the PS3 game
+	  console.  This driver has built-in support for Ethernet.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called ps3_gelic.
+
 config GIANFAR
 	tristate "Gianfar Ethernet"
 	depends on 85xx || 83xx || PPC_86xx
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index eb62fb4..1bbcbed 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -60,10 +60,11 @@ obj-$(CONFIG_TIGON3) += tg3.o
 obj-$(CONFIG_BNX2) += bnx2.o
 spidernet-y += spider_net.o spider_net_ethtool.o
 obj-$(CONFIG_SPIDER_NET) += spidernet.o sungem_phy.o
+obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
+ps3_gelic-objs += ps3_gelic_net.o
 obj-$(CONFIG_TC35815) += tc35815.o
 obj-$(CONFIG_SKGE) += skge.o
 obj-$(CONFIG_SKY2) += sky2.o
-obj-$(CONFIG_SK98LIN) += sk98lin/
 obj-$(CONFIG_SKFP) += skfp/
 obj-$(CONFIG_VIA_RHINE) += via-rhine.o
 obj-$(CONFIG_VIA_VELOCITY) += via-velocity.o
@@ -107,6 +108,7 @@ obj-$(CONFIG_NET_SB1250_MAC) += sb1250-mac.o
 obj-$(CONFIG_B44) += b44.o
 obj-$(CONFIG_FORCEDETH) += forcedeth.o
 obj-$(CONFIG_NE_H8300) += ne-h8300.o
+obj-$(CONFIG_AX88796) += ax88796.o
 
 obj-$(CONFIG_TSI108_ETH) += tsi108_eth.o
 obj-$(CONFIG_MV643XX_ETH) += mv643xx_eth.o
diff --git a/drivers/net/atari_pamsnet.c b/drivers/net/atari_pamsnet.c
index 5471440..f735637 100644
--- a/drivers/net/atari_pamsnet.c
+++ b/drivers/net/atari_pamsnet.c
@@ -295,10 +295,7 @@ int if_up = 0;
 /* Setup the DMA counter */
 
 static void
-setup_dma (address, rw_flag, num_blocks)
-	void *address;
-	unsigned rw_flag;
-	int num_blocks;
+setup_dma (void *address, unsigned rw_flag, int num_blocks)
 {
 	WRITEMODE((unsigned) rw_flag          | DMA_FDC | SEC_COUNT | REG_ACSI |
 		  A1);
@@ -317,9 +314,7 @@ setup_dma (address, rw_flag, num_blocks)
 /* Send the first byte of an command block */
 
 static int
-send_first (target, byte)
-	int target;
-	unsigned char byte;
+send_first (int target, unsigned char byte)
 {
 	rw = READ;
 	acsi_delay_end(COMMAND_DELAY);
@@ -338,10 +333,7 @@ send_first (target, byte)
 /* Send the rest of an command block */
 
 static int
-send_1_5 (lun, command, dma)
-	int lun;
-	unsigned char *command;
-	int dma;
+send_1_5 (int lun, unsigned char *command, int dma)
 {
 	int i, j;
 
@@ -371,8 +363,7 @@ get_status (void)
 /* Calculate the number of received bytes */
 
 static int
-calc_received (start_address)
-	void *start_address;
+calc_received (void *start_address)
 {
 	return (int)(
 		(((unsigned long)DMAHIGH << 16) | ((unsigned)DMAMID << 8) | DMALOW)
@@ -384,8 +375,7 @@ calc_received (start_address)
 /* start() starts the PAM's DMA adaptor */
 
 static void
-start (target)
-	int target;
+start (int target)
 {
 	send_first(target, START);
 }
@@ -393,8 +383,7 @@ start (target)
 /* stop() stops the PAM's DMA adaptor and returns a value of zero in case of success */
 
 static int
-stop (target)
-	int target;
+stop (int target)
 {
 	int ret = -1;
 	unsigned char cmd_buffer[5];
@@ -415,8 +404,7 @@ bad:
 /* testpkt() returns the number of received packets waiting in the queue */
 
 static int
-testpkt(target)
-	int target;
+testpkt(int target)
 {
 	int ret = -1;
 
@@ -431,9 +419,7 @@ bad:
 /* Please note: The buffer is for internal use only but must be defined!   */
 
 static int
-inquiry (target, buffer)
-	int target;
-	unsigned char *buffer;
+inquiry (int target, unsigned char *buffer)
 {
 	int ret = -1;
 	unsigned char *vbuffer = phys_to_virt((unsigned long)buffer);
@@ -468,9 +454,7 @@ bad:
  */
 
 static HADDR
-*read_hw_addr(target, buffer)
-	int target;
-	unsigned char *buffer;
+*read_hw_addr(int target, unsigned char *buffer)
 {
 	HADDR *ret = 0;
 	unsigned char cmd_buffer[5];
@@ -491,9 +475,7 @@ bad:
 }
 
 static irqreturn_t
-pamsnet_intr(irq, data, fp)
-	int irq;
-	void *data;
+pamsnet_intr(int irq, void *data)
 {
 	return IRQ_HANDLED;
 }
@@ -501,9 +483,7 @@ pamsnet_intr(irq, data, fp)
 /* receivepkt() loads a packet to a given buffer and returns its length */
 
 static int
-receivepkt (target, buffer)
-	int target;
-	unsigned char *buffer;
+receivepkt (int target, unsigned char *buffer)
 {
 	int ret = -1;
 	unsigned char cmd_buffer[5];
@@ -526,10 +506,7 @@ bad:
              successfully */
 
 static int
-sendpkt (target, buffer, length)
-	int target;
-	unsigned char *buffer;
-	int length;
+sendpkt (int target, unsigned char *buffer, int length)
 {
 	int ret = -1;
 	unsigned char cmd_buffer[5];
@@ -665,7 +642,8 @@ struct net_device * __init pamsnet_probe (int unit)
    there is non-reboot way to recover if something goes wrong.
  */
 static int
-pamsnet_open(struct net_device *dev) {
+pamsnet_open(struct net_device *dev)
+{
 	struct net_local *lp = netdev_priv(dev);
 
 	if (pamsnet_debug > 0)
@@ -694,7 +672,8 @@ pamsnet_open(struct net_device *dev) {
 }
 
 static int
-pamsnet_send_packet(struct sk_buff *skb, struct net_device *dev) {
+pamsnet_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
 	struct net_local *lp = netdev_priv(dev);
 	unsigned long flags;
 
@@ -741,7 +720,8 @@ pamsnet_send_packet(struct sk_buff *skb, struct net_device *dev) {
 /* We have a good packet(s), get it/them out of the buffers.
  */
 static void
-pamsnet_poll_rx(struct net_device *dev) {
+pamsnet_poll_rx(struct net_device *dev)
+{
 	struct net_local *lp = netdev_priv(dev);
 	int boguscount;
 	int pkt_len;
@@ -816,7 +796,8 @@ pamsnet_poll_rx(struct net_device *dev) {
  * passes them to the higher layers and restarts the timer.
  */
 static void
-pamsnet_tick(unsigned long data) {
+pamsnet_tick(unsigned long data)
+{
 	struct net_device	 *dev = (struct net_device *)data;
 	struct net_local *lp = netdev_priv(dev);
 
@@ -832,7 +813,8 @@ pamsnet_tick(unsigned long data) {
 /* The inverse routine to pamsnet_open().
  */
 static int
-pamsnet_close(struct net_device *dev) {
+pamsnet_close(struct net_device *dev)
+{
 	struct net_local *lp = netdev_priv(dev);
 
 	if (pamsnet_debug > 0)
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 6862c11..3bb40dd 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -634,14 +634,13 @@ static void atl1_intr_tx(struct atl1_adapter *adapter)
 	struct atl1_buffer *buffer_info;
 	u16 sw_tpd_next_to_clean;
 	u16 cmb_tpd_next_to_clean;
-	u8 update = 0;
 
 	sw_tpd_next_to_clean = atomic_read(&tpd_ring->next_to_clean);
 	cmb_tpd_next_to_clean = le16_to_cpu(adapter->cmb.cmb->tpd_cons_idx);
 
 	while (cmb_tpd_next_to_clean != sw_tpd_next_to_clean) {
 		struct tx_packet_desc *tpd;
-		update = 1;
+
 		tpd = ATL1_TPD_DESC(tpd_ring, sw_tpd_next_to_clean);
 		buffer_info = &tpd_ring->buffer_info[sw_tpd_next_to_clean];
 		if (buffer_info->dma) {
diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
new file mode 100644
index 0000000..d19874b
--- /dev/null
+++ b/drivers/net/ax88796.c
@@ -0,0 +1,952 @@
+/* drivers/net/ax88796.c
+ *
+ * Copyright 2005,2007 Simtec Electronics
+ *	Ben Dooks <ben@simtec.co.uk>
+ *
+ * Asix AX88796 10/100 Ethernet controller support
+ *	Based on ne.c, by Donald Becker, et-al.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+*/
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/isapnp.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/platform_device.h>
+#include <linux/delay.h>
+#include <linux/timer.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+
+#include <net/ax88796.h>
+
+#include <asm/system.h>
+#include <asm/io.h>
+
+static int phy_debug = 0;
+
+/* Rename the lib8390.c functions to show that they are in this driver */
+#define __ei_open       ax_ei_open
+#define __ei_close      ax_ei_close
+#define __ei_poll	ax_ei_poll
+#define __ei_tx_timeout ax_ei_tx_timeout
+#define __ei_interrupt  ax_ei_interrupt
+#define ____alloc_ei_netdev ax__alloc_ei_netdev
+#define __NS8390_init   ax_NS8390_init
+
+/* force unsigned long back to 'void __iomem *' */
+#define ax_convert_addr(_a) ((void __force __iomem *)(_a))
+
+#define ei_inb(_a)	readb(ax_convert_addr(_a))
+#define ei_outb(_v, _a) writeb(_v, ax_convert_addr(_a))
+
+#define ei_inb_p(_a)	ei_inb(_a)
+#define ei_outb_p(_v, _a) ei_outb(_v, _a)
+
+/* define EI_SHIFT() to take into account our register offsets */
+#define EI_SHIFT(x)     (ei_local->reg_offset[(x)])
+
+/* Ensure we have our RCR base value */
+#define AX88796_PLATFORM
+
+static unsigned char version[] = "ax88796.c: Copyright 2005,2007 Simtec Electronics\n";
+
+#include "lib8390.c"
+
+#define DRV_NAME "ax88796"
+#define DRV_VERSION "1.00"
+
+/* from ne.c */
+#define NE_CMD		EI_SHIFT(0x00)
+#define NE_RESET	EI_SHIFT(0x1f)
+#define NE_DATAPORT	EI_SHIFT(0x10)
+
+#define NE1SM_START_PG	0x20	/* First page of TX buffer */
+#define NE1SM_STOP_PG 	0x40	/* Last page +1 of RX ring */
+#define NESM_START_PG	0x40	/* First page of TX buffer */
+#define NESM_STOP_PG	0x80	/* Last page +1 of RX ring */
+
+/* device private data */
+
+struct ax_device {
+	struct timer_list	 mii_timer;
+	spinlock_t		 mii_lock;
+	struct mii_if_info	 mii;
+
+	u32			 msg_enable;
+	void __iomem		*map2;
+	struct platform_device	*dev;
+	struct resource		*mem;
+	struct resource		*mem2;
+	struct ax_plat_data	*plat;
+
+	unsigned char		 running;
+	unsigned char		 resume_open;
+
+	u32			 reg_offsets[0x20];
+};
+
+static inline struct ax_device *to_ax_dev(struct net_device *dev)
+{
+	struct ei_device *ei_local = netdev_priv(dev);
+	return (struct ax_device *)(ei_local+1);
+}
+
+/* ax_initial_check
+ *
+ * do an initial probe for the card to check wether it exists
+ * and is functional
+ */
+
+static int ax_initial_check(struct net_device *dev)
+{
+	struct ei_device *ei_local = netdev_priv(dev);
+	void __iomem *ioaddr = ei_local->mem;
+	int reg0;
+	int regd;
+
+	reg0 = ei_inb(ioaddr);
+	if (reg0 == 0xFF)
+		return -ENODEV;
+
+	ei_outb(E8390_NODMA+E8390_PAGE1+E8390_STOP, ioaddr + E8390_CMD);
+	regd = ei_inb(ioaddr + 0x0d);
+	ei_outb(0xff, ioaddr + 0x0d);
+	ei_outb(E8390_NODMA+E8390_PAGE0, ioaddr + E8390_CMD);
+	ei_inb(ioaddr + EN0_COUNTER0); /* Clear the counter by reading. */
+	if (ei_inb(ioaddr + EN0_COUNTER0) != 0) {
+		ei_outb(reg0, ioaddr);
+		ei_outb(regd, ioaddr + 0x0d);	/* Restore the old values. */
+		return -ENODEV;
+	}
+
+	return 0;
+}
+
+/* Hard reset the card.  This used to pause for the same period that a
+   8390 reset command required, but that shouldn't be necessary. */
+
+static void ax_reset_8390(struct net_device *dev)
+{
+	struct ei_device *ei_local = netdev_priv(dev);
+	unsigned long reset_start_time = jiffies;
+	void __iomem *addr = (void __iomem *)dev->base_addr;
+
+	if (ei_debug > 1)
+		printk(KERN_DEBUG "resetting the 8390 t=%ld...", jiffies);
+
+	ei_outb(ei_inb(addr + NE_RESET), addr + NE_RESET);
+
+	ei_status.txing = 0;
+	ei_status.dmaing = 0;
+
+	/* This check _should_not_ be necessary, omit eventually. */
+	while ((ei_inb(addr + EN0_ISR) & ENISR_RESET) == 0) {
+		if (jiffies - reset_start_time > 2*HZ/100) {
+			printk(KERN_WARNING "%s: %s did not complete.\n",
+			       __FUNCTION__, dev->name);
+			break;
+		}
+	}
+
+	ei_outb(ENISR_RESET, addr + EN0_ISR);	/* Ack intr. */
+}
+
+
+static void ax_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr,
+			    int ring_page)
+{
+	struct ei_device *ei_local = netdev_priv(dev);
+	void __iomem *nic_base = ei_local->mem;
+
+	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
+	if (ei_status.dmaing) {
+		printk(KERN_EMERG "%s: DMAing conflict in %s [DMAstat:%d][irqlock:%d].\n",
+			dev->name, __FUNCTION__,
+		       ei_status.dmaing, ei_status.irqlock);
+		return;
+	}
+
+	ei_status.dmaing |= 0x01;
+	ei_outb(E8390_NODMA+E8390_PAGE0+E8390_START, nic_base+ NE_CMD);
+	ei_outb(sizeof(struct e8390_pkt_hdr), nic_base + EN0_RCNTLO);
+	ei_outb(0, nic_base + EN0_RCNTHI);
+	ei_outb(0, nic_base + EN0_RSARLO);		/* On page boundary */
+	ei_outb(ring_page, nic_base + EN0_RSARHI);
+	ei_outb(E8390_RREAD+E8390_START, nic_base + NE_CMD);
+
+	if (ei_status.word16)
+		readsw(nic_base + NE_DATAPORT, hdr, sizeof(struct e8390_pkt_hdr)>>1);
+	else
+		readsb(nic_base + NE_DATAPORT, hdr, sizeof(struct e8390_pkt_hdr));
+
+	ei_outb(ENISR_RDC, nic_base + EN0_ISR);	/* Ack intr. */
+	ei_status.dmaing &= ~0x01;
+
+	le16_to_cpus(&hdr->count);
+}
+
+
+/* Block input and output, similar to the Crynwr packet driver.  If you
+   are porting to a new ethercard, look at the packet driver source for hints.
+   The NEx000 doesn't share the on-board packet memory -- you have to put
+   the packet out through the "remote DMA" dataport using ei_outb. */
+
+static void ax_block_input(struct net_device *dev, int count,
+			   struct sk_buff *skb, int ring_offset)
+{
+	struct ei_device *ei_local = netdev_priv(dev);
+	void __iomem *nic_base = ei_local->mem;
+	char *buf = skb->data;
+
+	if (ei_status.dmaing) {
+		printk(KERN_EMERG "%s: DMAing conflict in ax_block_input "
+			"[DMAstat:%d][irqlock:%d].\n",
+			dev->name, ei_status.dmaing, ei_status.irqlock);
+		return;
+	}
+
+	ei_status.dmaing |= 0x01;
+
+	ei_outb(E8390_NODMA+E8390_PAGE0+E8390_START, nic_base+ NE_CMD);
+	ei_outb(count & 0xff, nic_base + EN0_RCNTLO);
+	ei_outb(count >> 8, nic_base + EN0_RCNTHI);
+	ei_outb(ring_offset & 0xff, nic_base + EN0_RSARLO);
+	ei_outb(ring_offset >> 8, nic_base + EN0_RSARHI);
+	ei_outb(E8390_RREAD+E8390_START, nic_base + NE_CMD);
+
+	if (ei_status.word16) {
+		readsw(nic_base + NE_DATAPORT, buf, count >> 1);
+		if (count & 0x01)
+			buf[count-1] = ei_inb(nic_base + NE_DATAPORT);
+
+	} else {
+		readsb(nic_base + NE_DATAPORT, buf, count);
+	}
+
+	ei_status.dmaing &= ~1;
+}
+
+static void ax_block_output(struct net_device *dev, int count,
+			    const unsigned char *buf, const int start_page)
+{
+	struct ei_device *ei_local = netdev_priv(dev);
+	void __iomem *nic_base = ei_local->mem;
+	unsigned long dma_start;
+
+	/* Round the count up for word writes.  Do we need to do this?
+	   What effect will an odd byte count have on the 8390?
+	   I should check someday. */
+
+	if (ei_status.word16 && (count & 0x01))
+		count++;
+
+	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
+	if (ei_status.dmaing) {
+		printk(KERN_EMERG "%s: DMAing conflict in %s."
+			"[DMAstat:%d][irqlock:%d]\n",
+			dev->name, __FUNCTION__,
+		       ei_status.dmaing, ei_status.irqlock);
+		return;
+	}
+
+	ei_status.dmaing |= 0x01;
+	/* We should already be in page 0, but to be safe... */
+	ei_outb(E8390_PAGE0+E8390_START+E8390_NODMA, nic_base + NE_CMD);
+
+	ei_outb(ENISR_RDC, nic_base + EN0_ISR);
+
+	/* Now the normal output. */
+	ei_outb(count & 0xff, nic_base + EN0_RCNTLO);
+	ei_outb(count >> 8,   nic_base + EN0_RCNTHI);
+	ei_outb(0x00, nic_base + EN0_RSARLO);
+	ei_outb(start_page, nic_base + EN0_RSARHI);
+
+	ei_outb(E8390_RWRITE+E8390_START, nic_base + NE_CMD);
+	if (ei_status.word16) {
+		writesw(nic_base + NE_DATAPORT, buf, count>>1);
+	} else {
+		writesb(nic_base + NE_DATAPORT, buf, count);
+	}
+
+	dma_start = jiffies;
+
+	while ((ei_inb(nic_base + EN0_ISR) & ENISR_RDC) == 0) {
+		if (jiffies - dma_start > 2*HZ/100) {		/* 20ms */
+			printk(KERN_WARNING "%s: timeout waiting for Tx RDC.\n", dev->name);
+			ax_reset_8390(dev);
+			ax_NS8390_init(dev,1);
+			break;
+		}
+	}
+
+	ei_outb(ENISR_RDC, nic_base + EN0_ISR);	/* Ack intr. */
+	ei_status.dmaing &= ~0x01;
+	return;
+}
+
+/* definitions for accessing MII/EEPROM interface */
+
+#define AX_MEMR			EI_SHIFT(0x14)
+#define AX_MEMR_MDC		(1<<0)
+#define AX_MEMR_MDIR		(1<<1)
+#define AX_MEMR_MDI		(1<<2)
+#define AX_MEMR_MDO		(1<<3)
+#define AX_MEMR_EECS		(1<<4)
+#define AX_MEMR_EEI		(1<<5)
+#define AX_MEMR_EEO		(1<<6)
+#define AX_MEMR_EECLK		(1<<7)
+
+/* ax_mii_ei_outbits
+ *
+ * write the specified set of bits to the phy
+*/
+
+static void
+ax_mii_ei_outbits(struct net_device *dev, unsigned int bits, int len)
+{
+	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	void __iomem *memr_addr = (void __iomem *)dev->base_addr + AX_MEMR;
+	unsigned int memr;
+
+	/* clock low, data to output mode */
+	memr = ei_inb(memr_addr);
+	memr &= ~(AX_MEMR_MDC | AX_MEMR_MDIR);
+	ei_outb(memr, memr_addr);
+
+	for (len--; len >= 0; len--) {
+		if (bits & (1 << len))
+			memr |= AX_MEMR_MDO;
+		else
+			memr &= ~AX_MEMR_MDO;
+
+		ei_outb(memr, memr_addr);
+
+		/* clock high */
+
+		ei_outb(memr | AX_MEMR_MDC, memr_addr);
+		udelay(1);
+
+		/* clock low */
+		ei_outb(memr, memr_addr);
+	}
+
+	/* leaves the clock line low, mdir input */
+	memr |= AX_MEMR_MDIR;
+	ei_outb(memr, (void __iomem *)dev->base_addr + AX_MEMR);
+}
+
+/* ax_phy_ei_inbits
+ *
+ * read a specified number of bits from the phy
+*/
+
+static unsigned int
+ax_phy_ei_inbits(struct net_device *dev, int no)
+{
+	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	void __iomem *memr_addr = (void __iomem *)dev->base_addr + AX_MEMR;
+	unsigned int memr;
+	unsigned int result = 0;
+
+	/* clock low, data to input mode */
+	memr = ei_inb(memr_addr);
+	memr &= ~AX_MEMR_MDC;
+	memr |= AX_MEMR_MDIR;
+	ei_outb(memr, memr_addr);
+
+	for (no--; no >= 0; no--) {
+		ei_outb(memr | AX_MEMR_MDC, memr_addr);
+
+		udelay(1);
+
+		if (ei_inb(memr_addr) & AX_MEMR_MDI)
+			result |= (1<<no);
+
+		ei_outb(memr, memr_addr);
+	}
+
+	return result;
+}
+
+/* ax_phy_issueaddr
+ *
+ * use the low level bit shifting routines to send the address
+ * and command to the specified phy
+*/
+
+static void
+ax_phy_issueaddr(struct net_device *dev, int phy_addr, int reg, int opc)
+{
+	if (phy_debug)
+		pr_debug("%s: dev %p, %04x, %04x, %d\n",
+			__FUNCTION__, dev, phy_addr, reg, opc);
+
+	ax_mii_ei_outbits(dev, 0x3f, 6);	/* pre-amble */
+	ax_mii_ei_outbits(dev, 1, 2);		/* frame-start */
+	ax_mii_ei_outbits(dev, opc, 2);		/* op code */
+	ax_mii_ei_outbits(dev, phy_addr, 5);	/* phy address */
+	ax_mii_ei_outbits(dev, reg, 5);		/* reg address */
+}
+
+static int
+ax_phy_read(struct net_device *dev, int phy_addr, int reg)
+{
+	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	unsigned long flags;
+ 	unsigned int result;
+
+      	spin_lock_irqsave(&ei_local->page_lock, flags);
+
+	ax_phy_issueaddr(dev, phy_addr, reg, 2);
+
+	result = ax_phy_ei_inbits(dev, 17);
+	result &= ~(3<<16);
+
+      	spin_unlock_irqrestore(&ei_local->page_lock, flags);
+
+	if (phy_debug)
+		pr_debug("%s: %04x.%04x => read %04x\n", __FUNCTION__,
+			 phy_addr, reg, result);
+
+	return result;
+}
+
+static void
+ax_phy_write(struct net_device *dev, int phy_addr, int reg, int value)
+{
+	struct ei_device *ei = (struct ei_device *) netdev_priv(dev);
+	unsigned long flags;
+
+	printk(KERN_DEBUG "%s: %p, %04x, %04x %04x\n",
+	       __FUNCTION__, dev, phy_addr, reg, value);
+
+      	spin_lock_irqsave(&ei->page_lock, flags);
+
+	ax_phy_issueaddr(dev, phy_addr, reg, 1);
+	ax_mii_ei_outbits(dev, 2, 2);		/* send TA */
+	ax_mii_ei_outbits(dev, value, 16);
+
+      	spin_unlock_irqrestore(&ei->page_lock, flags);
+}
+
+static void ax_mii_expiry(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct ax_device  *ax = to_ax_dev(dev);
+	unsigned long flags;
+
+	spin_lock_irqsave(&ax->mii_lock, flags);
+	mii_check_media(&ax->mii, netif_msg_link(ax), 0);
+	spin_unlock_irqrestore(&ax->mii_lock, flags);
+
+	if (ax->running) {
+		ax->mii_timer.expires = jiffies + HZ*2;
+		add_timer(&ax->mii_timer);
+	}
+}
+
+static int ax_open(struct net_device *dev)
+{
+	struct ax_device  *ax = to_ax_dev(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
+	int ret;
+
+	dev_dbg(ax->dev, "%s: open\n", dev->name);
+
+	ret = request_irq(dev->irq, ax_ei_interrupt, 0, dev->name, dev);
+	if (ret)
+		return ret;
+
+	ret = ax_ei_open(dev);
+	if (ret)
+		return ret;
+
+	/* turn the phy on (if turned off) */
+
+	ei_outb(ax->plat->gpoc_val, ei_local->mem + EI_SHIFT(0x17));
+	ax->running = 1;
+
+	/* start the MII timer */
+
+	init_timer(&ax->mii_timer);
+
+	ax->mii_timer.expires  = jiffies+1;
+	ax->mii_timer.data     = (unsigned long) dev;
+	ax->mii_timer.function = ax_mii_expiry;
+
+	add_timer(&ax->mii_timer);
+
+	return 0;
+}
+
+static int ax_close(struct net_device *dev)
+{
+	struct ax_device *ax = to_ax_dev(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
+
+	dev_dbg(ax->dev, "%s: close\n", dev->name);
+
+	/* turn the phy off */
+
+	ei_outb(ax->plat->gpoc_val | (1<<6),
+	       ei_local->mem + EI_SHIFT(0x17));
+
+	ax->running = 0;
+	wmb();
+
+	del_timer_sync(&ax->mii_timer);
+	ax_ei_close(dev);
+
+	free_irq(dev->irq, dev);
+	return 0;
+}
+
+static int ax_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
+{
+	struct ax_device *ax = to_ax_dev(dev);
+	unsigned long flags;
+	int rc;
+
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	spin_lock_irqsave(&ax->mii_lock, flags);
+	rc = generic_mii_ioctl(&ax->mii, if_mii(req), cmd, NULL);
+	spin_unlock_irqrestore(&ax->mii_lock, flags);
+
+	return rc;
+}
+
+/* ethtool ops */
+
+static void ax_get_drvinfo(struct net_device *dev,
+			   struct ethtool_drvinfo *info)
+{
+	struct ax_device *ax = to_ax_dev(dev);
+
+	strcpy(info->driver, DRV_NAME);
+	strcpy(info->version, DRV_VERSION);
+	strcpy(info->bus_info, ax->dev->name);
+}
+
+static int ax_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct ax_device *ax = to_ax_dev(dev);
+	unsigned long flags;
+
+	spin_lock_irqsave(&ax->mii_lock, flags);
+	mii_ethtool_gset(&ax->mii, cmd);
+	spin_lock_irqsave(&ax->mii_lock, flags);
+
+	return 0;
+}
+
+static int ax_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct ax_device *ax = to_ax_dev(dev);
+	unsigned long flags;
+	int rc;
+
+	spin_lock_irqsave(&ax->mii_lock, flags);
+	rc = mii_ethtool_sset(&ax->mii, cmd);
+	spin_lock_irqsave(&ax->mii_lock, flags);
+
+	return rc;
+}
+
+static int ax_nway_reset(struct net_device *dev)
+{
+	struct ax_device *ax = to_ax_dev(dev);
+	return mii_nway_restart(&ax->mii);
+}
+
+static u32 ax_get_link(struct net_device *dev)
+{
+	struct ax_device *ax = to_ax_dev(dev);
+	return mii_link_ok(&ax->mii);
+}
+
+static const struct ethtool_ops ax_ethtool_ops = {
+	.get_drvinfo		= ax_get_drvinfo,
+	.get_settings		= ax_get_settings,
+	.set_settings		= ax_set_settings,
+	.nway_reset		= ax_nway_reset,
+	.get_link		= ax_get_link,
+	.get_perm_addr		= ethtool_op_get_perm_addr,
+};
+
+/* setup code */
+
+static void ax_initial_setup(struct net_device *dev, struct ei_device *ei_local)
+{
+	void __iomem *ioaddr = ei_local->mem;
+	struct ax_device *ax = to_ax_dev(dev);
+
+	/* Select page 0*/
+	ei_outb(E8390_NODMA+E8390_PAGE0+E8390_STOP, ioaddr + E8390_CMD);
+
+	/* set to byte access */
+	ei_outb(ax->plat->dcr_val & ~1, ioaddr + EN0_DCFG);
+	ei_outb(ax->plat->gpoc_val, ioaddr + EI_SHIFT(0x17));
+}
+
+/* ax_init_dev
+ *
+ * initialise the specified device, taking care to note the MAC
+ * address it may already have (if configured), ensure
+ * the device is ready to be used by lib8390.c and registerd with
+ * the network layer.
+ */
+
+static int ax_init_dev(struct net_device *dev, int first_init)
+{
+	struct ei_device *ei_local = netdev_priv(dev);
+	struct ax_device *ax = to_ax_dev(dev);
+	void __iomem *ioaddr = ei_local->mem;
+	unsigned int start_page;
+	unsigned int stop_page;
+	int ret;
+	int i;
+
+	ret = ax_initial_check(dev);
+	if (ret)
+		goto err_out;
+
+	/* setup goes here */
+
+	ax_initial_setup(dev, ei_local);
+
+	/* read the mac from the card prom if we need it */
+
+	if (first_init && ax->plat->flags & AXFLG_HAS_EEPROM) {
+		unsigned char SA_prom[32];
+
+		for(i = 0; i < sizeof(SA_prom); i+=2) {
+			SA_prom[i] = ei_inb(ioaddr + NE_DATAPORT);
+			SA_prom[i+1] = ei_inb(ioaddr + NE_DATAPORT);
+		}
+
+		if (ax->plat->wordlength == 2)
+			for (i = 0; i < 16; i++)
+				SA_prom[i] = SA_prom[i+i];
+
+		memcpy(dev->dev_addr,  SA_prom, 6);
+	}
+
+	if (ax->plat->wordlength == 2) {
+		/* We must set the 8390 for word mode. */
+		ei_outb(ax->plat->dcr_val, ei_local->mem + EN0_DCFG);
+		start_page = NESM_START_PG;
+		stop_page = NESM_STOP_PG;
+	} else {
+		start_page = NE1SM_START_PG;
+		stop_page = NE1SM_STOP_PG;
+	}
+
+	/* load the mac-address from the device if this is the
+	 * first time we've initialised */
+
+	if (first_init && ax->plat->flags & AXFLG_MAC_FROMDEV) {
+		ei_outb(E8390_NODMA + E8390_PAGE1 + E8390_STOP,
+			ei_local->mem + E8390_CMD); /* 0x61 */
+
+		for (i = 0 ; i < ETHER_ADDR_LEN ; i++)
+			dev->dev_addr[i] = ei_inb(ioaddr + EN1_PHYS_SHIFT(i));
+	}
+
+	ax_reset_8390(dev);
+
+	ei_status.name = "AX88796";
+	ei_status.tx_start_page = start_page;
+	ei_status.stop_page = stop_page;
+	ei_status.word16 = (ax->plat->wordlength == 2);
+	ei_status.rx_start_page = start_page + TX_PAGES;
+
+#ifdef PACKETBUF_MEMSIZE
+	 /* Allow the packet buffer size to be overridden by know-it-alls. */
+	ei_status.stop_page = ei_status.tx_start_page + PACKETBUF_MEMSIZE;
+#endif
+
+	ei_status.reset_8390	= &ax_reset_8390;
+	ei_status.block_input	= &ax_block_input;
+	ei_status.block_output	= &ax_block_output;
+	ei_status.get_8390_hdr	= &ax_get_8390_hdr;
+	ei_status.priv = 0;
+
+	dev->open		= ax_open;
+	dev->stop		= ax_close;
+	dev->do_ioctl		= ax_ioctl;
+	dev->ethtool_ops	= &ax_ethtool_ops;
+
+	ax->msg_enable		= NETIF_MSG_LINK;
+	ax->mii.phy_id_mask	= 0x1f;
+	ax->mii.reg_num_mask	= 0x1f;
+	ax->mii.phy_id		= 0x10;		/* onboard phy */
+	ax->mii.force_media	= 0;
+	ax->mii.full_duplex	= 0;
+	ax->mii.mdio_read	= ax_phy_read;
+	ax->mii.mdio_write	= ax_phy_write;
+	ax->mii.dev		= dev;
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = ax_ei_poll;
+#endif
+	ax_NS8390_init(dev, 0);
+
+	if (first_init) {
+		printk("AX88796: %dbit, irq %d, %lx, MAC: ",
+		       ei_status.word16 ? 16:8, dev->irq, dev->base_addr);
+
+		for (i = 0; i < ETHER_ADDR_LEN; i++)
+			printk("%2.2x%c", dev->dev_addr[i],
+			       (i < (ETHER_ADDR_LEN-1) ? ':' : ' '));
+
+		printk("\n");
+	}
+
+	ret = register_netdev(dev);
+	if (ret)
+		goto out_irq;
+
+	return 0;
+
+ out_irq:
+	/* cleanup irq */
+	free_irq(dev->irq, dev);
+ err_out:
+	return ret;
+}
+
+static int ax_remove(struct platform_device *_dev)
+{
+	struct net_device *dev = platform_get_drvdata(_dev);
+	struct ax_device  *ax;
+
+	ax = to_ax_dev(dev);
+
+	unregister_netdev(dev);
+	free_irq(dev->irq, dev);
+
+	iounmap(ei_status.mem);
+	release_resource(ax->mem);
+	kfree(ax->mem);
+
+	if (ax->map2) {
+		iounmap(ax->map2);
+		release_resource(ax->mem2);
+		kfree(ax->mem2);
+	}
+
+	free_netdev(dev);
+
+	return 0;
+}
+
+/* ax_probe
+ *
+ * This is the entry point when the platform device system uses to
+ * notify us of a new device to attach to. Allocate memory, find
+ * the resources and information passed, and map the necessary registers.
+*/
+
+static int ax_probe(struct platform_device *pdev)
+{
+	struct net_device *dev;
+	struct ax_device  *ax;
+	struct resource   *res;
+	size_t size;
+	int ret;
+
+	dev = ax__alloc_ei_netdev(sizeof(struct ax_device));
+	if (dev == NULL)
+		return -ENOMEM;
+
+	/* ok, let's setup our device */
+	ax = to_ax_dev(dev);
+
+	memset(ax, 0, sizeof(struct ax_device));
+
+	spin_lock_init(&ax->mii_lock);
+
+	ax->dev = pdev;
+	ax->plat = pdev->dev.platform_data;
+	platform_set_drvdata(pdev, dev);
+
+	ei_status.rxcr_base  = ax->plat->rcr_val;
+
+	/* find the platform resources */
+
+	dev->irq  = platform_get_irq(pdev, 0);
+	if (dev->irq < 0) {
+		dev_err(&pdev->dev, "no IRQ specified\n");
+		ret = -ENXIO;
+		goto exit_mem;
+	}
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (res == NULL) {
+		dev_err(&pdev->dev, "no MEM specified\n");
+		ret = -ENXIO;
+		goto exit_mem;
+	}
+
+	size = (res->end - res->start) + 1;
+
+	/* setup the register offsets from either the platform data
+	 * or by using the size of the resource provided */
+
+	if (ax->plat->reg_offsets)
+		ei_status.reg_offset = ax->plat->reg_offsets;
+	else {
+		ei_status.reg_offset = ax->reg_offsets;
+		for (ret = 0; ret < 0x18; ret++)
+			ax->reg_offsets[ret] = (size / 0x18) * ret;
+	}
+
+	ax->mem = request_mem_region(res->start, size, pdev->name);
+	if (ax->mem == NULL) {
+		dev_err(&pdev->dev, "cannot reserve registers\n");
+ 		ret = -ENXIO;
+		goto exit_mem;
+	}
+
+	ei_status.mem = ioremap(res->start, size);
+	dev->base_addr = (long)ei_status.mem;
+
+	if (ei_status.mem == NULL) {
+		dev_err(&pdev->dev, "Cannot ioremap area (%08zx,%08zx)\n",
+			res->start, res->end);
+
+ 		ret = -ENXIO;
+		goto exit_req;
+	}
+
+	/* look for reset area */
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	if (res == NULL) {
+		if (!ax->plat->reg_offsets) {
+			for (ret = 0; ret < 0x20; ret++)
+				ax->reg_offsets[ret] = (size / 0x20) * ret;
+		}
+
+		ax->map2 = NULL;
+	} else {
+ 		size = (res->end - res->start) + 1;
+
+		ax->mem2 = request_mem_region(res->start, size, pdev->name);
+		if (ax->mem == NULL) {
+			dev_err(&pdev->dev, "cannot reserve registers\n");
+			ret = -ENXIO;
+			goto exit_mem1;
+		}
+
+		ax->map2 = ioremap(res->start, size);
+		if (ax->map2 == NULL) {
+			dev_err(&pdev->dev, "cannot map reset register");
+			ret = -ENXIO;
+			goto exit_mem2;
+		}
+
+		ei_status.reg_offset[0x1f] = ax->map2 - ei_status.mem;
+	}
+
+	/* got resources, now initialise and register device */
+
+	ret = ax_init_dev(dev, 1);
+	if (!ret)
+		return 0;
+
+	if (ax->map2 == NULL)
+		goto exit_mem1;
+
+	iounmap(ax->map2);
+
+ exit_mem2:
+	release_resource(ax->mem2);
+	kfree(ax->mem2);
+
+ exit_mem1:
+	iounmap(ei_status.mem);
+
+ exit_req:
+	release_resource(ax->mem);
+	kfree(ax->mem);
+
+ exit_mem:
+	free_netdev(dev);
+
+	return ret;
+}
+
+/* suspend and resume */
+
+#ifdef CONFIG_PM
+static int ax_suspend(struct platform_device *dev, pm_message_t state)
+{
+	struct net_device *ndev = platform_get_drvdata(dev);
+	struct ax_device  *ax = to_ax_dev(ndev);
+
+	ax->resume_open = ax->running;
+
+	netif_device_detach(ndev);
+	ax_close(ndev);
+
+	return 0;
+}
+
+static int ax_resume(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct ax_device  *ax = to_ax_dev(ndev);
+
+	ax_initial_setup(ndev, netdev_priv(ndev));
+	ax_NS8390_init(ndev, ax->resume_open);
+	netif_device_attach(ndev);
+
+	if (ax->resume_open)
+		ax_open(ndev);
+
+	return 0;
+}
+
+#else
+#define ax_suspend NULL
+#define ax_resume  NULL
+#endif
+
+static struct platform_driver axdrv = {
+	.driver	= {
+		.name		= "ax88796",
+		.owner		= THIS_MODULE,
+	},
+	.probe		= ax_probe,
+	.remove		= ax_remove,
+	.suspend	= ax_suspend,
+	.resume		= ax_resume,
+};
+
+static int __init axdrv_init(void)
+{
+	return platform_driver_register(&axdrv);
+}
+
+static void __exit axdrv_exit(void)
+{
+	platform_driver_unregister(&axdrv);
+}
+
+module_init(axdrv_init);
+module_exit(axdrv_exit);
+
+MODULE_DESCRIPTION("AX88796 10/100 Ethernet platform driver");
+MODULE_AUTHOR("Ben Dooks, <ben@simtec.co.uk>");
+MODULE_LICENSE("GPL v2");
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6287ffb..cb9cb30 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -187,7 +187,7 @@ static void bond_send_gratuitous_arp(struct bonding *bond);
 
 /*---------------------------- General routines -----------------------------*/
 
-const char *bond_mode_name(int mode)
+static const char *bond_mode_name(int mode)
 {
 	switch (mode) {
 	case BOND_MODE_ROUNDROBIN :
@@ -1224,7 +1224,8 @@ static void bond_detach_slave(struct bonding *bond, struct slave *slave)
 
 /*---------------------------------- IOCTL ----------------------------------*/
 
-int bond_sethwaddr(struct net_device *bond_dev, struct net_device *slave_dev)
+static int bond_sethwaddr(struct net_device *bond_dev,
+			  struct net_device *slave_dev)
 {
 	dprintk("bond_dev=%p\n", bond_dev);
 	dprintk("slave_dev=%p\n", slave_dev);
@@ -1390,6 +1391,11 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		goto err_free;
 	}
 
+	res = netdev_set_master(slave_dev, bond_dev);
+	if (res) {
+		dprintk("Error %d calling netdev_set_master\n", res);
+		goto err_close;
+	}
 	/* open the slave since the application closed it */
 	res = dev_open(slave_dev);
 	if (res) {
@@ -1397,12 +1403,6 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		goto err_restore_mac;
 	}
 
-	res = netdev_set_master(slave_dev, bond_dev);
-	if (res) {
-		dprintk("Error %d calling netdev_set_master\n", res);
-		goto err_close;
-	}
-
 	new_slave->dev = slave_dev;
 	slave_dev->priv_flags |= IFF_BONDING;
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index a891021..6dcbd25 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -301,13 +301,11 @@ int bond_create_slave_symlinks(struct net_device *master, struct net_device *sla
 void bond_destroy_slave_symlinks(struct net_device *master, struct net_device *slave);
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
-int bond_sethwaddr(struct net_device *bond_dev, struct net_device *slave_dev);
 void bond_mii_monitor(struct net_device *bond_dev);
 void bond_loadbalance_arp_mon(struct net_device *bond_dev);
 void bond_activebackup_arp_mon(struct net_device *bond_dev);
 void bond_set_mode_ops(struct bonding *bond, int mode);
 int bond_parse_parm(char *mode_arg, struct bond_parm_tbl *tbl);
-const char *bond_mode_name(int mode);
 void bond_select_active_slave(struct bonding *bond);
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
 void bond_register_arp(struct bonding *);
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 15defe4..6fd1e52 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -43,6 +43,7 @@
 #include <linux/proc_fs.h>
 #include <linux/rtnetlink.h>
 #include <linux/firmware.h>
+#include <linux/log2.h>
 #include <asm/uaccess.h>
 
 #include "common.h"
@@ -1818,8 +1819,8 @@ static int cxgb_extension_ioctl(struct net_device *dev, void __user *useraddr)
 			return -EBUSY;
 		if (copy_from_user(&m, useraddr, sizeof(m)))
 			return -EFAULT;
-		if (!m.rx_pg_sz || (m.rx_pg_sz & (m.rx_pg_sz - 1)) ||
-			!m.tx_pg_sz || (m.tx_pg_sz & (m.tx_pg_sz - 1)))
+		if (!is_power_of_2(m.rx_pg_sz) ||
+			!is_power_of_2(m.tx_pg_sz))
 			return -EINVAL;	/* not power of 2 */
 		if (!(m.rx_pg_sz & 0x14000))
 			return -EINVAL;	/* not 16KB or 64KB */
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 763810c..74ea637 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -159,7 +159,7 @@
 
 #define DRV_NAME		"e100"
 #define DRV_EXT			"-NAPI"
-#define DRV_VERSION		"3.5.17-k4"DRV_EXT
+#define DRV_VERSION		"3.5.23-k4"DRV_EXT
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
 #define DRV_COPYRIGHT		"Copyright(c) 1999-2006 Intel Corporation"
 #define PFX			DRV_NAME ": "
@@ -1024,10 +1024,16 @@ static void e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 		config->mwi_enable = 0x1;	/* 1=enable, 0=disable */
 		config->standard_tcb = 0x0;	/* 1=standard, 0=extended */
 		config->rx_long_ok = 0x1;	/* 1=VLANs ok, 0=standard */
-		if(nic->mac >= mac_82559_D101M)
+		if (nic->mac >= mac_82559_D101M) {
 			config->tno_intr = 0x1;		/* TCO stats enable */
-		else
+			/* Enable TCO in extended config */
+			if (nic->mac >= mac_82551_10) {
+				config->byte_count = 0x20; /* extended bytes */
+				config->rx_d102_mode = 0x1; /* GMRC for TCO */
+			}
+		} else {
 			config->standard_stat_counter = 0x0;
+		}
 	}
 
 	DPRINTK(HW, DEBUG, "[00-07]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index abaf3ac..f03f070 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -39,7 +39,13 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0065"
+#define DRV_VERSION	"EHEA_0067"
+
+/* EHEA capability flags */
+#define DLPAR_PORT_ADD_REM 1
+#define DLPAR_MEM_ADD 2
+#define DLPAR_MEM_REM 4
+#define EHEA_CAPABILITIES (DLPAR_PORT_ADD_REM)
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index bdb5241..383144d 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2923,6 +2923,15 @@ static int check_module_parm(void)
 	return ret;
 }
 
+static ssize_t ehea_show_capabilities(struct device_driver *drv,
+				      char *buf)
+{
+	return sprintf(buf, "%d", EHEA_CAPABILITIES);
+}
+
+static DRIVER_ATTR(capabilities, S_IRUSR | S_IRGRP | S_IROTH,
+		   ehea_show_capabilities, NULL);
+
 int __init ehea_module_init(void)
 {
 	int ret;
@@ -2934,8 +2943,19 @@ int __init ehea_module_init(void)
 	if (ret)
 		goto out;
 	ret = ibmebus_register_driver(&ehea_driver);
-	if (ret)
+	if (ret) {
 		ehea_error("failed registering eHEA device driver on ebus");
+		goto out;
+	}
+
+	ret = driver_create_file(&ehea_driver.driver,
+				 &driver_attr_capabilities);
+	if (ret) {
+		ehea_error("failed to register capabilities attribute, ret=%d",
+			   ret);
+		ibmebus_unregister_driver(&ehea_driver);
+		goto out;
+	}
 
 out:
 	return ret;
@@ -2943,6 +2963,7 @@ out:
 
 static void __exit ehea_module_exit(void)
 {
+	driver_remove_file(&ehea_driver.driver, &driver_attr_capabilities);
 	ibmebus_unregister_driver(&ehea_driver);
 }
 
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index f749e07..3ca1e8e 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -352,13 +352,12 @@ static u64 nic_find(struct ioc3 *ioc3, int *last)
 
 static int nic_init(struct ioc3 *ioc3)
 {
-	const char *type;
+	const char *unknown = "unknown";
+	const char *type = unknown;
 	u8 crc;
 	u8 serial[6];
 	int save = 0, i;
 
-	type = "unknown";
-
 	while (1) {
 		u64 reg;
 		reg = nic_find(ioc3, &save);
@@ -392,7 +391,7 @@ static int nic_init(struct ioc3 *ioc3)
 	}
 
 	printk("Found %s NIC", type);
-	if (type != "unknown") {
+	if (type != unknown) {
 		printk (" registration number %02x:%02x:%02x:%02x:%02x:%02x,"
 			" CRC %02x", serial[0], serial[1], serial[2],
 			serial[3], serial[4], serial[5], crc);
@@ -1103,20 +1102,28 @@ static int ioc3_close(struct net_device *dev)
  * MiniDINs; all other subdevices are left swinging in the wind, leave
  * them disabled.
  */
-static inline int ioc3_is_menet(struct pci_dev *pdev)
+
+static int ioc3_adjacent_is_ioc3(struct pci_dev *pdev, int slot)
+{
+	struct pci_dev *dev = pci_get_slot(pdev->bus, PCI_DEVFN(slot, 0));
+	int ret = 0;
+
+	if (dev) {
+		if (dev->vendor == PCI_VENDOR_ID_SGI &&
+			dev->device == PCI_DEVICE_ID_SGI_IOC3)
+			ret = 1;
+		pci_dev_put(dev);
+	}
+
+	return ret;
+}
+
+static int ioc3_is_menet(struct pci_dev *pdev)
 {
-	struct pci_dev *dev;
-
-	return pdev->bus->parent == NULL
-	       && (dev = pci_find_slot(pdev->bus->number, PCI_DEVFN(0, 0)))
-	       && dev->vendor == PCI_VENDOR_ID_SGI
-	       && dev->device == PCI_DEVICE_ID_SGI_IOC3
-	       && (dev = pci_find_slot(pdev->bus->number, PCI_DEVFN(1, 0)))
-	       && dev->vendor == PCI_VENDOR_ID_SGI
-	       && dev->device == PCI_DEVICE_ID_SGI_IOC3
-	       && (dev = pci_find_slot(pdev->bus->number, PCI_DEVFN(2, 0)))
-	       && dev->vendor == PCI_VENDOR_ID_SGI
-	       && dev->device == PCI_DEVICE_ID_SGI_IOC3;
+	return pdev->bus->parent == NULL &&
+	       ioc3_adjacent_is_ioc3(pdev, 0) &&
+	       ioc3_adjacent_is_ioc3(pdev, 1) &&
+	       ioc3_adjacent_is_ioc3(pdev, 2);
 }
 
 #ifdef CONFIG_SERIAL_8250
diff --git a/drivers/net/macmace.c b/drivers/net/macmace.c
index fef3193..9a343b9 100644
--- a/drivers/net/macmace.c
+++ b/drivers/net/macmace.c
@@ -577,7 +577,7 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
 	struct mace_data *mp = netdev_priv(dev);
 	volatile struct mace *mb = mp->mace;
 	int intr, fs;
-	unsigned int flags;
+	unsigned long flags;
 
 	/* don't want the dma interrupt handler to fire */
 	local_irq_save(flags);
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index d0cc122..e1732c1 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -60,6 +60,7 @@
 #include <linux/crc32.h>
 #include <linux/moduleparam.h>
 #include <linux/io.h>
+#include <linux/log2.h>
 #include <net/checksum.h>
 #include <asm/byteorder.h>
 #include <asm/io.h>
@@ -1804,7 +1805,7 @@ static int myri10ge_open(struct net_device *dev)
 	 */
 	big_pow2 = dev->mtu + ETH_HLEN + VLAN_HLEN + MXGEFW_PAD;
 	if (big_pow2 < MYRI10GE_ALLOC_SIZE / 2) {
-		while ((big_pow2 & (big_pow2 - 1)) != 0)
+		while (!is_power_of_2(big_pow2))
 			big_pow2++;
 		mgp->big_bytes = dev->mtu + ETH_HLEN + VLAN_HLEN + MXGEFW_PAD;
 	} else {
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 6195037..325269d 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1097,109 +1097,6 @@ int netxen_nic_change_mtu(struct net_device *netdev, int new_mtu);
 int netxen_nic_set_mac(struct net_device *netdev, void *p);
 struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev);
 
-static inline void netxen_nic_disable_int(struct netxen_adapter *adapter)
-{
-	uint32_t	mask = 0x7ff;
-	int retries = 32;
-
-	DPRINTK(1, INFO, "Entered ISR Disable \n");
-
-	switch (adapter->portnum) {
-	case 0:
-		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_0));
-		break;
-	case 1:
-		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_1));
-		break;
-	case 2:
-		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_2));
-		break;
-	case 3:
-		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_3));
-		break;
-	}
-
-	if (adapter->intr_scheme != -1 &&
-		adapter->intr_scheme != INTR_SCHEME_PERPORT) {
-		writel(mask,
-			(void *)(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK)));
-	}
-
-	/* Window = 0 or 1 */
-	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
-		do {
-			writel(0xffffffff, (void *)
-				(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_TARGET_STATUS)));
-			mask = readl((void *)
-					(pci_base_offset(adapter, ISR_INT_VECTOR)));
-			if (!(mask & 0x80))
-				break;
-			udelay(10);
-		} while (--retries);
-
-		if (!retries) {
-			printk(KERN_NOTICE "%s: Failed to disable interrupt completely\n",
-					netxen_nic_driver_name);
-		}
-	}
-
-	DPRINTK(1, INFO, "Done with Disable Int\n");
-
-	return;
-}
-
-static inline void netxen_nic_enable_int(struct netxen_adapter *adapter)
-{
-	u32 mask;
-
-	DPRINTK(1, INFO, "Entered ISR Enable \n");
-
-	if (adapter->intr_scheme != -1 &&
-		adapter->intr_scheme != INTR_SCHEME_PERPORT) {
-		switch (adapter->ahw.board_type) {
-		case NETXEN_NIC_GBE:
-			mask  =  0x77b;
-			break;
-		case NETXEN_NIC_XGBE:
-			mask  =  0x77f;
-			break;
-		default:
-			mask  =  0x7ff;
-			break;
-		}
-
-		writel(mask,
-			(void *)(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK)));
-	}
-	switch (adapter->portnum) {
-	case 0:
-		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_0));
-		break;
-	case 1:
-		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_1));
-		break;
-	case 2:
-		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_2));
-		break;
-	case 3:
-		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_3));
-		break;
-	}
-
-	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
-		mask = 0xbff;
-		if (adapter->intr_scheme != -1 &&
-			adapter->intr_scheme != INTR_SCHEME_PERPORT) {
-			writel(0X0, NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
-		}
-		writel(mask,
-			(void *)(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_TARGET_MASK)));
-	}
-
-	DPRINTK(1, INFO, "Done with enable Int\n");
-
-	return;
-}
 
 /*
  * NetXen Board information
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index a66ff58..56f8197 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -156,6 +156,103 @@ static inline void netxen_nic_update_cmd_consumer(struct netxen_adapter *adapter
 #define	ADAPTER_LIST_SIZE 12
 int netxen_cards_found;
 
+static void netxen_nic_disable_int(struct netxen_adapter *adapter)
+{
+	uint32_t	mask = 0x7ff;
+	int retries = 32;
+
+	DPRINTK(1, INFO, "Entered ISR Disable \n");
+
+	switch (adapter->portnum) {
+	case 0:
+		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_0));
+		break;
+	case 1:
+		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_1));
+		break;
+	case 2:
+		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_2));
+		break;
+	case 3:
+		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_3));
+		break;
+	}
+
+	if (adapter->intr_scheme != -1 &&
+	    adapter->intr_scheme != INTR_SCHEME_PERPORT)
+		writel(mask,PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK));
+
+	/* Window = 0 or 1 */
+	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
+		do {
+			writel(0xffffffff,
+			       PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_TARGET_STATUS));
+			mask = readl(pci_base_offset(adapter, ISR_INT_VECTOR));
+			if (!(mask & 0x80))
+				break;
+			udelay(10);
+		} while (--retries);
+
+		if (!retries) {
+			printk(KERN_NOTICE "%s: Failed to disable interrupt completely\n",
+					netxen_nic_driver_name);
+		}
+	}
+
+	DPRINTK(1, INFO, "Done with Disable Int\n");
+}
+
+static void netxen_nic_enable_int(struct netxen_adapter *adapter)
+{
+	u32 mask;
+
+	DPRINTK(1, INFO, "Entered ISR Enable \n");
+
+	if (adapter->intr_scheme != -1 &&
+		adapter->intr_scheme != INTR_SCHEME_PERPORT) {
+		switch (adapter->ahw.board_type) {
+		case NETXEN_NIC_GBE:
+			mask  =  0x77b;
+			break;
+		case NETXEN_NIC_XGBE:
+			mask  =  0x77f;
+			break;
+		default:
+			mask  =  0x7ff;
+			break;
+		}
+
+		writel(mask, PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK));
+	}
+
+	switch (adapter->portnum) {
+	case 0:
+		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_0));
+		break;
+	case 1:
+		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_1));
+		break;
+	case 2:
+		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_2));
+		break;
+	case 3:
+		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_3));
+		break;
+	}
+
+	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
+		mask = 0xbff;
+		if (adapter->intr_scheme != -1 &&
+			adapter->intr_scheme != INTR_SCHEME_PERPORT) {
+			writel(0X0, NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
+		}
+		writel(mask,
+		       PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_TARGET_MASK));
+	}
+
+	DPRINTK(1, INFO, "Done with enable Int\n");
+}
+
 /*
  * netxen_nic_probe()
  *
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index f2613c2..63de89e 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -1581,6 +1581,7 @@ static struct pcmcia_device_id pcnet_ids[] = {
 	PCMCIA_DEVICE_MANF_CARD(0x0274, 0x1103),
 	PCMCIA_DEVICE_MANF_CARD(0x0274, 0x1121),
 	PCMCIA_DEVICE_PROD_ID12("2408LAN", "Ethernet", 0x352fff7f, 0x00b2e941),
+	PCMCIA_DEVICE_PROD_ID1234("Socket", "CF 10/100 Ethernet Card", "Revision B", "05/11/06", 0xb38bcc2e, 0x4de88352, 0xeaca6c8d, 0x7e57c22e),
 	PCMCIA_DEVICE_PROD_ID123("Cardwell", "PCMCIA", "ETHERNET", 0x9533672e, 0x281f1c5d, 0x3ff7175b),
 	PCMCIA_DEVICE_PROD_ID123("CNet  ", "CN30BC", "ETHERNET", 0x9fe55d3d, 0x85601198, 0x3ff7175b),
 	PCMCIA_DEVICE_PROD_ID123("Digital", "Ethernet", "Adapter", 0x9999ab35, 0x00b2e941, 0x4b0d829e),
diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index fbe1104..d2ede5f 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -254,77 +254,84 @@ static int m88e1145_config_init(struct phy_device *phydev)
 	return 0;
 }
 
-static struct phy_driver m88e1101_driver = {
-	.phy_id = 0x01410c60,
-	.phy_id_mask = 0xfffffff0,
-	.name = "Marvell 88E1101",
-	.features = PHY_GBIT_FEATURES,
-	.flags = PHY_HAS_INTERRUPT,
-	.config_aneg = &marvell_config_aneg,
-	.read_status = &genphy_read_status,
-	.ack_interrupt = &marvell_ack_interrupt,
-	.config_intr = &marvell_config_intr,
-	.driver = {.owner = THIS_MODULE,},
-};
-
-static struct phy_driver m88e1111_driver = {
-	.phy_id = 0x01410cc0,
-	.phy_id_mask = 0xfffffff0,
-	.name = "Marvell 88E1111",
-	.features = PHY_GBIT_FEATURES,
-	.flags = PHY_HAS_INTERRUPT,
-	.config_aneg = &marvell_config_aneg,
-	.read_status = &genphy_read_status,
-	.ack_interrupt = &marvell_ack_interrupt,
-	.config_intr = &marvell_config_intr,
-	.config_init = &m88e1111_config_init,
-	.driver = {.owner = THIS_MODULE,},
-};
-
-static struct phy_driver m88e1145_driver = {
-	.phy_id = 0x01410cd0,
-	.phy_id_mask = 0xfffffff0,
-	.name = "Marvell 88E1145",
-	.features = PHY_GBIT_FEATURES,
-	.flags = PHY_HAS_INTERRUPT,
-	.config_init = &m88e1145_config_init,
-	.config_aneg = &marvell_config_aneg,
-	.read_status = &genphy_read_status,
-	.ack_interrupt = &marvell_ack_interrupt,
-	.config_intr = &marvell_config_intr,
-	.driver = {.owner = THIS_MODULE,},
+static struct phy_driver marvell_drivers[] = {
+	{
+		.phy_id = 0x01410c60,
+		.phy_id_mask = 0xfffffff0,
+		.name = "Marvell 88E1101",
+		.features = PHY_GBIT_FEATURES,
+		.flags = PHY_HAS_INTERRUPT,
+		.config_aneg = &marvell_config_aneg,
+		.read_status = &genphy_read_status,
+		.ack_interrupt = &marvell_ack_interrupt,
+		.config_intr = &marvell_config_intr,
+		.driver = {.owner = THIS_MODULE,},
+	},
+	{
+		.phy_id = 0x01410c90,
+		.phy_id_mask = 0xfffffff0,
+		.name = "Marvell 88E1112",
+		.features = PHY_GBIT_FEATURES,
+		.flags = PHY_HAS_INTERRUPT,
+		.config_init = &m88e1111_config_init,
+		.config_aneg = &marvell_config_aneg,
+		.read_status = &genphy_read_status,
+		.ack_interrupt = &marvell_ack_interrupt,
+		.config_intr = &marvell_config_intr,
+		.driver = {.owner = THIS_MODULE,},
+	},
+	{
+		.phy_id = 0x01410cc0,
+		.phy_id_mask = 0xfffffff0,
+		.name = "Marvell 88E1111",
+		.features = PHY_GBIT_FEATURES,
+		.flags = PHY_HAS_INTERRUPT,
+		.config_init = &m88e1111_config_init,
+		.config_aneg = &marvell_config_aneg,
+		.read_status = &genphy_read_status,
+		.ack_interrupt = &marvell_ack_interrupt,
+		.config_intr = &marvell_config_intr,
+		.driver = {.owner = THIS_MODULE,},
+	},
+	{
+		.phy_id = 0x01410cd0,
+		.phy_id_mask = 0xfffffff0,
+		.name = "Marvell 88E1145",
+		.features = PHY_GBIT_FEATURES,
+		.flags = PHY_HAS_INTERRUPT,
+		.config_init = &m88e1145_config_init,
+		.config_aneg = &marvell_config_aneg,
+		.read_status = &genphy_read_status,
+		.ack_interrupt = &marvell_ack_interrupt,
+		.config_intr = &marvell_config_intr,
+		.driver = {.owner = THIS_MODULE,},
+	}
 };
 
 static int __init marvell_init(void)
 {
 	int ret;
+	int i;
 
-	ret = phy_driver_register(&m88e1101_driver);
-	if (ret)
-		return ret;
+	for (i = 0; i < ARRAY_SIZE(marvell_drivers); i++) {
+		ret = phy_driver_register(&marvell_drivers[i]);
 
-	ret = phy_driver_register(&m88e1111_driver);
-	if (ret)
-		goto err1111;
-
-	ret = phy_driver_register(&m88e1145_driver);
-	if (ret)
-		goto err1145;
+		if (ret) {
+			while (i-- > 0)
+				phy_driver_unregister(&marvell_drivers[i]);
+			return ret;
+		}
+	}
 
 	return 0;
-
-err1145:
-	phy_driver_unregister(&m88e1111_driver);
-err1111:
-	phy_driver_unregister(&m88e1101_driver);
-	return ret;
 }
 
 static void __exit marvell_exit(void)
 {
-	phy_driver_unregister(&m88e1101_driver);
-	phy_driver_unregister(&m88e1111_driver);
-	phy_driver_unregister(&m88e1145_driver);
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(marvell_drivers); i++)
+		phy_driver_unregister(&marvell_drivers[i]);
 }
 
 module_init(marvell_init);
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
new file mode 100644
index 0000000..08d2506
--- /dev/null
+++ b/drivers/net/ps3_gelic_net.c
@@ -0,0 +1,1576 @@
+/*
+ *  PS3 gelic network driver.
+ *
+ * Copyright (C) 2007 Sony Computer Entertainment Inc.
+ * Copyright 2006, 2007 Sony Corporation
+ *
+ * This file is based on: spider_net.c
+ *
+ * (C) Copyright IBM Corp. 2005
+ *
+ * Authors : Utz Bacher <utz.bacher@de.ibm.com>
+ *           Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#undef DEBUG
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/if_vlan.h>
+
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+
+#include <linux/dma-mapping.h>
+#include <net/checksum.h>
+#include <asm/firmware.h>
+#include <asm/ps3.h>
+#include <asm/lv1call.h>
+
+#include "ps3_gelic_net.h"
+
+#define DRV_NAME "Gelic Network Driver"
+#define DRV_VERSION "1.0"
+
+MODULE_AUTHOR("SCE Inc.");
+MODULE_DESCRIPTION("Gelic Network driver");
+MODULE_LICENSE("GPL");
+
+static inline struct device *ctodev(struct gelic_net_card *card)
+{
+	return &card->dev->core;
+}
+static inline unsigned int bus_id(struct gelic_net_card *card)
+{
+	return card->dev->bus_id;
+}
+static inline unsigned int dev_id(struct gelic_net_card *card)
+{
+	return card->dev->dev_id;
+}
+
+/* set irq_mask */
+static int gelic_net_set_irq_mask(struct gelic_net_card *card, u64 mask)
+{
+	int status;
+
+	status = lv1_net_set_interrupt_mask(bus_id(card), dev_id(card),
+					    mask, 0);
+	if (status)
+		dev_info(ctodev(card),
+			 "lv1_net_set_interrupt_mask failed %d\n", status);
+	return status;
+}
+static inline void gelic_net_rx_irq_on(struct gelic_net_card *card)
+{
+	gelic_net_set_irq_mask(card, card->ghiintmask | GELIC_NET_RXINT);
+}
+static inline void gelic_net_rx_irq_off(struct gelic_net_card *card)
+{
+	gelic_net_set_irq_mask(card, card->ghiintmask & ~GELIC_NET_RXINT);
+}
+/**
+ * gelic_net_get_descr_status -- returns the status of a descriptor
+ * @descr: descriptor to look at
+ *
+ * returns the status as in the dmac_cmd_status field of the descriptor
+ */
+static enum gelic_net_descr_status
+gelic_net_get_descr_status(struct gelic_net_descr *descr)
+{
+	u32 cmd_status;
+
+	cmd_status = descr->dmac_cmd_status;
+	cmd_status >>= GELIC_NET_DESCR_IND_PROC_SHIFT;
+	return cmd_status;
+}
+
+/**
+ * gelic_net_set_descr_status -- sets the status of a descriptor
+ * @descr: descriptor to change
+ * @status: status to set in the descriptor
+ *
+ * changes the status to the specified value. Doesn't change other bits
+ * in the status
+ */
+static void gelic_net_set_descr_status(struct gelic_net_descr *descr,
+				       enum gelic_net_descr_status status)
+{
+	u32 cmd_status;
+
+	/* read the status */
+	cmd_status = descr->dmac_cmd_status;
+	/* clean the upper 4 bits */
+	cmd_status &= GELIC_NET_DESCR_IND_PROC_MASKO;
+	/* add the status to it */
+	cmd_status |= ((u32)status) << GELIC_NET_DESCR_IND_PROC_SHIFT;
+	/* and write it back */
+	descr->dmac_cmd_status = cmd_status;
+	/*
+	 * dma_cmd_status field is used to indicate whether the descriptor
+	 * is valid or not.
+	 * Usually caller of this function wants to inform that to the
+	 * hardware, so we assure here the hardware sees the change.
+	 */
+	wmb();
+}
+
+/**
+ * gelic_net_free_chain - free descriptor chain
+ * @card: card structure
+ * @descr_in: address of desc
+ */
+static void gelic_net_free_chain(struct gelic_net_card *card,
+				 struct gelic_net_descr *descr_in)
+{
+	struct gelic_net_descr *descr;
+
+	for (descr = descr_in; descr && descr->bus_addr; descr = descr->next) {
+		dma_unmap_single(ctodev(card), descr->bus_addr,
+				 GELIC_NET_DESCR_SIZE, DMA_BIDIRECTIONAL);
+		descr->bus_addr = 0;
+	}
+}
+
+/**
+ * gelic_net_init_chain - links descriptor chain
+ * @card: card structure
+ * @chain: address of chain
+ * @start_descr: address of descriptor array
+ * @no: number of descriptors
+ *
+ * we manage a circular list that mirrors the hardware structure,
+ * except that the hardware uses bus addresses.
+ *
+ * returns 0 on success, <0 on failure
+ */
+static int gelic_net_init_chain(struct gelic_net_card *card,
+				struct gelic_net_descr_chain *chain,
+				struct gelic_net_descr *start_descr, int no)
+{
+	int i;
+	struct gelic_net_descr *descr;
+
+	descr = start_descr;
+	memset(descr, 0, sizeof(*descr) * no);
+
+	/* set up the hardware pointers in each descriptor */
+	for (i = 0; i < no; i++, descr++) {
+		gelic_net_set_descr_status(descr, GELIC_NET_DESCR_NOT_IN_USE);
+		descr->bus_addr =
+			dma_map_single(ctodev(card), descr,
+				       GELIC_NET_DESCR_SIZE,
+				       DMA_BIDIRECTIONAL);
+
+		if (!descr->bus_addr)
+			goto iommu_error;
+
+		descr->next = descr + 1;
+		descr->prev = descr - 1;
+	}
+	/* make them as ring */
+	(descr - 1)->next = start_descr;
+	start_descr->prev = (descr - 1);
+
+	/* chain bus addr of hw descriptor */
+	descr = start_descr;
+	for (i = 0; i < no; i++, descr++) {
+		descr->next_descr_addr = descr->next->bus_addr;
+	}
+
+	chain->head = start_descr;
+	chain->tail = start_descr;
+
+	/* do not chain last hw descriptor */
+	(descr - 1)->next_descr_addr = 0;
+
+	return 0;
+
+iommu_error:
+	for (i--, descr--; 0 <= i; i--, descr--)
+		if (descr->bus_addr)
+			dma_unmap_single(ctodev(card), descr->bus_addr,
+					 GELIC_NET_DESCR_SIZE,
+					 DMA_BIDIRECTIONAL);
+	return -ENOMEM;
+}
+
+/**
+ * gelic_net_prepare_rx_descr - reinitializes a rx descriptor
+ * @card: card structure
+ * @descr: descriptor to re-init
+ *
+ * return 0 on succes, <0 on failure
+ *
+ * allocates a new rx skb, iommu-maps it and attaches it to the descriptor.
+ * Activate the descriptor state-wise
+ */
+static int gelic_net_prepare_rx_descr(struct gelic_net_card *card,
+				      struct gelic_net_descr *descr)
+{
+	int offset;
+	unsigned int bufsize;
+
+	if (gelic_net_get_descr_status(descr) !=  GELIC_NET_DESCR_NOT_IN_USE) {
+		dev_info(ctodev(card), "%s: ERROR status \n", __func__);
+	}
+	/* we need to round up the buffer size to a multiple of 128 */
+	bufsize = ALIGN(GELIC_NET_MAX_MTU, GELIC_NET_RXBUF_ALIGN);
+
+	/* and we need to have it 128 byte aligned, therefore we allocate a
+	 * bit more */
+	descr->skb = netdev_alloc_skb(card->netdev,
+		bufsize + GELIC_NET_RXBUF_ALIGN - 1);
+	if (!descr->skb) {
+		descr->buf_addr = 0; /* tell DMAC don't touch memory */
+		dev_info(ctodev(card),
+			 "%s:allocate skb failed !!\n", __func__);
+		return -ENOMEM;
+	}
+	descr->buf_size = bufsize;
+	descr->dmac_cmd_status = 0;
+	descr->result_size = 0;
+	descr->valid_size = 0;
+	descr->data_error = 0;
+
+	offset = ((unsigned long)descr->skb->data) &
+		(GELIC_NET_RXBUF_ALIGN - 1);
+	if (offset)
+		skb_reserve(descr->skb, GELIC_NET_RXBUF_ALIGN - offset);
+	/* io-mmu-map the skb */
+	descr->buf_addr = dma_map_single(ctodev(card), descr->skb->data,
+					 GELIC_NET_MAX_MTU,
+					 DMA_FROM_DEVICE);
+	if (!descr->buf_addr) {
+		dev_kfree_skb_any(descr->skb);
+		descr->skb = NULL;
+		dev_info(ctodev(card),
+			 "%s:Could not iommu-map rx buffer\n", __func__);
+		gelic_net_set_descr_status(descr, GELIC_NET_DESCR_NOT_IN_USE);
+		return -ENOMEM;
+	} else {
+		gelic_net_set_descr_status(descr, GELIC_NET_DESCR_CARDOWNED);
+		return 0;
+	}
+}
+
+/**
+ * gelic_net_release_rx_chain - free all skb of rx descr
+ * @card: card structure
+ *
+ */
+static void gelic_net_release_rx_chain(struct gelic_net_card *card)
+{
+	struct gelic_net_descr *descr = card->rx_chain.head;
+
+	do {
+		if (descr->skb) {
+			dma_unmap_single(ctodev(card),
+					 descr->buf_addr,
+					 descr->skb->len,
+					 DMA_FROM_DEVICE);
+			descr->buf_addr = 0;
+			dev_kfree_skb_any(descr->skb);
+			descr->skb = NULL;
+			descr->dmac_cmd_status = GELIC_NET_DESCR_NOT_IN_USE;
+		}
+		descr = descr->next;
+	} while (descr != card->rx_chain.head);
+}
+
+/**
+ * gelic_net_fill_rx_chain - fills descriptors/skbs in the rx chains
+ * @card: card structure
+ *
+ * fills all descriptors in the rx chain: allocates skbs
+ * and iommu-maps them.
+ * returns 0 on success, <0 on failure
+ */
+static int gelic_net_fill_rx_chain(struct gelic_net_card *card)
+{
+	struct gelic_net_descr *descr = card->rx_chain.head;
+	int ret;
+
+	do {
+		if (!descr->skb) {
+			ret = gelic_net_prepare_rx_descr(card, descr);
+			if (ret)
+				goto rewind;
+		}
+		descr = descr->next;
+	} while (descr != card->rx_chain.head);
+
+	return 0;
+rewind:
+	gelic_net_release_rx_chain(card);
+	return ret;
+}
+
+/**
+ * gelic_net_alloc_rx_skbs - allocates rx skbs in rx descriptor chains
+ * @card: card structure
+ *
+ * returns 0 on success, <0 on failure
+ */
+static int gelic_net_alloc_rx_skbs(struct gelic_net_card *card)
+{
+	struct gelic_net_descr_chain *chain;
+	int ret;
+	chain = &card->rx_chain;
+	ret = gelic_net_fill_rx_chain(card);
+	chain->head = card->rx_top->prev; /* point to the last */
+	return ret;
+}
+
+/**
+ * gelic_net_release_tx_descr - processes a used tx descriptor
+ * @card: card structure
+ * @descr: descriptor to release
+ *
+ * releases a used tx descriptor (unmapping, freeing of skb)
+ */
+static void gelic_net_release_tx_descr(struct gelic_net_card *card,
+			    struct gelic_net_descr *descr)
+{
+	struct sk_buff *skb;
+
+
+	if (descr->data_status & (1 << GELIC_NET_TXDESC_TAIL)) {
+		/* 2nd descriptor */
+		skb = descr->skb;
+		dma_unmap_single(ctodev(card), descr->buf_addr, skb->len,
+				 DMA_TO_DEVICE);
+		dev_kfree_skb_any(skb);
+	} else {
+		dma_unmap_single(ctodev(card), descr->buf_addr,
+				 descr->buf_size, DMA_TO_DEVICE);
+	}
+
+	descr->buf_addr = 0;
+	descr->buf_size = 0;
+	descr->next_descr_addr = 0;
+	descr->result_size = 0;
+	descr->valid_size = 0;
+	descr->data_status = 0;
+	descr->data_error = 0;
+	descr->skb = NULL;
+
+	/* set descr status */
+	descr->dmac_cmd_status = GELIC_NET_DMAC_CMDSTAT_NOT_IN_USE;
+}
+
+/**
+ * gelic_net_release_tx_chain - processes sent tx descriptors
+ * @card: adapter structure
+ * @stop: net_stop sequence
+ *
+ * releases the tx descriptors that gelic has finished with
+ */
+static void gelic_net_release_tx_chain(struct gelic_net_card *card, int stop)
+{
+	struct gelic_net_descr_chain *tx_chain;
+	enum gelic_net_descr_status status;
+	int release = 0;
+
+	for (tx_chain = &card->tx_chain;
+	     tx_chain->head != tx_chain->tail && tx_chain->tail;
+	     tx_chain->tail = tx_chain->tail->next) {
+		status = gelic_net_get_descr_status(tx_chain->tail);
+		switch (status) {
+		case GELIC_NET_DESCR_RESPONSE_ERROR:
+		case GELIC_NET_DESCR_PROTECTION_ERROR:
+		case GELIC_NET_DESCR_FORCE_END:
+			if (printk_ratelimit())
+				dev_info(ctodev(card),
+					 "%s: forcing end of tx descriptor " \
+					 "with status %x\n",
+					 __func__, status);
+			card->netdev_stats.tx_dropped++;
+			break;
+
+		case GELIC_NET_DESCR_COMPLETE:
+			card->netdev_stats.tx_packets++;
+			card->netdev_stats.tx_bytes +=
+				tx_chain->tail->skb->len;
+			break;
+
+		case GELIC_NET_DESCR_CARDOWNED:
+			/* pending tx request */
+		default:
+			/* any other value (== GELIC_NET_DESCR_NOT_IN_USE) */
+			goto out;
+		}
+		gelic_net_release_tx_descr(card, tx_chain->tail);
+		release = 1;
+	}
+out:
+	if (!stop && release)
+		netif_wake_queue(card->netdev);
+}
+
+/**
+ * gelic_net_set_multi - sets multicast addresses and promisc flags
+ * @netdev: interface device structure
+ *
+ * gelic_net_set_multi configures multicast addresses as needed for the
+ * netdev interface. It also sets up multicast, allmulti and promisc
+ * flags appropriately
+ */
+static void gelic_net_set_multi(struct net_device *netdev)
+{
+	struct gelic_net_card *card = netdev_priv(netdev);
+	struct dev_mc_list *mc;
+	unsigned int i;
+	uint8_t *p;
+	u64 addr;
+	int status;
+
+	/* clear all multicast address */
+	status = lv1_net_remove_multicast_address(bus_id(card), dev_id(card),
+						  0, 1);
+	if (status)
+		dev_err(ctodev(card),
+			"lv1_net_remove_multicast_address failed %d\n",
+			status);
+	/* set broadcast address */
+	status = lv1_net_add_multicast_address(bus_id(card), dev_id(card),
+					       GELIC_NET_BROADCAST_ADDR, 0);
+	if (status)
+		dev_err(ctodev(card),
+			"lv1_net_add_multicast_address failed, %d\n",
+			status);
+
+	if (netdev->flags & IFF_ALLMULTI
+		|| netdev->mc_count > GELIC_NET_MC_COUNT_MAX) { /* list max */
+		status = lv1_net_add_multicast_address(bus_id(card),
+						       dev_id(card),
+						       0, 1);
+		if (status)
+			dev_err(ctodev(card),
+				"lv1_net_add_multicast_address failed, %d\n",
+				status);
+		return;
+	}
+
+	/* set multicast address */
+	for (mc = netdev->mc_list; mc; mc = mc->next) {
+		addr = 0;
+		p = mc->dmi_addr;
+		for (i = 0; i < ETH_ALEN; i++) {
+			addr <<= 8;
+			addr |= *p++;
+		}
+		status = lv1_net_add_multicast_address(bus_id(card),
+						       dev_id(card),
+						       addr, 0);
+		if (status)
+			dev_err(ctodev(card),
+				"lv1_net_add_multicast_address failed, %d\n",
+				status);
+	}
+}
+
+/**
+ * gelic_net_enable_rxdmac - enables the receive DMA controller
+ * @card: card structure
+ *
+ * gelic_net_enable_rxdmac enables the DMA controller by setting RX_DMA_EN
+ * in the GDADMACCNTR register
+ */
+static inline void gelic_net_enable_rxdmac(struct gelic_net_card *card)
+{
+	int status;
+
+	status = lv1_net_start_rx_dma(bus_id(card), dev_id(card),
+				card->rx_chain.tail->bus_addr, 0);
+	if (status)
+		dev_info(ctodev(card),
+			 "lv1_net_start_rx_dma failed, status=%d\n", status);
+}
+
+/**
+ * gelic_net_disable_rxdmac - disables the receive DMA controller
+ * @card: card structure
+ *
+ * gelic_net_disable_rxdmac terminates processing on the DMA controller by
+ * turing off DMA and issueing a force end
+ */
+static inline void gelic_net_disable_rxdmac(struct gelic_net_card *card)
+{
+	int status;
+
+	/* this hvc blocks until the DMA in progress really stopped */
+	status = lv1_net_stop_rx_dma(bus_id(card), dev_id(card), 0);
+	if (status)
+		dev_err(ctodev(card),
+			"lv1_net_stop_rx_dma faild, %d\n", status);
+}
+
+/**
+ * gelic_net_disable_txdmac - disables the transmit DMA controller
+ * @card: card structure
+ *
+ * gelic_net_disable_txdmac terminates processing on the DMA controller by
+ * turing off DMA and issueing a force end
+ */
+static inline void gelic_net_disable_txdmac(struct gelic_net_card *card)
+{
+	int status;
+
+	/* this hvc blocks until the DMA in progress really stopped */
+	status = lv1_net_stop_tx_dma(bus_id(card), dev_id(card), 0);
+	if (status)
+		dev_err(ctodev(card),
+			"lv1_net_stop_tx_dma faild, status=%d\n", status);
+}
+
+/**
+ * gelic_net_stop - called upon ifconfig down
+ * @netdev: interface device structure
+ *
+ * always returns 0
+ */
+static int gelic_net_stop(struct net_device *netdev)
+{
+	struct gelic_net_card *card = netdev_priv(netdev);
+
+	netif_poll_disable(netdev);
+	netif_stop_queue(netdev);
+
+	/* turn off DMA, force end */
+	gelic_net_disable_rxdmac(card);
+	gelic_net_disable_txdmac(card);
+
+	gelic_net_set_irq_mask(card, 0);
+
+	/* disconnect event port */
+	free_irq(card->netdev->irq, card->netdev);
+	ps3_sb_event_receive_port_destroy(card->dev, card->netdev->irq);
+	card->netdev->irq = NO_IRQ;
+
+	netif_carrier_off(netdev);
+
+	/* release chains */
+	gelic_net_release_tx_chain(card, 1);
+	gelic_net_release_rx_chain(card);
+
+	gelic_net_free_chain(card, card->tx_top);
+	gelic_net_free_chain(card, card->rx_top);
+
+	return 0;
+}
+
+/**
+ * gelic_net_get_next_tx_descr - returns the next available tx descriptor
+ * @card: device structure to get descriptor from
+ *
+ * returns the address of the next descriptor, or NULL if not available.
+ */
+static struct gelic_net_descr *
+gelic_net_get_next_tx_descr(struct gelic_net_card *card)
+{
+	if (!card->tx_chain.head)
+		return NULL;
+	/*  see if we can two consecutive free descrs */
+	if (card->tx_chain.tail != card->tx_chain.head->next &&
+	    gelic_net_get_descr_status(card->tx_chain.head) ==
+	    GELIC_NET_DESCR_NOT_IN_USE &&
+	    card->tx_chain.tail != card->tx_chain.head->next->next &&
+	    gelic_net_get_descr_status(card->tx_chain.head->next) ==
+	     GELIC_NET_DESCR_NOT_IN_USE )
+		return card->tx_chain.head;
+	else
+		return NULL;
+
+}
+
+/**
+ * gelic_net_set_txdescr_cmdstat - sets the tx descriptor command field
+ * @descr: descriptor structure to fill out
+ * @skb: packet to consider
+ * @middle: middle of frame
+ *
+ * fills out the command and status field of the descriptor structure,
+ * depending on hardware checksum settings. This function assumes a wmb()
+ * has executed before.
+ */
+static void gelic_net_set_txdescr_cmdstat(struct gelic_net_descr *descr,
+					  struct sk_buff *skb, int middle)
+{
+	u32 eofr;
+
+	if (middle)
+		eofr = 0;
+	else
+		eofr = GELIC_NET_DMAC_CMDSTAT_END_FRAME;
+
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		descr->dmac_cmd_status = GELIC_NET_DMAC_CMDSTAT_NOCS | eofr;
+	else {
+		/* is packet ip?
+		 * if yes: tcp? udp? */
+		if (skb->protocol == htons(ETH_P_IP)) {
+			if (ip_hdr(skb)->protocol == IPPROTO_TCP)
+				descr->dmac_cmd_status =
+					GELIC_NET_DMAC_CMDSTAT_TCPCS | eofr;
+			else if (ip_hdr(skb)->protocol == IPPROTO_UDP)
+				descr->dmac_cmd_status =
+					GELIC_NET_DMAC_CMDSTAT_UDPCS | eofr;
+			else	/*
+				 * the stack should checksum non-tcp and non-udp
+				 * packets on his own: NETIF_F_IP_CSUM
+				 */
+				descr->dmac_cmd_status =
+					GELIC_NET_DMAC_CMDSTAT_NOCS | eofr;
+		}
+	}
+}
+
+/**
+ * gelic_net_prepare_tx_descr_v - get dma address of skb_data
+ * @card: card structure
+ * @descr: descriptor structure
+ * @skb: packet to use
+ *
+ * returns 0 on success, <0 on failure.
+ *
+ */
+static int gelic_net_prepare_tx_descr_v(struct gelic_net_card *card,
+					struct gelic_net_descr *descr,
+					struct sk_buff *skb)
+{
+	dma_addr_t buf[2];
+	unsigned int vlan_len;
+
+	if (skb->len < GELIC_NET_VLAN_POS)
+		return -EINVAL;
+
+	memcpy(&descr->vlan, skb->data, GELIC_NET_VLAN_POS);
+	if (card->vlan_index != -1) {
+		descr->vlan.h_vlan_proto = htons(ETH_P_8021Q); /* vlan 0x8100*/
+		descr->vlan.h_vlan_TCI = htons(card->vlan_id[card->vlan_index]);
+		vlan_len = GELIC_NET_VLAN_POS + VLAN_HLEN; /* VLAN_HLEN=4 */
+	} else
+		vlan_len = GELIC_NET_VLAN_POS; /* no vlan tag */
+
+	/* first descr */
+	buf[0] = dma_map_single(ctodev(card), &descr->vlan,
+			     vlan_len, DMA_TO_DEVICE);
+
+	if (!buf[0]) {
+		dev_err(ctodev(card),
+			"dma map 1 failed (%p, %i). Dropping packet\n",
+			skb->data, vlan_len);
+		return -ENOMEM;
+	}
+
+	descr->buf_addr = buf[0];
+	descr->buf_size = vlan_len;
+	descr->skb = skb; /* not used */
+	descr->data_status = 0;
+	gelic_net_set_txdescr_cmdstat(descr, skb, 1); /* not the frame end */
+
+	/* second descr */
+	card->tx_chain.head = card->tx_chain.head->next;
+	descr->next_descr_addr = descr->next->bus_addr;
+	descr = descr->next;
+	if (gelic_net_get_descr_status(descr) != GELIC_NET_DESCR_NOT_IN_USE)
+		/* XXX will be removed */
+		dev_err(ctodev(card), "descr is not free!\n");
+
+	buf[1] = dma_map_single(ctodev(card), skb->data + GELIC_NET_VLAN_POS,
+			     skb->len - GELIC_NET_VLAN_POS,
+			     DMA_TO_DEVICE);
+
+	if (!buf[1]) {
+		dev_err(ctodev(card),
+			"dma map 2 failed (%p, %i). Dropping packet\n",
+			skb->data + GELIC_NET_VLAN_POS,
+			skb->len - GELIC_NET_VLAN_POS);
+		dma_unmap_single(ctodev(card), buf[0], vlan_len,
+				 DMA_TO_DEVICE);
+		return -ENOMEM;
+	}
+
+	descr->buf_addr = buf[1];
+	descr->buf_size = skb->len - GELIC_NET_VLAN_POS;
+	descr->skb = skb;
+	descr->data_status = 0;
+	descr->next_descr_addr = 0; /* terminate hw descr */
+	gelic_net_set_txdescr_cmdstat(descr, skb, 0);
+
+	return 0;
+}
+
+/**
+ * gelic_net_kick_txdma - enables TX DMA processing
+ * @card: card structure
+ * @descr: descriptor address to enable TX processing at
+ *
+ */
+static int gelic_net_kick_txdma(struct gelic_net_card *card,
+				struct gelic_net_descr *descr)
+{
+	int status = -ENXIO;
+	int count = 10;
+
+	if (card->tx_dma_progress)
+		return 0;
+
+	if (gelic_net_get_descr_status(descr) == GELIC_NET_DESCR_CARDOWNED) {
+		card->tx_dma_progress = 1;
+		/* sometimes we need retry here */
+		while (count--) {
+			status = lv1_net_start_tx_dma(bus_id(card),
+						      dev_id(card),
+						      descr->bus_addr, 0);
+			if (!status)
+				break;
+		}
+		if (!count)
+			dev_info(ctodev(card), "lv1_net_start_txdma failed," \
+				"status=%d %#lx\n",
+				 status, card->irq_status);
+	}
+	return status;
+}
+
+/**
+ * gelic_net_xmit - transmits a frame over the device
+ * @skb: packet to send out
+ * @netdev: interface device structure
+ *
+ * returns 0 on success, <0 on failure
+ */
+static int gelic_net_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct gelic_net_card *card = netdev_priv(netdev);
+	struct gelic_net_descr *descr = NULL;
+	int result;
+	unsigned long flags;
+
+	spin_lock_irqsave(&card->tx_dma_lock, flags);
+
+	gelic_net_release_tx_chain(card, 0);
+	if (!skb)
+		goto kick;
+	descr = gelic_net_get_next_tx_descr(card);
+	if (!descr) {
+		netif_stop_queue(netdev);
+		spin_unlock_irqrestore(&card->tx_dma_lock, flags);
+		return NETDEV_TX_BUSY;
+	}
+	result = gelic_net_prepare_tx_descr_v(card, descr, skb);
+
+	if (result)
+		goto error;
+
+	card->tx_chain.head = card->tx_chain.head->next;
+
+	if (descr->prev)
+		descr->prev->next_descr_addr = descr->bus_addr;
+kick:
+	/*
+	 * as hardware descriptor is modified in the above lines,
+	 * ensure that the hardware sees it
+	 */
+	wmb();
+	if (gelic_net_kick_txdma(card, card->tx_chain.tail))
+		goto error;
+
+	netdev->trans_start = jiffies;
+	spin_unlock_irqrestore(&card->tx_dma_lock, flags);
+	return NETDEV_TX_OK;
+
+error:
+	card->netdev_stats.tx_dropped++;
+	spin_unlock_irqrestore(&card->tx_dma_lock, flags);
+	return NETDEV_TX_LOCKED;
+}
+
+/**
+ * gelic_net_pass_skb_up - takes an skb from a descriptor and passes it on
+ * @descr: descriptor to process
+ * @card: card structure
+ *
+ * iommu-unmaps the skb, fills out skb structure and passes the data to the
+ * stack. The descriptor state is not changed.
+ */
+static void gelic_net_pass_skb_up(struct gelic_net_descr *descr,
+				 struct gelic_net_card *card)
+{
+	struct sk_buff *skb;
+	struct net_device *netdev;
+	u32 data_status, data_error;
+
+	data_status = descr->data_status;
+	data_error = descr->data_error;
+	netdev = card->netdev;
+	/* unmap skb buffer */
+	skb = descr->skb;
+	dma_unmap_single(ctodev(card), descr->buf_addr, GELIC_NET_MAX_MTU,
+			 DMA_FROM_DEVICE);
+
+	skb_put(skb, descr->valid_size? descr->valid_size : descr->result_size);
+	if (!descr->valid_size)
+		dev_info(ctodev(card), "buffer full %x %x %x\n",
+			 descr->result_size, descr->buf_size,
+			 descr->dmac_cmd_status);
+
+	descr->skb = NULL;
+	/*
+	 * the card put 2 bytes vlan tag in front
+	 * of the ethernet frame
+	 */
+	skb_pull(skb, 2);
+	skb->protocol = eth_type_trans(skb, netdev);
+
+	/* checksum offload */
+	if (card->rx_csum) {
+		if ((data_status & GELIC_NET_DATA_STATUS_CHK_MASK) &&
+		    (!(data_error & GELIC_NET_DATA_ERROR_CHK_MASK)))
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		else
+			skb->ip_summed = CHECKSUM_NONE;
+	} else
+		skb->ip_summed = CHECKSUM_NONE;
+
+	/* update netdevice statistics */
+	card->netdev_stats.rx_packets++;
+	card->netdev_stats.rx_bytes += skb->len;
+
+	/* pass skb up to stack */
+	netif_receive_skb(skb);
+}
+
+/**
+ * gelic_net_decode_one_descr - processes an rx descriptor
+ * @card: card structure
+ *
+ * returns 1 if a packet has been sent to the stack, otherwise 0
+ *
+ * processes an rx descriptor by iommu-unmapping the data buffer and passing
+ * the packet up to the stack
+ */
+static int gelic_net_decode_one_descr(struct gelic_net_card *card)
+{
+	enum gelic_net_descr_status status;
+	struct gelic_net_descr_chain *chain = &card->rx_chain;
+	struct gelic_net_descr *descr = chain->tail;
+	int dmac_chain_ended;
+
+	status = gelic_net_get_descr_status(descr);
+	/* is this descriptor terminated with next_descr == NULL? */
+	dmac_chain_ended =
+		descr->dmac_cmd_status & GELIC_NET_DMAC_CMDSTAT_RXDCEIS;
+
+	if (status == GELIC_NET_DESCR_CARDOWNED)
+		return 0;
+
+	if (status == GELIC_NET_DESCR_NOT_IN_USE) {
+		dev_dbg(ctodev(card), "dormant descr? %p\n", descr);
+		return 0;
+	}
+
+	if ((status == GELIC_NET_DESCR_RESPONSE_ERROR) ||
+	    (status == GELIC_NET_DESCR_PROTECTION_ERROR) ||
+	    (status == GELIC_NET_DESCR_FORCE_END)) {
+		dev_info(ctodev(card), "dropping RX descriptor with state %x\n",
+			 status);
+		card->netdev_stats.rx_dropped++;
+		goto refill;
+	}
+
+	if ((status != GELIC_NET_DESCR_COMPLETE) &&
+	    (status != GELIC_NET_DESCR_FRAME_END)) {
+		dev_dbg(ctodev(card), "RX descriptor with state %x\n",
+			status);
+		goto refill;
+	}
+
+	/* ok, we've got a packet in descr */
+	gelic_net_pass_skb_up(descr, card); /* 1: skb_up sccess */
+
+refill:
+	descr->next_descr_addr = 0; /* unlink the descr */
+
+	/* change the descriptor state: */
+	gelic_net_set_descr_status(descr, GELIC_NET_DESCR_NOT_IN_USE);
+
+	/* refill one desc
+	 * FIXME: this can fail, but for now, just leave this
+	 * descriptor without skb
+	 */
+	gelic_net_prepare_rx_descr(card, descr);
+	chain->head = descr;
+	chain->tail = descr->next;
+	descr->prev->next_descr_addr = descr->bus_addr;
+
+	if (dmac_chain_ended) {
+		gelic_net_enable_rxdmac(card);
+		dev_dbg(ctodev(card), "reenable rx dma\n");
+	}
+
+	return 1;
+}
+
+/**
+ * gelic_net_poll - NAPI poll function called by the stack to return packets
+ * @netdev: interface device structure
+ * @budget: number of packets we can pass to the stack at most
+ *
+ * returns 0 if no more packets available to the driver/stack. Returns 1,
+ * if the quota is exceeded, but the driver has still packets.
+ *
+ */
+static int gelic_net_poll(struct net_device *netdev, int *budget)
+{
+	struct gelic_net_card *card = netdev_priv(netdev);
+	int packets_to_do, packets_done = 0;
+	int no_more_packets = 0;
+
+	packets_to_do = min(*budget, netdev->quota);
+
+	while (packets_to_do) {
+		if (gelic_net_decode_one_descr(card)) {
+			packets_done++;
+			packets_to_do--;
+		} else {
+			/* no more packets for the stack */
+			no_more_packets = 1;
+			break;
+		}
+	}
+	netdev->quota -= packets_done;
+	*budget -= packets_done;
+	if (no_more_packets) {
+		netif_rx_complete(netdev);
+		gelic_net_rx_irq_on(card);
+		return 0;
+	} else
+		return 1;
+}
+
+/**
+ * gelic_net_get_stats - get interface statistics
+ * @netdev: interface device structure
+ *
+ * returns the interface statistics residing in the gelic_net_card struct
+ */
+static struct net_device_stats *gelic_net_get_stats(struct net_device *netdev)
+{
+	struct gelic_net_card *card = netdev_priv(netdev);
+
+	return &card->netdev_stats;
+}
+
+/**
+ * gelic_net_change_mtu - changes the MTU of an interface
+ * @netdev: interface device structure
+ * @new_mtu: new MTU value
+ *
+ * returns 0 on success, <0 on failure
+ */
+static int gelic_net_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	/* no need to re-alloc skbs or so -- the max mtu is about 2.3k
+	 * and mtu is outbound only anyway */
+	if ((new_mtu < GELIC_NET_MIN_MTU) ||
+	    (new_mtu > GELIC_NET_MAX_MTU)) {
+		return -EINVAL;
+	}
+	netdev->mtu = new_mtu;
+	return 0;
+}
+
+/**
+ * gelic_net_interrupt - event handler for gelic_net
+ */
+static irqreturn_t gelic_net_interrupt(int irq, void *ptr)
+{
+	unsigned long flags;
+	struct net_device *netdev = ptr;
+	struct gelic_net_card *card = netdev_priv(netdev);
+	u64 status;
+
+	status = card->irq_status;
+
+	if (!status)
+		return IRQ_NONE;
+
+	if (status & GELIC_NET_RXINT) {
+		gelic_net_rx_irq_off(card);
+		netif_rx_schedule(netdev);
+	}
+
+	if (status & GELIC_NET_TXINT) {
+		spin_lock_irqsave(&card->tx_dma_lock, flags);
+		card->tx_dma_progress = 0;
+		spin_unlock_irqrestore(&card->tx_dma_lock, flags);
+		/* start pending DMA */
+		gelic_net_xmit(NULL, netdev);
+	}
+	return IRQ_HANDLED;
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/**
+ * gelic_net_poll_controller - artificial interrupt for netconsole etc.
+ * @netdev: interface device structure
+ *
+ * see Documentation/networking/netconsole.txt
+ */
+static void gelic_net_poll_controller(struct net_device *netdev)
+{
+	struct gelic_net_card *card = netdev_priv(netdev);
+
+	gelic_net_set_irq_mask(card, 0);
+	gelic_net_interrupt(netdev->irq, netdev);
+	gelic_net_set_irq_mask(card, card->ghiintmask);
+}
+#endif /* CONFIG_NET_POLL_CONTROLLER */
+
+/**
+ * gelic_net_open_device - open device and map dma region
+ * @card: card structure
+ */
+static int gelic_net_open_device(struct gelic_net_card *card)
+{
+	int result;
+
+	result = ps3_sb_event_receive_port_setup(card->dev, PS3_BINDING_CPU_ANY,
+		&card->netdev->irq);
+
+	if (result) {
+		dev_info(ctodev(card),
+			 "%s:%d: gelic_net_open_device failed (%d)\n",
+			 __func__, __LINE__, result);
+		result = -EPERM;
+		goto fail_alloc_irq;
+	}
+
+	result = request_irq(card->netdev->irq, gelic_net_interrupt,
+			     IRQF_DISABLED, "gelic network", card->netdev);
+
+	if (result) {
+		dev_info(ctodev(card), "%s:%d: request_irq failed (%d)\n",
+			__func__, __LINE__, result);
+		goto fail_request_irq;
+	}
+
+	return 0;
+
+fail_request_irq:
+	ps3_sb_event_receive_port_destroy(card->dev, card->netdev->irq);
+	card->netdev->irq = NO_IRQ;
+fail_alloc_irq:
+	return result;
+}
+
+
+/**
+ * gelic_net_open - called upon ifonfig up
+ * @netdev: interface device structure
+ *
+ * returns 0 on success, <0 on failure
+ *
+ * gelic_net_open allocates all the descriptors and memory needed for
+ * operation, sets up multicast list and enables interrupts
+ */
+static int gelic_net_open(struct net_device *netdev)
+{
+	struct gelic_net_card *card = netdev_priv(netdev);
+
+	dev_dbg(ctodev(card), " -> %s:%d\n", __func__, __LINE__);
+
+	gelic_net_open_device(card);
+
+	if (gelic_net_init_chain(card, &card->tx_chain,
+			card->descr, GELIC_NET_TX_DESCRIPTORS))
+		goto alloc_tx_failed;
+	if (gelic_net_init_chain(card, &card->rx_chain,
+				 card->descr + GELIC_NET_RX_DESCRIPTORS,
+				 GELIC_NET_RX_DESCRIPTORS))
+		goto alloc_rx_failed;
+
+	/* head of chain */
+	card->tx_top = card->tx_chain.head;
+	card->rx_top = card->rx_chain.head;
+	dev_dbg(ctodev(card), "descr rx %p, tx %p, size %#lx, num %#x\n",
+		card->rx_top, card->tx_top, sizeof(struct gelic_net_descr),
+		GELIC_NET_RX_DESCRIPTORS);
+	/* allocate rx skbs */
+	if (gelic_net_alloc_rx_skbs(card))
+		goto alloc_skbs_failed;
+
+	card->tx_dma_progress = 0;
+	card->ghiintmask = GELIC_NET_RXINT | GELIC_NET_TXINT;
+
+	gelic_net_set_irq_mask(card, card->ghiintmask);
+	gelic_net_enable_rxdmac(card);
+
+	netif_start_queue(netdev);
+	netif_carrier_on(netdev);
+	netif_poll_enable(netdev);
+
+	return 0;
+
+alloc_skbs_failed:
+	gelic_net_free_chain(card, card->rx_top);
+alloc_rx_failed:
+	gelic_net_free_chain(card, card->tx_top);
+alloc_tx_failed:
+	return -ENOMEM;
+}
+
+#ifdef GELIC_NET_ETHTOOL
+static void gelic_net_get_drvinfo (struct net_device *netdev,
+				   struct ethtool_drvinfo *info)
+{
+	strncpy(info->driver, DRV_NAME, sizeof(info->driver) - 1);
+	strncpy(info->version, DRV_VERSION, sizeof(info->version) - 1);
+}
+
+static int gelic_net_get_settings(struct net_device *netdev,
+				  struct ethtool_cmd *cmd)
+{
+	struct gelic_net_card *card = netdev_priv(netdev);
+	int status;
+	u64 v1, v2;
+	int speed, duplex;
+
+	speed = duplex = -1;
+	status = lv1_net_control(bus_id(card), dev_id(card),
+			GELIC_NET_GET_ETH_PORT_STATUS, GELIC_NET_PORT, 0, 0,
+			&v1, &v2);
+	if (status) {
+		/* link down */
+	} else {
+		if (v1 & GELIC_NET_FULL_DUPLEX) {
+			duplex = DUPLEX_FULL;
+		} else {
+			duplex = DUPLEX_HALF;
+		}
+
+		if (v1 & GELIC_NET_SPEED_10 ) {
+			speed = SPEED_10;
+		} else if (v1 & GELIC_NET_SPEED_100) {
+			speed = SPEED_100;
+		} else if (v1 & GELIC_NET_SPEED_1000) {
+			speed = SPEED_1000;
+		}
+	}
+	cmd->supported = SUPPORTED_TP | SUPPORTED_Autoneg |
+			SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
+			SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
+			SUPPORTED_1000baseT_Half | SUPPORTED_1000baseT_Full;
+	cmd->advertising = cmd->supported;
+	cmd->speed = speed;
+	cmd->duplex = duplex;
+	cmd->autoneg = AUTONEG_ENABLE; /* always enabled */
+	cmd->port = PORT_TP;
+
+	return 0;
+}
+
+static u32 gelic_net_get_link(struct net_device *netdev)
+{
+	struct gelic_net_card *card = netdev_priv(netdev);
+	int status;
+	u64 v1, v2;
+	int link;
+
+	status = lv1_net_control(bus_id(card), dev_id(card),
+			GELIC_NET_GET_ETH_PORT_STATUS, GELIC_NET_PORT, 0, 0,
+			&v1, &v2);
+	if (status)
+		return 0; /* link down */
+
+	if (v1 & GELIC_NET_LINK_UP)
+		link = 1;
+	else
+		link = 0;
+
+	return link;
+}
+
+static int gelic_net_nway_reset(struct net_device *netdev)
+{
+	if (netif_running(netdev)) {
+		gelic_net_stop(netdev);
+		gelic_net_open(netdev);
+	}
+	return 0;
+}
+
+static u32 gelic_net_get_tx_csum(struct net_device *netdev)
+{
+	return (netdev->features & NETIF_F_IP_CSUM) != 0;
+}
+
+static int gelic_net_set_tx_csum(struct net_device *netdev, u32 data)
+{
+	if (data)
+		netdev->features |= NETIF_F_IP_CSUM;
+	else
+		netdev->features &= ~NETIF_F_IP_CSUM;
+
+	return 0;
+}
+
+static u32 gelic_net_get_rx_csum(struct net_device *netdev)
+{
+	struct gelic_net_card *card = netdev_priv(netdev);
+
+	return card->rx_csum;
+}
+
+static int gelic_net_set_rx_csum(struct net_device *netdev, u32 data)
+{
+	struct gelic_net_card *card = netdev_priv(netdev);
+
+	card->rx_csum = data;
+	return 0;
+}
+
+static struct ethtool_ops gelic_net_ethtool_ops = {
+	.get_drvinfo	= gelic_net_get_drvinfo,
+	.get_settings	= gelic_net_get_settings,
+	.get_link	= gelic_net_get_link,
+	.nway_reset	= gelic_net_nway_reset,
+	.get_tx_csum	= gelic_net_get_tx_csum,
+	.set_tx_csum	= gelic_net_set_tx_csum,
+	.get_rx_csum	= gelic_net_get_rx_csum,
+	.set_rx_csum	= gelic_net_set_rx_csum,
+};
+#endif
+
+/**
+ * gelic_net_tx_timeout_task - task scheduled by the watchdog timeout
+ * function (to be called not under interrupt status)
+ * @work: work is context of tx timout task
+ *
+ * called as task when tx hangs, resets interface (if interface is up)
+ */
+static void gelic_net_tx_timeout_task(struct work_struct *work)
+{
+	struct gelic_net_card *card =
+		container_of(work, struct gelic_net_card, tx_timeout_task);
+	struct net_device *netdev = card->netdev;
+
+	dev_info(ctodev(card), "%s:Timed out. Restarting... \n", __func__);
+
+	if (!(netdev->flags & IFF_UP))
+		goto out;
+
+	netif_device_detach(netdev);
+	gelic_net_stop(netdev);
+
+	gelic_net_open(netdev);
+	netif_device_attach(netdev);
+
+out:
+	atomic_dec(&card->tx_timeout_task_counter);
+}
+
+/**
+ * gelic_net_tx_timeout - called when the tx timeout watchdog kicks in.
+ * @netdev: interface device structure
+ *
+ * called, if tx hangs. Schedules a task that resets the interface
+ */
+static void gelic_net_tx_timeout(struct net_device *netdev)
+{
+	struct gelic_net_card *card;
+
+	card = netdev_priv(netdev);
+	atomic_inc(&card->tx_timeout_task_counter);
+	if (netdev->flags & IFF_UP)
+		schedule_work(&card->tx_timeout_task);
+	else
+		atomic_dec(&card->tx_timeout_task_counter);
+}
+
+/**
+ * gelic_net_setup_netdev_ops - initialization of net_device operations
+ * @netdev: net_device structure
+ *
+ * fills out function pointers in the net_device structure
+ */
+static void gelic_net_setup_netdev_ops(struct net_device *netdev)
+{
+	netdev->open = &gelic_net_open;
+	netdev->stop = &gelic_net_stop;
+	netdev->hard_start_xmit = &gelic_net_xmit;
+	netdev->get_stats = &gelic_net_get_stats;
+	netdev->set_multicast_list = &gelic_net_set_multi;
+	netdev->change_mtu = &gelic_net_change_mtu;
+	/* tx watchdog */
+	netdev->tx_timeout = &gelic_net_tx_timeout;
+	netdev->watchdog_timeo = GELIC_NET_WATCHDOG_TIMEOUT;
+	/* NAPI */
+	netdev->poll = &gelic_net_poll;
+	netdev->weight = GELIC_NET_NAPI_WEIGHT;
+#ifdef GELIC_NET_ETHTOOL
+	netdev->ethtool_ops = &gelic_net_ethtool_ops;
+#endif
+}
+
+/**
+ * gelic_net_setup_netdev - initialization of net_device
+ * @card: card structure
+ *
+ * Returns 0 on success or <0 on failure
+ *
+ * gelic_net_setup_netdev initializes the net_device structure
+ **/
+static int gelic_net_setup_netdev(struct gelic_net_card *card)
+{
+	struct net_device *netdev = card->netdev;
+	struct sockaddr addr;
+	unsigned int i;
+	int status;
+	u64 v1, v2;
+
+	SET_MODULE_OWNER(netdev);
+	SET_NETDEV_DEV(netdev, &card->dev->core);
+	spin_lock_init(&card->tx_dma_lock);
+
+	card->rx_csum = GELIC_NET_RX_CSUM_DEFAULT;
+
+	gelic_net_setup_netdev_ops(netdev);
+
+	netdev->features = NETIF_F_IP_CSUM;
+
+	status = lv1_net_control(bus_id(card), dev_id(card),
+				 GELIC_NET_GET_MAC_ADDRESS,
+				 0, 0, 0, &v1, &v2);
+	if (status || !is_valid_ether_addr((u8 *)&v1)) {
+		dev_info(ctodev(card),
+			 "%s:lv1_net_control GET_MAC_ADDR failed %d\n",
+			 __func__, status);
+		return -EINVAL;
+	}
+	v1 <<= 16;
+	memcpy(addr.sa_data, &v1, ETH_ALEN);
+	memcpy(netdev->dev_addr, addr.sa_data, ETH_ALEN);
+	dev_info(ctodev(card), "MAC addr %02x:%02x:%02x:%02x:%02x:%02x\n",
+		 netdev->dev_addr[0], netdev->dev_addr[1],
+		 netdev->dev_addr[2], netdev->dev_addr[3],
+		 netdev->dev_addr[4], netdev->dev_addr[5]);
+
+	card->vlan_index = -1;	/* no vlan */
+	for (i = 0; i < GELIC_NET_VLAN_MAX; i++) {
+		status = lv1_net_control(bus_id(card), dev_id(card),
+					GELIC_NET_GET_VLAN_ID,
+					i + 1, /* index; one based */
+					0, 0, &v1, &v2);
+		if (status == GELIC_NET_VLAN_NO_ENTRY) {
+			dev_dbg(ctodev(card),
+				"GELIC_VLAN_ID no entry:%d, VLAN disabled\n",
+				status);
+			card->vlan_id[i] = 0;
+		} else if (status) {
+			dev_dbg(ctodev(card),
+				"%s:GELIC_NET_VLAN_ID faild, status=%d\n",
+				__func__, status);
+			card->vlan_id[i] = 0;
+		} else {
+			card->vlan_id[i] = (u32)v1;
+			dev_dbg(ctodev(card), "vlan_id:%d, %lx\n", i, v1);
+		}
+	}
+	if (card->vlan_id[GELIC_NET_VLAN_WIRED - 1])
+		card->vlan_index = GELIC_NET_VLAN_WIRED - 1;
+
+	status = register_netdev(netdev);
+	if (status) {
+		dev_err(ctodev(card), "%s:Couldn't register net_device: %d\n",
+			__func__, status);
+		return status;
+	}
+
+	return 0;
+}
+
+/**
+ * gelic_net_alloc_card - allocates net_device and card structure
+ *
+ * returns the card structure or NULL in case of errors
+ *
+ * the card and net_device structures are linked to each other
+ */
+static struct gelic_net_card *gelic_net_alloc_card(void)
+{
+	struct net_device *netdev;
+	struct gelic_net_card *card;
+	size_t alloc_size;
+
+	alloc_size = sizeof (*card) +
+		sizeof (struct gelic_net_descr) * GELIC_NET_RX_DESCRIPTORS +
+		sizeof (struct gelic_net_descr) * GELIC_NET_TX_DESCRIPTORS;
+	/*
+	 * we assume private data is allocated 32 bytes (or more) aligned
+	 * so that gelic_net_descr should be 32 bytes aligned.
+	 * Current alloc_etherdev() does do it because NETDEV_ALIGN
+	 * is 32.
+	 * check this assumption here.
+	 */
+	BUILD_BUG_ON(NETDEV_ALIGN < 32);
+	BUILD_BUG_ON(offsetof(struct gelic_net_card, irq_status) % 8);
+	BUILD_BUG_ON(offsetof(struct gelic_net_card, descr) % 32);
+
+	netdev = alloc_etherdev(alloc_size);
+	if (!netdev)
+		return NULL;
+
+	card = netdev_priv(netdev);
+	card->netdev = netdev;
+	INIT_WORK(&card->tx_timeout_task, gelic_net_tx_timeout_task);
+	init_waitqueue_head(&card->waitq);
+	atomic_set(&card->tx_timeout_task_counter, 0);
+
+	return card;
+}
+
+/**
+ * ps3_gelic_driver_probe - add a device to the control of this driver
+ */
+static int ps3_gelic_driver_probe (struct ps3_system_bus_device *dev)
+{
+	struct gelic_net_card *card = gelic_net_alloc_card();
+	int result;
+
+	if (!card) {
+		dev_info(&dev->core, "gelic_net_alloc_card failed\n");
+		result = -ENOMEM;
+		goto fail_alloc_card;
+	}
+
+	ps3_system_bus_set_driver_data(dev, card);
+	card->dev = dev;
+
+	result = ps3_open_hv_device(dev);
+
+	if (result) {
+		dev_dbg(&dev->core, "ps3_open_hv_device failed\n");
+		goto fail_open;
+	}
+
+	result = ps3_dma_region_create(dev->d_region);
+
+	if (result) {
+		dev_dbg(&dev->core, "ps3_dma_region_create failed(%d)\n",
+			result);
+		BUG_ON("check region type");
+		goto fail_dma_region;
+	}
+
+	result = lv1_net_set_interrupt_status_indicator(bus_id(card),
+							dev_id(card),
+		ps3_mm_phys_to_lpar(__pa(&card->irq_status)),
+		0);
+
+	if (result) {
+		dev_dbg(&dev->core,
+			"lv1_net_set_interrupt_status_indicator failed: %s\n",
+			ps3_result(result));
+		result = -EIO;
+		goto fail_status_indicator;
+	}
+
+	result = gelic_net_setup_netdev(card);
+
+	if (result) {
+		dev_dbg(&dev->core, "%s:%d: ps3_dma_region_create failed: "
+			"(%d)\n", __func__, __LINE__, result);
+		goto fail_setup_netdev;
+	}
+
+	return 0;
+
+fail_setup_netdev:
+	lv1_net_set_interrupt_status_indicator(bus_id(card),
+					       bus_id(card),
+					       0 , 0);
+fail_status_indicator:
+	ps3_dma_region_free(dev->d_region);
+fail_dma_region:
+	ps3_close_hv_device(dev);
+fail_open:
+	ps3_system_bus_set_driver_data(dev, NULL);
+	free_netdev(card->netdev);
+fail_alloc_card:
+	return result;
+}
+
+/**
+ * ps3_gelic_driver_remove - remove a device from the control of this driver
+ */
+
+static int ps3_gelic_driver_remove (struct ps3_system_bus_device *dev)
+{
+	struct gelic_net_card *card = ps3_system_bus_get_driver_data(dev);
+
+	wait_event(card->waitq,
+		   atomic_read(&card->tx_timeout_task_counter) == 0);
+
+	lv1_net_set_interrupt_status_indicator(bus_id(card), dev_id(card),
+					       0 , 0);
+
+	unregister_netdev(card->netdev);
+	free_netdev(card->netdev);
+
+	ps3_system_bus_set_driver_data(dev, NULL);
+
+	ps3_dma_region_free(dev->d_region);
+
+	ps3_close_hv_device(dev);
+
+	return 0;
+}
+
+static struct ps3_system_bus_driver ps3_gelic_driver = {
+	.match_id = PS3_MATCH_ID_GELIC,
+	.probe = ps3_gelic_driver_probe,
+	.remove = ps3_gelic_driver_remove,
+	.shutdown = ps3_gelic_driver_remove,
+	.core.name = "ps3_gelic_driver",
+	.core.owner = THIS_MODULE,
+};
+
+static int __init ps3_gelic_driver_init (void)
+{
+	return firmware_has_feature(FW_FEATURE_PS3_LV1)
+		? ps3_system_bus_driver_register(&ps3_gelic_driver)
+		: -ENODEV;
+}
+
+static void __exit ps3_gelic_driver_exit (void)
+{
+	ps3_system_bus_driver_unregister(&ps3_gelic_driver);
+}
+
+module_init (ps3_gelic_driver_init);
+module_exit (ps3_gelic_driver_exit);
+
+MODULE_ALIAS(PS3_MODULE_ALIAS_GELIC);
+
diff --git a/drivers/net/ps3_gelic_net.h b/drivers/net/ps3_gelic_net.h
new file mode 100644
index 0000000..5e1c286
--- /dev/null
+++ b/drivers/net/ps3_gelic_net.h
@@ -0,0 +1,239 @@
+/*
+ *  PS3 Platfom gelic network driver.
+ *
+ * Copyright (C) 2007 Sony Computer Entertainment Inc.
+ * Copyright 2006, 2007 Sony Corporation.
+ *
+ * This file is based on: spider_net.h
+ *
+ * (C) Copyright IBM Corp. 2005
+ *
+ * Authors : Utz Bacher <utz.bacher@de.ibm.com>
+ *           Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+#ifndef _GELIC_NET_H
+#define _GELIC_NET_H
+
+#define GELIC_NET_DRV_NAME "Gelic Network Driver"
+#define GELIC_NET_DRV_VERSION "1.0"
+
+#define GELIC_NET_ETHTOOL               /* use ethtool */
+
+/* ioctl */
+#define GELIC_NET_GET_MODE              (SIOCDEVPRIVATE + 0)
+#define GELIC_NET_SET_MODE              (SIOCDEVPRIVATE + 1)
+
+/* descriptors */
+#define GELIC_NET_RX_DESCRIPTORS        128 /* num of descriptors */
+#define GELIC_NET_TX_DESCRIPTORS        128 /* num of descriptors */
+
+#define GELIC_NET_MAX_MTU               2308
+#define GELIC_NET_MIN_MTU               64
+#define GELIC_NET_RXBUF_ALIGN           128
+#define GELIC_NET_RX_CSUM_DEFAULT       1 /* hw chksum */
+#define GELIC_NET_WATCHDOG_TIMEOUT      5*HZ
+#define GELIC_NET_NAPI_WEIGHT           (GELIC_NET_RX_DESCRIPTORS)
+#define GELIC_NET_BROADCAST_ADDR        0xffffffffffffL
+#define GELIC_NET_VLAN_POS              (VLAN_ETH_ALEN * 2)
+#define GELIC_NET_VLAN_MAX              4
+#define GELIC_NET_MC_COUNT_MAX          32 /* multicast address list */
+
+enum gelic_net_int0_status {
+	GELIC_NET_GDTDCEINT  = 24,
+	GELIC_NET_GRFANMINT  = 28,
+};
+
+/* GHIINT1STS bits */
+enum gelic_net_int1_status {
+	GELIC_NET_GDADCEINT = 14,
+};
+
+/* interrupt mask */
+#define GELIC_NET_TXINT                   (1L << (GELIC_NET_GDTDCEINT + 32))
+
+#define GELIC_NET_RXINT0                  (1L << (GELIC_NET_GRFANMINT + 32))
+#define GELIC_NET_RXINT1                  (1L << GELIC_NET_GDADCEINT)
+#define GELIC_NET_RXINT                   (GELIC_NET_RXINT0 | GELIC_NET_RXINT1)
+
+ /* RX descriptor data_status bits */
+#define GELIC_NET_RXDMADU	0x80000000 /* destination MAC addr unknown */
+#define GELIC_NET_RXLSTFBF	0x40000000 /* last frame buffer            */
+#define GELIC_NET_RXIPCHK	0x20000000 /* IP checksum performed        */
+#define GELIC_NET_RXTCPCHK	0x10000000 /* TCP/UDP checksup performed   */
+#define GELIC_NET_RXIPSPKT	0x08000000 /* IPsec packet   */
+#define GELIC_NET_RXIPSAHPRT	0x04000000 /* IPsec AH protocol performed */
+#define GELIC_NET_RXIPSESPPRT	0x02000000 /* IPsec ESP protocol performed */
+#define GELIC_NET_RXSESPAH	0x01000000 /*
+					    * IPsec ESP protocol auth
+					    * performed
+					    */
+
+#define GELIC_NET_RXWTPKT	0x00C00000 /*
+					    * wakeup trigger packet
+					    * 01: Magic Packet (TM)
+					    * 10: ARP packet
+					    * 11: Multicast MAC addr
+					    */
+#define GELIC_NET_RXVLNPKT	0x00200000 /* VLAN packet */
+/* bit 20..16 reserved */
+#define GELIC_NET_RXRECNUM	0x0000ff00 /* reception receipt number */
+/* bit 7..0 reserved */
+
+#define GELIC_NET_TXDESC_TAIL		0
+#define GELIC_NET_DATA_STATUS_CHK_MASK	(GELIC_NET_RXIPCHK | GELIC_NET_RXTCPCHK)
+
+/* RX descriptor data_error bits */
+/* bit 31 reserved */
+#define GELIC_NET_RXALNERR	0x40000000 /* alignement error 10/100M */
+#define GELIC_NET_RXOVERERR	0x20000000 /* oversize error */
+#define GELIC_NET_RXRNTERR	0x10000000 /* Runt error */
+#define GELIC_NET_RXIPCHKERR	0x08000000 /* IP checksum  error */
+#define GELIC_NET_RXTCPCHKERR	0x04000000 /* TCP/UDP checksum  error */
+#define GELIC_NET_RXUMCHSP	0x02000000 /* unmatched sp on sp */
+#define GELIC_NET_RXUMCHSPI	0x01000000 /* unmatched SPI on SAD */
+#define GELIC_NET_RXUMCHSAD	0x00800000 /* unmatched SAD */
+#define GELIC_NET_RXIPSAHERR	0x00400000 /* auth error on AH protocol
+					    * processing */
+#define GELIC_NET_RXIPSESPAHERR	0x00200000 /* auth error on ESP protocol
+					    * processing */
+#define GELIC_NET_RXDRPPKT	0x00100000 /* drop packet */
+#define GELIC_NET_RXIPFMTERR	0x00080000 /* IP packet format error */
+/* bit 18 reserved */
+#define GELIC_NET_RXDATAERR	0x00020000 /* IP packet format error */
+#define GELIC_NET_RXCALERR	0x00010000 /* cariier extension length
+					    * error */
+#define GELIC_NET_RXCREXERR	0x00008000 /* carrier extention error */
+#define GELIC_NET_RXMLTCST	0x00004000 /* multicast address frame */
+/* bit 13..0 reserved */
+#define GELIC_NET_DATA_ERROR_CHK_MASK		\
+	(GELIC_NET_RXIPCHKERR | GELIC_NET_RXTCPCHKERR)
+
+
+/* tx descriptor command and status */
+#define GELIC_NET_DMAC_CMDSTAT_NOCS       0xa0080000 /* middle of frame */
+#define GELIC_NET_DMAC_CMDSTAT_TCPCS      0xa00a0000
+#define GELIC_NET_DMAC_CMDSTAT_UDPCS      0xa00b0000
+#define GELIC_NET_DMAC_CMDSTAT_END_FRAME  0x00040000 /* end of frame */
+
+#define GELIC_NET_DMAC_CMDSTAT_RXDCEIS	  0x00000002 /* descriptor chain end
+						      * interrupt status */
+
+#define GELIC_NET_DMAC_CMDSTAT_CHAIN_END  0x00000002 /* RXDCEIS:DMA stopped */
+#define GELIC_NET_DMAC_CMDSTAT_NOT_IN_USE 0xb0000000
+#define GELIC_NET_DESCR_IND_PROC_SHIFT    28
+#define GELIC_NET_DESCR_IND_PROC_MASKO    0x0fffffff
+
+
+enum gelic_net_descr_status {
+	GELIC_NET_DESCR_COMPLETE            = 0x00, /* used in rx and tx */
+	GELIC_NET_DESCR_RESPONSE_ERROR      = 0x01, /* used in rx and tx */
+	GELIC_NET_DESCR_PROTECTION_ERROR    = 0x02, /* used in rx and tx */
+	GELIC_NET_DESCR_FRAME_END           = 0x04, /* used in rx */
+	GELIC_NET_DESCR_FORCE_END           = 0x05, /* used in rx and tx */
+	GELIC_NET_DESCR_CARDOWNED           = 0x0a, /* used in rx and tx */
+	GELIC_NET_DESCR_NOT_IN_USE                  /* any other value */
+};
+/* for lv1_net_control */
+#define GELIC_NET_GET_MAC_ADDRESS               0x0000000000000001
+#define GELIC_NET_GET_ETH_PORT_STATUS           0x0000000000000002
+#define GELIC_NET_SET_NEGOTIATION_MODE          0x0000000000000003
+#define GELIC_NET_GET_VLAN_ID                   0x0000000000000004
+
+#define GELIC_NET_LINK_UP                       0x0000000000000001
+#define GELIC_NET_FULL_DUPLEX                   0x0000000000000002
+#define GELIC_NET_AUTO_NEG                      0x0000000000000004
+#define GELIC_NET_SPEED_10                      0x0000000000000010
+#define GELIC_NET_SPEED_100                     0x0000000000000020
+#define GELIC_NET_SPEED_1000                    0x0000000000000040
+
+#define GELIC_NET_VLAN_ALL                      0x0000000000000001
+#define GELIC_NET_VLAN_WIRED                    0x0000000000000002
+#define GELIC_NET_VLAN_WIRELESS                 0x0000000000000003
+#define GELIC_NET_VLAN_PSP                      0x0000000000000004
+#define GELIC_NET_VLAN_PORT0                    0x0000000000000010
+#define GELIC_NET_VLAN_PORT1                    0x0000000000000011
+#define GELIC_NET_VLAN_PORT2                    0x0000000000000012
+#define GELIC_NET_VLAN_DAEMON_CLIENT_BSS        0x0000000000000013
+#define GELIC_NET_VLAN_LIBERO_CLIENT_BSS        0x0000000000000014
+#define GELIC_NET_VLAN_NO_ENTRY                 -6
+
+#define GELIC_NET_PORT                          2 /* for port status */
+
+/* size of hardware part of gelic descriptor */
+#define GELIC_NET_DESCR_SIZE	(32)
+struct gelic_net_descr {
+	/* as defined by the hardware */
+	u32 buf_addr;
+	u32 buf_size;
+	u32 next_descr_addr;
+	u32 dmac_cmd_status;
+	u32 result_size;
+	u32 valid_size;	/* all zeroes for tx */
+	u32 data_status;
+	u32 data_error;	/* all zeroes for tx */
+
+	/* used in the driver */
+	struct sk_buff *skb;
+	dma_addr_t bus_addr;
+	struct gelic_net_descr *next;
+	struct gelic_net_descr *prev;
+	struct vlan_ethhdr vlan;
+} __attribute__((aligned(32)));
+
+struct gelic_net_descr_chain {
+	/* we walk from tail to head */
+	struct gelic_net_descr *head;
+	struct gelic_net_descr *tail;
+};
+
+struct gelic_net_card {
+	struct net_device *netdev;
+	/*
+	 * hypervisor requires irq_status should be
+	 * 8 bytes aligned, but u64 member is
+	 * always disposed in that manner
+	 */
+	u64 irq_status;
+	u64 ghiintmask;
+
+	struct ps3_system_bus_device *dev;
+	u32 vlan_id[GELIC_NET_VLAN_MAX];
+	int vlan_index;
+
+	struct gelic_net_descr_chain tx_chain;
+	struct gelic_net_descr_chain rx_chain;
+	/* gurad dmac descriptor chain*/
+	spinlock_t chain_lock;
+
+	struct net_device_stats netdev_stats;
+	int rx_csum;
+	/* guard tx_dma_progress */
+	spinlock_t tx_dma_lock;
+	int tx_dma_progress;
+
+	struct work_struct tx_timeout_task;
+	atomic_t tx_timeout_task_counter;
+	wait_queue_head_t waitq;
+
+	struct gelic_net_descr *tx_top, *rx_top;
+	struct gelic_net_descr descr[0];
+};
+
+
+extern unsigned long p_to_lp(long pa);
+
+#endif /* _GELIC_NET_H */
diff --git a/drivers/net/rrunner.c b/drivers/net/rrunner.c
index 25c73d4..5c2e41f 100644
--- a/drivers/net/rrunner.c
+++ b/drivers/net/rrunner.c
@@ -516,7 +516,7 @@ static unsigned int write_eeprom(struct rr_private *rrpriv,
 }
 
 
-static int __init rr_init(struct net_device *dev)
+static int __devinit rr_init(struct net_device *dev)
 {
 	struct rr_private *rrpriv;
 	struct rr_regs __iomem *regs;
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 2d826ff..fa29a40 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -8036,7 +8036,7 @@ static void lro_append_pkt(struct s2io_nic *sp, struct lro *lro,
 /**
  * s2io_io_error_detected - called when PCI error is detected
  * @pdev: Pointer to PCI device
- * @state: The current pci conneection state
+ * @state: The current pci connection state
  *
  * This function is called after a PCI bus error affecting
  * this device has been detected.
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index 2cb2e15..7c6e480 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -573,7 +573,7 @@ static int __devinit sis900_probe(struct pci_dev *pci_dev,
  *	return error if it failed to found.
  */
 
-static int __init sis900_mii_probe(struct net_device * net_dev)
+static int __devinit sis900_mii_probe(struct net_device * net_dev)
 {
 	struct sis900_private * sis_priv = net_dev->priv;
 	const char *dev_name = pci_name(sis_priv->pci_dev);

=======================================================================
SNIP snip   obvious sk98lin driver removal patches   snip SNIP
=======================================================================

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index b51d73c..a2f3215 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -39,6 +39,7 @@
 #include <linux/workqueue.h>
 #include <linux/if_vlan.h>
 #include <linux/prefetch.h>
+#include <linux/debugfs.h>
 #include <linux/mii.h>
 
 #include <asm/irq.h>
@@ -50,7 +51,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.15"
+#define DRV_VERSION		"1.16"
 #define PFX			DRV_NAME " "
 
 /*
@@ -64,7 +65,6 @@
 #define RX_MAX_PENDING		(RX_LE_SIZE/6 - 2)
 #define RX_DEF_PENDING		RX_MAX_PENDING
 #define RX_SKB_ALIGN		8
-#define RX_BUF_WRITE		16
 
 #define TX_RING_SIZE		512
 #define TX_DEF_PENDING		(TX_RING_SIZE - 1)
@@ -77,6 +77,9 @@
 #define NAPI_WEIGHT		64
 #define PHY_RETRIES		1000
 
+#define SKY2_EEPROM_MAGIC	0x9955aabb
+
+
 #define RING_NEXT(x,s)	(((x)+1) & ((s)-1))
 
 static const u32 default_msg =
@@ -96,7 +99,7 @@ static int disable_msi = 0;
 module_param(disable_msi, int, 0);
 MODULE_PARM_DESC(disable_msi, "Disable Message Signaled Interrupt (MSI)");
 
-static int idle_timeout = 0;
+static int idle_timeout = 100;
 module_param(idle_timeout, int, 0);
 MODULE_PARM_DESC(idle_timeout, "Watchdog timer for lost interrupts (ms)");
 
@@ -890,24 +893,18 @@ static inline struct sky2_rx_le *sky2_next_rx(struct sky2_port *sky2)
 	return le;
 }
 
-/* Return high part of DMA address (could be 32 or 64 bit) */
-static inline u32 high32(dma_addr_t a)
-{
-	return sizeof(a) > sizeof(u32) ? (a >> 16) >> 16 : 0;
-}
-
 /* Build description to hardware for one receive segment */
 static void sky2_rx_add(struct sky2_port *sky2,  u8 op,
 			dma_addr_t map, unsigned len)
 {
 	struct sky2_rx_le *le;
-	u32 hi = high32(map);
+	u32 hi = upper_32_bits(map);
 
 	if (sky2->rx_addr64 != hi) {
 		le = sky2_next_rx(sky2);
 		le->addr = cpu_to_le32(hi);
 		le->opcode = OP_ADDR64 | HW_OWNER;
-		sky2->rx_addr64 = high32(map + len);
+		sky2->rx_addr64 = upper_32_bits(map + len);
 	}
 
 	le = sky2_next_rx(sky2);
@@ -1137,6 +1134,11 @@ nomem:
 	return NULL;
 }
 
+static inline void sky2_rx_update(struct sky2_port *sky2, unsigned rxq)
+{
+	sky2_put_idx(sky2->hw, rxq, sky2->rx_put);
+}
+
 /*
  * Allocate and setup receiver buffer pool.
  * Normal case this ends up creating one list element for skb
@@ -1172,8 +1174,7 @@ static int sky2_rx_start(struct sky2_port *sky2)
 	rx_set_checksum(sky2);
 
 	/* Space needed for frame data + headers rounded up */
-	size = ALIGN(sky2->netdev->mtu + ETH_HLEN + VLAN_HLEN, 8)
-		+ 8;
+	size = roundup(sky2->netdev->mtu + ETH_HLEN + VLAN_HLEN, 8);
 
 	/* Stopping point for hardware truncation */
 	thresh = (size - 8) / sizeof(u32);
@@ -1228,7 +1229,7 @@ static int sky2_rx_start(struct sky2_port *sky2)
 	}
 
 	/* Tell chip about available buffers */
-	sky2_put_idx(hw, rxq, sky2->rx_put);
+	sky2_rx_update(sky2, rxq);
 	return 0;
 nomem:
 	sky2_rx_clean(sky2);
@@ -1265,6 +1266,8 @@ static int sky2_up(struct net_device *dev)
 	if (netif_msg_ifup(sky2))
 		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
 
+	netif_carrier_off(dev);
+
 	/* must be power of 2 */
 	sky2->tx_le = pci_alloc_consistent(hw->pdev,
 					   TX_RING_SIZE *
@@ -1415,14 +1418,15 @@ static int sky2_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 
 	len = skb_headlen(skb);
 	mapping = pci_map_single(hw->pdev, skb->data, len, PCI_DMA_TODEVICE);
-	addr64 = high32(mapping);
+	addr64 = upper_32_bits(mapping);
 
 	/* Send high bits if changed or crosses boundary */
-	if (addr64 != sky2->tx_addr64 || high32(mapping + len) != sky2->tx_addr64) {
+	if (addr64 != sky2->tx_addr64 ||
+	    upper_32_bits(mapping + len) != sky2->tx_addr64) {
 		le = get_tx_le(sky2);
 		le->addr = cpu_to_le32(addr64);
 		le->opcode = OP_ADDR64 | HW_OWNER;
-		sky2->tx_addr64 = high32(mapping + len);
+		sky2->tx_addr64 = upper_32_bits(mapping + len);
 	}
 
 	/* Check for TCP Segmentation Offload */
@@ -1502,7 +1506,7 @@ static int sky2_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 
 		mapping = pci_map_page(hw->pdev, frag->page, frag->page_offset,
 				       frag->size, PCI_DMA_TODEVICE);
-		addr64 = high32(mapping);
+		addr64 = upper_32_bits(mapping);
 		if (addr64 != sky2->tx_addr64) {
 			le = get_tx_le(sky2);
 			le->addr = cpu_to_le32(addr64);
@@ -1572,13 +1576,13 @@ static void sky2_tx_complete(struct sky2_port *sky2, u16 done)
 			if (unlikely(netif_msg_tx_done(sky2)))
 				printk(KERN_DEBUG "%s: tx done %u\n",
 				       dev->name, idx);
+
 			sky2->net_stats.tx_packets++;
 			sky2->net_stats.tx_bytes += re->skb->len;
 
 			dev_kfree_skb_any(re->skb);
+			sky2->tx_next = RING_NEXT(idx, TX_RING_SIZE);
 		}
-
-		le->opcode = 0;	/* paranoia */
 	}
 
 	sky2->tx_cons = idx;
@@ -1616,7 +1620,6 @@ static int sky2_down(struct net_device *dev)
 
 	/* Stop more packets from being queued */
 	netif_stop_queue(dev);
-	netif_carrier_off(dev);
 
 	/* Disable port IRQ */
 	imask = sky2_read32(hw, B0_IMSK);
@@ -1668,6 +1671,8 @@ static int sky2_down(struct net_device *dev)
 
 	sky2_phy_power(hw, port, 0);
 
+	netif_carrier_off(dev);
+
 	/* turn off LED's */
 	sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);
 
@@ -1732,7 +1737,6 @@ static void sky2_link_up(struct sky2_port *sky2)
 	gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_DEF_MSK);
 
 	netif_carrier_on(sky2->netdev);
-	netif_wake_queue(sky2->netdev);
 
 	/* Turn on link LED */
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG),
@@ -1784,7 +1788,6 @@ static void sky2_link_down(struct sky2_port *sky2)
 	gma_write16(hw, port, GM_GP_CTRL, reg);
 
 	netif_carrier_off(sky2->netdev);
-	netif_stop_queue(sky2->netdev);
 
 	/* Turn on link LED */
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG), LINKLED_OFF);
@@ -2055,8 +2058,6 @@ static struct sk_buff *receive_new(struct sky2_port *sky2,
 	struct sk_buff *skb, *nskb;
 	unsigned hdr_space = sky2->rx_data_size;
 
-	pr_debug(PFX "receive new length=%d\n", length);
-
 	/* Don't be tricky about reusing pages (yet) */
 	nskb = sky2_rx_alloc(sky2);
 	if (unlikely(!nskb))
@@ -2100,6 +2101,9 @@ static struct sk_buff *sky2_receive(struct net_device *dev,
 	if (!(status & GMR_FS_RX_OK))
 		goto resubmit;
 
+	if (status >> 16 != length)
+		goto len_mismatch;
+
 	if (length < copybreak)
 		skb = receive_copy(sky2, re, length);
 	else
@@ -2109,6 +2113,11 @@ resubmit:
 
 	return skb;
 
+len_mismatch:
+	/* Truncation of overlength packets
+	   causes PHY length to not match MAC length */
+	++sky2->net_stats.rx_length_errors;
+
 error:
 	++sky2->net_stats.rx_errors;
 	if (status & GMR_FS_RX_FF_OV) {
@@ -2145,14 +2154,14 @@ static inline void sky2_tx_done(struct net_device *dev, u16 last)
 /* Process status response ring */
 static int sky2_status_intr(struct sky2_hw *hw, int to_do)
 {
-	struct sky2_port *sky2;
 	int work_done = 0;
-	unsigned buf_write[2] = { 0, 0 };
+	unsigned rx[2] = { 0, 0 };
 	u16 hwidx = sky2_read16(hw, STAT_PUT_IDX);
 
 	rmb();
 
 	while (hw->st_idx != hwidx) {
+		struct sky2_port *sky2;
 		struct sky2_status_le *le  = hw->st_le + hw->st_idx;
 		unsigned port = le->css & CSS_LINK_BIT;
 		struct net_device *dev;
@@ -2169,10 +2178,11 @@ static int sky2_status_intr(struct sky2_hw *hw, int to_do)
 
 		switch (le->opcode & ~HW_OWNER) {
 		case OP_RXSTAT:
+			++rx[port];
 			skb = sky2_receive(dev, length, status);
 			if (unlikely(!skb)) {
 				sky2->net_stats.rx_dropped++;
-				goto force_update;
+				break;
 			}
 
 			/* This chip reports checksum status differently */
@@ -2199,13 +2209,6 @@ static int sky2_status_intr(struct sky2_hw *hw, int to_do)
 #endif
 				netif_receive_skb(skb);
 
-			/* Update receiver after 16 frames */
-			if (++buf_write[port] == RX_BUF_WRITE) {
-force_update:
-				sky2_put_idx(hw, rxqaddr[port], sky2->rx_put);
-				buf_write[port] = 0;
-			}
-
 			/* Stop after net poll weight */
 			if (++work_done >= to_do)
 				goto exit_loop;
@@ -2261,24 +2264,18 @@ force_update:
 			if (net_ratelimit())
 				printk(KERN_WARNING PFX
 				       "unknown status opcode 0x%x\n", le->opcode);
-			goto exit_loop;
 		}
 	}
 
 	/* Fully processed status ring so clear irq */
 	sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
-	mmiowb();
 
 exit_loop:
-	if (buf_write[0]) {
-		sky2 = netdev_priv(hw->dev[0]);
-		sky2_put_idx(hw, Q_R1, sky2->rx_put);
-	}
+	if (rx[0])
+		sky2_rx_update(netdev_priv(hw->dev[0]), Q_R1);
 
-	if (buf_write[1]) {
-		sky2 = netdev_priv(hw->dev[1]);
-		sky2_put_idx(hw, Q_R2, sky2->rx_put);
-	}
+	if (rx[1])
+		sky2_rx_update(netdev_priv(hw->dev[1]), Q_R2);
 
 	return work_done;
 }
@@ -2475,8 +2472,7 @@ static void sky2_err_intr(struct sky2_hw *hw, u32 status)
 static int sky2_poll(struct net_device *dev0, int *budget)
 {
 	struct sky2_hw *hw = ((struct sky2_port *) netdev_priv(dev0))->hw;
-	int work_limit = min(dev0->quota, *budget);
-	int work_done = 0;
+	int work_done;
 	u32 status = sky2_read32(hw, B0_Y2_SP_EISR);
 
 	if (unlikely(status & Y2_IS_ERROR))
@@ -2488,18 +2484,25 @@ static int sky2_poll(struct net_device *dev0, int *budget)
 	if (status & Y2_IS_IRQ_PHY2)
 		sky2_phy_intr(hw, 1);
 
-	work_done = sky2_status_intr(hw, work_limit);
-	if (work_done < work_limit) {
-		netif_rx_complete(dev0);
+	work_done = sky2_status_intr(hw, min(dev0->quota, *budget));
+	*budget -= work_done;
+	dev0->quota -= work_done;
 
-		/* end of interrupt, re-enables also acts as I/O synchronization */
-		sky2_read32(hw, B0_Y2_SP_LISR);
-		return 0;
-	} else {
-		*budget -= work_done;
-		dev0->quota -= work_done;
+	/* More work? */
+ 	if (hw->st_idx != sky2_read16(hw, STAT_PUT_IDX))
 		return 1;
+
+	/* Bug/Errata workaround?
+	 * Need to kick the TX irq moderation timer.
+	 */
+	if (sky2_read8(hw, STAT_TX_TIMER_CTRL) == TIM_START) {
+		sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
+		sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
 	}
+	netif_rx_complete(dev0);
+
+	sky2_read32(hw, B0_Y2_SP_LISR);
+	return 0;
 }
 
 static irqreturn_t sky2_intr(int irq, void *dev_id)
@@ -2723,8 +2726,6 @@ static void sky2_restart(struct work_struct *work)
 	struct net_device *dev;
 	int i, err;
 
-	dev_dbg(&hw->pdev->dev, "restarting\n");
-
 	del_timer_sync(&hw->idle_timer);
 
 	rtnl_lock();
@@ -3429,39 +3430,315 @@ static int sky2_set_tso(struct net_device *dev, u32 data)
 	return ethtool_op_set_tso(dev, data);
 }
 
+static int sky2_get_eeprom_len(struct net_device *dev)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+	u16 reg2;
+
+	reg2 = sky2_pci_read32(sky2->hw, PCI_DEV_REG2);
+	return 1 << ( ((reg2 & PCI_VPD_ROM_SZ) >> 14) + 8);
+}
+
+static u32 sky2_vpd_read(struct sky2_hw *hw, int cap, u16 offset)
+{
+	sky2_pci_write16(hw, cap + PCI_VPD_ADDR, offset);
+
+	while (!(sky2_pci_read16(hw, cap + PCI_VPD_ADDR) & PCI_VPD_ADDR_F))
+			cpu_relax();
+	return sky2_pci_read32(hw, cap + PCI_VPD_DATA);
+}
+
+static void sky2_vpd_write(struct sky2_hw *hw, int cap, u16 offset, u32 val)
+{
+	sky2_pci_write32(hw, cap + PCI_VPD_DATA, val);
+	sky2_pci_write16(hw, cap + PCI_VPD_ADDR, offset | PCI_VPD_ADDR_F);
+	do {
+		cpu_relax();
+	} while (sky2_pci_read16(hw, cap + PCI_VPD_ADDR) & PCI_VPD_ADDR_F);
+}
+
+static int sky2_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
+			   u8 *data)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+	int cap = pci_find_capability(sky2->hw->pdev, PCI_CAP_ID_VPD);
+	int length = eeprom->len;
+	u16 offset = eeprom->offset;
+
+	if (!cap)
+		return -EINVAL;
+
+	eeprom->magic = SKY2_EEPROM_MAGIC;
+
+	while (length > 0) {
+		u32 val = sky2_vpd_read(sky2->hw, cap, offset);
+		int n = min_t(int, length, sizeof(val));
+
+		memcpy(data, &val, n);
+		length -= n;
+		data += n;
+		offset += n;
+	}
+	return 0;
+}
+
+static int sky2_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
+			   u8 *data)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+	int cap = pci_find_capability(sky2->hw->pdev, PCI_CAP_ID_VPD);
+	int length = eeprom->len;
+	u16 offset = eeprom->offset;
+
+	if (!cap)
+		return -EINVAL;
+
+	if (eeprom->magic != SKY2_EEPROM_MAGIC)
+		return -EINVAL;
+
+	while (length > 0) {
+		u32 val;
+		int n = min_t(int, length, sizeof(val));
+
+		if (n < sizeof(val))
+			val = sky2_vpd_read(sky2->hw, cap, offset);
+		memcpy(&val, data, n);
+
+		sky2_vpd_write(sky2->hw, cap, offset, val);
+
+		length -= n;
+		data += n;
+		offset += n;
+	}
+	return 0;
+}
+
+
 static const struct ethtool_ops sky2_ethtool_ops = {
-	.get_settings = sky2_get_settings,
-	.set_settings = sky2_set_settings,
-	.get_drvinfo  = sky2_get_drvinfo,
-	.get_wol      = sky2_get_wol,
-	.set_wol      = sky2_set_wol,
-	.get_msglevel = sky2_get_msglevel,
-	.set_msglevel = sky2_set_msglevel,
-	.nway_reset   = sky2_nway_reset,
-	.get_regs_len = sky2_get_regs_len,
-	.get_regs = sky2_get_regs,
-	.get_link = ethtool_op_get_link,
-	.get_sg = ethtool_op_get_sg,
-	.set_sg = ethtool_op_set_sg,
-	.get_tx_csum = ethtool_op_get_tx_csum,
-	.set_tx_csum = sky2_set_tx_csum,
-	.get_tso = ethtool_op_get_tso,
-	.set_tso = sky2_set_tso,
-	.get_rx_csum = sky2_get_rx_csum,
-	.set_rx_csum = sky2_set_rx_csum,
-	.get_strings = sky2_get_strings,
-	.get_coalesce = sky2_get_coalesce,
-	.set_coalesce = sky2_set_coalesce,
-	.get_ringparam = sky2_get_ringparam,
-	.set_ringparam = sky2_set_ringparam,
+	.get_settings	= sky2_get_settings,
+	.set_settings	= sky2_set_settings,
+	.get_drvinfo	= sky2_get_drvinfo,
+	.get_wol	= sky2_get_wol,
+	.set_wol	= sky2_set_wol,
+	.get_msglevel	= sky2_get_msglevel,
+	.set_msglevel	= sky2_set_msglevel,
+	.nway_reset	= sky2_nway_reset,
+	.get_regs_len	= sky2_get_regs_len,
+	.get_regs	= sky2_get_regs,
+	.get_link	= ethtool_op_get_link,
+	.get_eeprom_len	= sky2_get_eeprom_len,
+	.get_eeprom	= sky2_get_eeprom,
+	.set_eeprom	= sky2_set_eeprom,
+	.get_sg 	= ethtool_op_get_sg,
+	.set_sg 	= ethtool_op_set_sg,
+	.get_tx_csum	= ethtool_op_get_tx_csum,
+	.set_tx_csum	= sky2_set_tx_csum,
+	.get_tso	= ethtool_op_get_tso,
+	.set_tso	= sky2_set_tso,
+	.get_rx_csum	= sky2_get_rx_csum,
+	.set_rx_csum	= sky2_set_rx_csum,
+	.get_strings	= sky2_get_strings,
+	.get_coalesce	= sky2_get_coalesce,
+	.set_coalesce	= sky2_set_coalesce,
+	.get_ringparam	= sky2_get_ringparam,
+	.set_ringparam	= sky2_set_ringparam,
 	.get_pauseparam = sky2_get_pauseparam,
 	.set_pauseparam = sky2_set_pauseparam,
-	.phys_id = sky2_phys_id,
+	.phys_id	= sky2_phys_id,
 	.get_stats_count = sky2_get_stats_count,
 	.get_ethtool_stats = sky2_get_ethtool_stats,
 	.get_perm_addr	= ethtool_op_get_perm_addr,
 };
 
+#ifdef CONFIG_SKY2_DEBUG
+
+static struct dentry *sky2_debug;
+
+static int sky2_debug_show(struct seq_file *seq, void *v)
+{
+	struct net_device *dev = seq->private;
+	const struct sky2_port *sky2 = netdev_priv(dev);
+	const struct sky2_hw *hw = sky2->hw;
+	unsigned port = sky2->port;
+	unsigned idx, last;
+	int sop;
+
+	if (!netif_running(dev))
+		return -ENETDOWN;
+
+	seq_printf(seq, "IRQ src=%x mask=%x control=%x\n",
+		   sky2_read32(hw, B0_ISRC),
+		   sky2_read32(hw, B0_IMSK),
+		   sky2_read32(hw, B0_Y2_SP_ICR));
+
+	netif_poll_disable(hw->dev[0]);
+	last = sky2_read16(hw, STAT_PUT_IDX);
+
+	if (hw->st_idx == last)
+		seq_puts(seq, "Status ring (empty)\n");
+	else {
+		seq_puts(seq, "Status ring\n");
+		for (idx = hw->st_idx; idx != last && idx < STATUS_RING_SIZE;
+		     idx = RING_NEXT(idx, STATUS_RING_SIZE)) {
+			const struct sky2_status_le *le = hw->st_le + idx;
+			seq_printf(seq, "[%d] %#x %d %#x\n",
+				   idx, le->opcode, le->length, le->status);
+		}
+		seq_puts(seq, "\n");
+	}
+
+	seq_printf(seq, "Tx ring pending=%u...%u report=%d done=%d\n",
+		   sky2->tx_cons, sky2->tx_prod,
+		   sky2_read16(hw, port == 0 ? STAT_TXA1_RIDX : STAT_TXA2_RIDX),
+		   sky2_read16(hw, Q_ADDR(txqaddr[port], Q_DONE)));
+
+	/* Dump contents of tx ring */
+	sop = 1;
+	for (idx = sky2->tx_next; idx != sky2->tx_prod && idx < TX_RING_SIZE;
+	     idx = RING_NEXT(idx, TX_RING_SIZE)) {
+		const struct sky2_tx_le *le = sky2->tx_le + idx;
+		u32 a = le32_to_cpu(le->addr);
+
+		if (sop)
+			seq_printf(seq, "%u:", idx);
+		sop = 0;
+
+		switch(le->opcode & ~HW_OWNER) {
+		case OP_ADDR64:
+			seq_printf(seq, " %#x:", a);
+			break;
+		case OP_LRGLEN:
+			seq_printf(seq, " mtu=%d", a);
+			break;
+		case OP_VLAN:
+			seq_printf(seq, " vlan=%d", be16_to_cpu(le->length));
+			break;
+		case OP_TCPLISW:
+			seq_printf(seq, " csum=%#x", a);
+			break;
+		case OP_LARGESEND:
+			seq_printf(seq, " tso=%#x(%d)", a, le16_to_cpu(le->length));
+			break;
+		case OP_PACKET:
+			seq_printf(seq, " %#x(%d)", a, le16_to_cpu(le->length));
+			break;
+		case OP_BUFFER:
+			seq_printf(seq, " frag=%#x(%d)", a, le16_to_cpu(le->length));
+			break;
+		default:
+			seq_printf(seq, " op=%#x,%#x(%d)", le->opcode,
+				   a, le16_to_cpu(le->length));
+		}
+
+		if (le->ctrl & EOP) {
+			seq_putc(seq, '\n');
+			sop = 1;
+		}
+	}
+
+	seq_printf(seq, "\nRx ring hw get=%d put=%d last=%d\n",
+		   sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_GET_IDX)),
+		   last = sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_PUT_IDX)),
+		   sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_LAST_IDX)));
+
+	netif_poll_enable(hw->dev[0]);
+	return 0;
+}
+
+static int sky2_debug_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, sky2_debug_show, inode->i_private);
+}
+
+static const struct file_operations sky2_debug_fops = {
+	.owner		= THIS_MODULE,
+	.open		= sky2_debug_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+/*
+ * Use network device events to create/remove/rename
+ * debugfs file entries
+ */
+static int sky2_device_event(struct notifier_block *unused,
+			     unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+
+	if (dev->open == sky2_up) {
+		struct sky2_port *sky2 = netdev_priv(dev);
+
+		switch(event) {
+		case NETDEV_CHANGENAME:
+			if (!netif_running(dev))
+				break;
+			/* fallthrough */
+		case NETDEV_DOWN:
+		case NETDEV_GOING_DOWN:
+			if (sky2->debugfs) {
+				printk(KERN_DEBUG PFX "%s: remove debugfs\n",
+				       dev->name);
+				debugfs_remove(sky2->debugfs);
+				sky2->debugfs = NULL;
+			}
+
+			if (event != NETDEV_CHANGENAME)
+				break;
+			/* fallthrough for changename */
+		case NETDEV_UP:
+			if (sky2_debug) {
+				struct dentry *d;
+				d = debugfs_create_file(dev->name, S_IRUGO,
+							sky2_debug, dev,
+							&sky2_debug_fops);
+				if (d == NULL || IS_ERR(d))
+					printk(KERN_INFO PFX
+					       "%s: debugfs create failed\n",
+					       dev->name);
+				else
+					sky2->debugfs = d;
+			}
+			break;
+		}
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block sky2_notifier = {
+	.notifier_call = sky2_device_event,
+};
+
+
+static __init void sky2_debug_init(void)
+{
+	struct dentry *ent;
+
+	ent = debugfs_create_dir("sky2", NULL);
+	if (!ent || IS_ERR(ent))
+		return;
+
+	sky2_debug = ent;
+	register_netdevice_notifier(&sky2_notifier);
+}
+
+static __exit void sky2_debug_cleanup(void)
+{
+	if (sky2_debug) {
+		unregister_netdevice_notifier(&sky2_notifier);
+		debugfs_remove(sky2_debug);
+		sky2_debug = NULL;
+	}
+}
+
+#else
+#define sky2_debug_init()
+#define sky2_debug_cleanup()
+#endif
+
+
 /* Initialize network device */
 static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 						     unsigned port,
@@ -3536,10 +3813,6 @@ static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 	memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8, ETH_ALEN);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
-	/* device is off until link detection */
-	netif_carrier_off(dev);
-	netif_stop_queue(dev);
-
 	return dev;
 }
 
@@ -3956,12 +4229,14 @@ static struct pci_driver sky2_driver = {
 
 static int __init sky2_init_module(void)
 {
+	sky2_debug_init();
 	return pci_register_driver(&sky2_driver);
 }
 
 static void __exit sky2_cleanup_module(void)
 {
 	pci_unregister_driver(&sky2_driver);
+	sky2_debug_cleanup();
 }
 
 module_init(sky2_init_module);
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 8df4643..dce4d27 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -1998,6 +1998,7 @@ struct sky2_port {
 	struct sky2_tx_le    *tx_le;
 	u16		     tx_cons;		/* next le to check */
 	u16		     tx_prod;		/* next le to use */
+	u16		     tx_next;		/* debug only */
 	u32		     tx_addr64;
 	u16		     tx_pending;
 	u16		     tx_last_mss;
@@ -2028,6 +2029,9 @@ struct sky2_port {
  	enum flow_control    flow_mode;
  	enum flow_control    flow_status;
 
+#ifdef CONFIG_SKY2_DEBUG
+	struct dentry	     *debugfs;
+#endif
 	struct net_device_stats net_stats;
 
 };
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index f5abb52..590b12c 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -1441,11 +1441,17 @@ static void
 spider_net_handle_error_irq(struct spider_net_card *card, u32 status_reg)
 {
 	u32 error_reg1, error_reg2;
+	u32 mask_reg1, mask_reg2;
 	u32 i;
 	int show_error = 1;
 
 	error_reg1 = spider_net_read_reg(card, SPIDER_NET_GHIINT1STS);
 	error_reg2 = spider_net_read_reg(card, SPIDER_NET_GHIINT2STS);
+	mask_reg1 = spider_net_read_reg(card, SPIDER_NET_GHIINT1MSK);
+	mask_reg2 = spider_net_read_reg(card,SPIDER_NET_GHIINT2MSK);
+
+	error_reg1 &= mask_reg1;
+	error_reg2 &= mask_reg2;
 
 	/* check GHIINT0STS ************************************/
 	if (status_reg)
@@ -1673,9 +1679,11 @@ spider_net_interrupt(int irq, void *ptr)
 {
 	struct net_device *netdev = ptr;
 	struct spider_net_card *card = netdev_priv(netdev);
-	u32 status_reg;
+	u32 status_reg, mask_reg;
 
 	status_reg = spider_net_read_reg(card, SPIDER_NET_GHIINT0STS);
+	mask_reg = spider_net_read_reg(card, SPIDER_NET_GHIINT0MSK);
+	status_reg &= mask_reg;
 
 	if (!status_reg)
 		return IRQ_NONE;
@@ -1717,6 +1725,38 @@ spider_net_poll_controller(struct net_device *netdev)
 #endif /* CONFIG_NET_POLL_CONTROLLER */
 
 /**
+ * spider_net_enable_interrupts - enable interrupts
+ * @card: card structure
+ *
+ * spider_net_enable_interrupt enables several interrupts
+ */
+static void 
+spider_net_enable_interrupts(struct spider_net_card *card)
+{
+	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK,
+			     SPIDER_NET_INT0_MASK_VALUE);
+	spider_net_write_reg(card, SPIDER_NET_GHIINT1MSK,
+			     SPIDER_NET_INT1_MASK_VALUE);
+	spider_net_write_reg(card, SPIDER_NET_GHIINT2MSK,
+			     SPIDER_NET_INT2_MASK_VALUE);
+}
+
+/**
+ * spider_net_disable_interrupts - disable interrupts
+ * @card: card structure
+ *
+ * spider_net_disable_interrupts disables all the interrupts
+ */
+static void 
+spider_net_disable_interrupts(struct spider_net_card *card)
+{
+	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK, 0);
+	spider_net_write_reg(card, SPIDER_NET_GHIINT1MSK, 0);
+	spider_net_write_reg(card, SPIDER_NET_GHIINT2MSK, 0);
+	spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0);
+}
+
+/**
  * spider_net_init_card - initializes the card
  * @card: card structure
  *
@@ -1736,6 +1776,7 @@ spider_net_init_card(struct spider_net_card *card)
 	spider_net_write_reg(card, SPIDER_NET_GMACOPEMD,
 		spider_net_read_reg(card, SPIDER_NET_GMACOPEMD) | 0x4);
 
+	spider_net_disable_interrupts(card);
 }
 
 /**
@@ -1823,14 +1864,6 @@ spider_net_enable_card(struct spider_net_card *card)
 	spider_net_write_reg(card, SPIDER_NET_GMACOPEMD,
 			     SPIDER_NET_OPMODE_VALUE);
 
-	/* set interrupt mask registers */
-	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK,
-			     SPIDER_NET_INT0_MASK_VALUE);
-	spider_net_write_reg(card, SPIDER_NET_GHIINT1MSK,
-			     SPIDER_NET_INT1_MASK_VALUE);
-	spider_net_write_reg(card, SPIDER_NET_GHIINT2MSK,
-			     SPIDER_NET_INT2_MASK_VALUE);
-
 	spider_net_write_reg(card, SPIDER_NET_GDTDMACCNTR,
 			     SPIDER_NET_GDTBSTA);
 }
@@ -2007,6 +2040,8 @@ spider_net_open(struct net_device *netdev)
 	netif_carrier_on(netdev);
 	netif_poll_enable(netdev);
 
+	spider_net_enable_interrupts(card);
+
 	return 0;
 
 register_int_failed:
@@ -2179,11 +2214,7 @@ spider_net_stop(struct net_device *netdev)
 	del_timer_sync(&card->tx_timer);
 	del_timer_sync(&card->aneg_timer);
 
-	/* disable/mask all interrupts */
-	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK, 0);
-	spider_net_write_reg(card, SPIDER_NET_GHIINT1MSK, 0);
-	spider_net_write_reg(card, SPIDER_NET_GHIINT2MSK, 0);
-	spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0);
+	spider_net_disable_interrupts(card);
 
 	free_irq(netdev->irq, netdev);
 
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 51c3fe2..15146a1 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2625,7 +2625,7 @@ static void quattro_sbus_free_irqs(void)
 #endif /* CONFIG_SBUS */
 
 #ifdef CONFIG_PCI
-static struct quattro * __init quattro_pci_find(struct pci_dev *pdev)
+static struct quattro * __devinit quattro_pci_find(struct pci_dev *pdev)
 {
 	struct pci_dev *bdev = pdev->bus->self;
 	struct quattro *qp;
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index e22a3f5..9f1b6ab 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -363,7 +363,7 @@ static int __devinit xl_probe(struct pci_dev *pdev,
 }
 
 
-static int __init xl_init(struct net_device *dev) 
+static int __devinit xl_init(struct net_device *dev) 
 {
     	struct xl_private *xl_priv = (struct xl_private *)dev->priv ;
 
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 18b731b..e4736a3 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2276,7 +2276,7 @@ static void ucc_geth_stop(struct ucc_geth_private *ugeth)
 	phy_stop(phydev);
 
 	/* Mask all interrupts */
-	out_be32(ugeth->uccf->p_ucce, 0x00000000);
+	out_be32(ugeth->uccf->p_uccm, 0x00000000);
 
 	/* Clear all interrupts */
 	out_be32(ugeth->uccf->p_ucce, 0xffffffff);
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 86b6908..37bf4f2 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1213,7 +1213,7 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 			status = 0;
 
 	}
-	if (status == 0 && dev->status)
+	if (status >= 0 && dev->status)
 		status = init_status (dev, udev);
 	if (status < 0)
 		goto out3;
diff --git a/include/net/ax88796.h b/include/net/ax88796.h
new file mode 100644
index 0000000..ee786a0
--- /dev/null
+++ b/include/net/ax88796.h
@@ -0,0 +1,27 @@
+/* include/net/ax88796.h
+ *
+ * Copyright 2005 Simtec Electronics
+ *	Ben Dooks <ben@simtec.co.uk>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+*/
+
+#ifndef __NET_AX88796_PLAT_H
+#define __NET_AX88796_PLAT_H
+
+#define AXFLG_HAS_EEPROM		(1<<0)
+#define AXFLG_MAC_FROMDEV		(1<<1)	/* device already has MAC */
+
+struct ax_plat_data {
+	unsigned int	 flags;
+	unsigned char	 wordlength;		/* 1 or 2 */
+	unsigned char	 dcr_val;		/* default value for DCR */
+	unsigned char	 rcr_val;		/* default value for RCR */
+	unsigned char	 gpoc_val;		/* default value for GPOC */
+	u32		*reg_offsets;		/* register offsets */
+};
+
+#endif /* __NET_AX88796_PLAT_H */
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f96ed76..79b79f3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2268,6 +2268,9 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 		break;
 	case NETDEV_UP:
 	case NETDEV_CHANGE:
+		if (dev->flags & IFF_SLAVE)
+			break;
+
 		if (event == NETDEV_UP) {
 			if (!netif_carrier_ok(dev)) {
 				/* device is not ready yet. */
