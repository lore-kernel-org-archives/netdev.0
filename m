From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.4 0/13] e1000: driver update
Date: Thu, 6 Jan 2005 17:20:44 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061433200.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

1 ITR does not default correctly on 2.4.x kernels
2 Fix for kernel panic when the interface is brought down while the NAPI 
enabled driver is under stress
3 Fix ethtool diagnostics -- specifically for blade server implementations
4 Enabling NETIF_F_SG without checksum offload is illegal -- jdmason@us.ibm.com
5 Apply patch from Jamal (hadi@znyx.com) to remove a redundant assignment to a local nr_frags in e1000_xmit_frame.
6 Synchronizing multicast table setup with transmit path - ak@suse.de
7 fix tx resource cleanup logic
8 {set, get}_wol is now symmetric for 82545EM adapters
9 Sparse cleanup - shemminger@osdl.org
10 Added workaround to prevent inadvertent gigabit waveform to be sent out on the wire due to init-time operations on the IGP phy.
11 Applied eeprom fix where it was possible to read/write one more word than what should have been possible.
12 Applied smart speed fix where the code was forcing smart speed on all the time.  Now it will honor the setting defined in the eeprom.
13 Driver version number, white spaces, comments, device id & other changes
