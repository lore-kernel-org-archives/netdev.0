From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6 0/14] e1000: driver update
Date: Thu, 6 Jan 2005 17:20:49 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061520290.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

1 ITR does not default correctly on 2.6.x kernels
2 Fix kernel panic when the interface is brought down while the NAPI enabled driver is under stress
3 Fix ethtool diagnostics -- specifically for blade server implementations
4 Enabling NETIF_F_SG without checksum offload is illegal -- jdmason@us.ibm.com
5 Avoid filling tx_ring completely - shemminger@osdl.org
6 Apply patch from Jamal (hadi@znyx.com) to remove a redundant assignment to a local nr_frags in e1000_xmit_frame.
7 Replace schedule_timeout() with msleep()/msleep_interruptible() nacc@us.ibm.com
8 Fix tx resource cleanup logic
9 {set, get}_wol is now symmetric for 82545EM adapters
10 Kernel API change for Module_param_array_named
11 Added workaround to prevent inadvertent gigabit waveform to be sent out on the wire due to init-time operations on the IGP phy.
12 Applied eeprom fix where it was possible to read/write one more word than what should have been possible.
13 Applied smart speed fix where the code was forcing smart speed on all the time.  Now it will honor the setting defined in the eeprom.
14 Driver version number, white spaces, comments, device id & other changes
