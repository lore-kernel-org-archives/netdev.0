From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: sysfs: add Documentation entries for basic set of attributes
Date: Fri, 28 Mar 2014 14:25:57 -0700
Message-ID: <1396041958-2471-2-git-send-email-f.fainelli@gmail.com>
References: <1396041958-2471-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:37093 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752554AbaC1V0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 17:26:14 -0400
Received: by mail-pa0-f46.google.com with SMTP id kx10so50042pab.19
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 14:26:14 -0700 (PDT)
In-Reply-To: <1396041958-2471-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add sysfs attributes Documentation entries for the basic set of
attributes that are exposed by a network device in
/sys/class/net/<iface>/

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/ABI/testing/sysfs-class-net | 199 ++++++++++++++++++++++++++++++
 1 file changed, 199 insertions(+)
 create mode 100644 Documentation/ABI/testing/sysfs-class-net

diff --git a/Documentation/ABI/testing/sysfs-class-net b/Documentation/ABI/testing/sysfs-class-net
new file mode 100644
index 000000000000..d922060e455d
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-class-net
@@ -0,0 +1,199 @@
+What:		/sys/class/net/<iface>/addr_assign_type
+Date:		July 2010
+KernelVersion:	3.2
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the address assignment type. Possible values are:
+		0: permanent address
+		1: randomly generated
+		2: stolen from another device
+		3: set using dev_set_mac_address
+
+What:		/sys/class/net/<iface>/addr_len
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the hardware address size in bytes.
+		Values vary based on the lower-level protocol used by the
+		interface (Ethernet, FDDI, ATM, IEEE 802.15.4...). See
+		include/uapi/linux/if_*.h for actual values.
+
+What:		/sys/class/net/<iface>/address
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Hardware address currently assigned to this interface.
+		Format is a string, e.g: 00:11:22:33:44:55 for an Ethernet MAC
+		address.
+
+What:		/sys/class/net/<iface>/broadcast
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Hardware broadcast address for this interface. Format is a
+		string, e.g: ff:ff:ff:ff:ff:ff for an Ethernet broadcast MAC
+		address.
+
+What:		/sys/class/net/<iface>/carrier
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the current physical link state of the interface.
+		Posssible values are:
+		0: physical link is down
+		1: physical link is up
+
+		Note: some special devices, e.g: bonding and team drivers will
+		allow this attribute to be written to force a link state for
+		operating correctly and designating another fallback interface.
+
+What:		/sys/class/net/<iface>/dev_id
+Date:		April 2008
+KernelVersion:	2.6.26
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the device unique identifier. Format is an hexadecimal
+		value. This is used to disambiguate interfaces which might be
+		stacked (e.g: VLAN interfaces) but still have the same MAC
+		address as their parent device.
+
+What:		/sys/class/net/<iface>/dormant
+Date:		March 2006
+KernelVersion:	2.6.17
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates whether the interface is in dormant state. Possible
+		values are:
+		0: interface is not dormant
+		1: interface is dormant
+
+		This attribute can be used by supplicant software to signal that
+		the device is not usable unless some supplicant-based
+		authentication is performed (e.g: 802.1x). 'link_mode' attribute
+		will also reflect the dormant state.
+
+What:		/sys/clas/net/<iface>/duplex
+Date:		October 2009
+KernelVersion:	2.6.33
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the interface latest or current duplex value. Possible
+		values are:
+		half: half duplex
+		full: full duplex
+
+		Note: This attribute is only valid for interfaces that implement
+		the ethtool get_settings method (mostly Ethernet).
+
+What:		/sys/class/net/<iface>/flags
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the interface flags as a bitmask in hexadecimal. See
+		include/uapi/linux/if.h for a list of all possible values and
+		the flags semantics.
+
+What:		/sys/class/net/<iface>/ifalias
+Date:		September 2008
+KernelVersion:	2.6.28
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates/stores an interface alias name as a string. This can
+		be used for system management purposes.
+
+What:		/sys/class/net/<iface>/ifindex
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the system-wide interface unique index identifier as a
+		decimal number. This attribute is used for mapping an interface
+		identifier to an interface name. It is used throughout the
+		networking stack for specifying the interface specific
+		requests/events.
+
+What:		/sys/class/net/<iface>/iflink
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the system-wide interface unique index identifier a
+		the interface is linked to. Format is decimal. This attribute is
+		used to resolve interfaces chaining, linking and stacking.
+		Physical interfaces have the same 'ifindex' and 'iflink' values.
+
+What:		/sys/class/net/<iface>/link_mode
+Date:		March 2006
+KernelVersion:	2.6.17
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the interface link mode, as a decimal number. This
+		attribute should be used in conjunction with 'dormant' attribute
+		to determine the interface usability. Possible values:
+		0: default link mode
+		1: dormant link mode
+
+What:		/sys/class/net/<iface>/mtu
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the interface currently configured MTU value, in
+		bytes, and in decimal format. Specific values depends on the
+		lower-level interface protocol used. Ethernet devices will show
+		a 'mtu' attribute value of 1500 unless changed.
+
+What:		/sys/calss/net/<iface>/netdev_group
+Date:		January 2011
+KernelVersion:	2.6.39
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the interface network device group, as a decimal
+		integer. Default value is 0 which corresponds to the initial
+		network devices group. The group can be changed to affect
+		routing decisions (see: net/ipv4/fib_rules and
+		net/ipv6/fib6_rules.c).
+
+What:		/sys/class/net/<iface>/operstate
+Date:		March 2006
+KernelVersion:	2.6.17
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the interface RFC2863 operational state as a string.
+		Possible values are:
+		"unknown", "notpresent", "down", "lowerlayerdown", "testing",
+		"dormant", "up".
+
+What:		/sys/class/net/<iface>/speed
+Date:		October 2009
+KernelVersion:	2.6.33
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the interface latest or current speed value. Value is
+		an integer representing the link speed in Mbits/sec.
+
+		Note: this attribute is only valid for interfaces that implement
+		the ethtool get_settings method (mostly Ethernet ).
+
+What:		/sys/class/net/<iface>/tx_queue_len
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the interface transmit queue len in number of packets,
+		as an integer value. Value depend on the type of interface,
+		Ethernet network adapters have a default value of 1000 unless
+		configured otherwise
+
+What:		/sys/class/net/<iface>/type
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the interface protocol type as a decimal value. See
+		include/uapi/linux/if_arp.h for all possible values.
-- 
1.8.3.2
