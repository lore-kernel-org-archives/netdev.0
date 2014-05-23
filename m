From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/3] net: sysfs: document /sys/class/net/statistics/*
Date: Fri, 23 May 2014 16:35:42 -0700
Message-ID: <1400888142-5963-4-git-send-email-f.fainelli@gmail.com>
References: <1400888142-5963-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, therbert@google.com, edumazet@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:37228 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbaEWXf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 19:35:56 -0400
Received: by mail-pa0-f54.google.com with SMTP id bj1so4778969pad.27
        for <netdev@vger.kernel.org>; Fri, 23 May 2014 16:35:55 -0700 (PDT)
In-Reply-To: <1400888142-5963-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Document the network device statistics counter that are exposed as sysfs
attributes.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 .../ABI/testing/sysfs-class-net-statistics         | 202 +++++++++++++++++++++
 1 file changed, 202 insertions(+)
 create mode 100644 Documentation/ABI/testing/sysfs-class-net-statistics

diff --git a/Documentation/ABI/testing/sysfs-class-net-statistics b/Documentation/ABI/testing/sysfs-class-net-statistics
new file mode 100644
index 000000000000..2f05e793dc32
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-class-net-statistics
@@ -0,0 +1,202 @@
+What:		/sys/class/<iface>/statistics/collisions
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of collisions seen by this network device.
+		This value might not be relevant with all MAC layers.
+
+What:		/sys/class/<iface>/statistics/multicast
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of multicast packets received by this
+		network device.
+
+What:		/sys/class/<iface>/statistics/rx_bytes
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of bytes received by this network device.
+		See the network driver for the exact meaning of when this
+		value is incremented.
+
+What:		/sys/class/<iface>/statistics/rx_compressed
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of compressed packets received by this
+		network device. This value might only be relevant for interfaces
+		that support packet compression (e.g: PPP).
+
+What:		/sys/class/<iface>/statistics/rx_crc_errors
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of packets received with a CRC (FCS) error
+		by this network device. Note that the specific meaning might
+		depend on the MAC layer used by the interface.
+
+What:		/sys/class/<iface>/statistics/rx_dropped
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of packets received by the network device
+		but dropped, that are not forwarded to the upper layers for
+		packet processing. See the network driver for the exact
+		meaning of this value.
+
+What:		/sys/class/<iface>/statistics/rx_fifo_errors
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of receive FIFO errors seen by this
+		network device. See the network driver for the exact
+		meaning of this value.
+
+What:		/sys/class/<iface>/statistics/rx_frame_errors
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of received frames with error, such as
+		alignment errors. Note that the specific meaning depends on
+		on the MAC layer protocol used. See the network driver for
+		the exact meaning of this value.
+
+What:		/sys/class/<iface>/statistics/rx_length_errors
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of received error packet with a length
+		error, oversized or undersized. See the network driver for the
+		exact meaning of this value.
+
+What:		/sys/class/<iface>/statistics/rx_missed_errors
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of received packets that have been missed
+		due to lack of capacity in the receive side. See the network
+		driver for the exact meaning of this value.
+
+What:		/sys/class/<iface>/statistics/rx_over_errors
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of received packets that are oversized
+		compared to what the network device is configured to accept
+		(e.g: larger than MTU). See the network driver for the exact
+		meaning of this value.
+
+What:		/sys/class/<iface>/statistics/rx_packets
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the total number of good packets received by this
+		network device.
+
+What:		/sys/class/<iface>/statistics/tx_aborted_errors
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of packets that have been aborted
+		during transmission by a network device (e.g: because of
+		a medium collision). See the network driver for the exact
+		meaning of this value.
+
+What:		/sys/class/<iface>/statistics/tx_bytes
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of bytes transmitted by a network
+		device. See the network driver for the exact meaning of this
+		value, in particular whether this accounts for all successfully
+		transmitted packets or all packets that have been queued for
+		transmission.
+
+What:		/sys/class/<iface>/statistics/tx_carrier_errors
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of packets that could not be transmitted
+		because of carrier errors (e.g: physical link down). See the
+		network driver for the exact meaning of this value.
+
+What:		/sys/class/<iface>/statistics/tx_compressed
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of transmitted compressed packets. Note
+		this might only be relevant for devices that support
+		compression (e.g: PPP).
+
+What:		/sys/class/<iface>/statistics/tx_dropped
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of packets dropped during transmission.
+		See the driver for the exact reasons as to why the packets were
+		dropped.
+
+What:		/sys/class/<iface>/statistics/tx_errors
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of packets in error during transmission by
+		a network device. See the driver for the exact reasons as to
+		why the packets were dropped.
+
+What:		/sys/class/<iface>/statistics/tx_fifo_errors
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of packets having caused a transmit
+		FIFO error. See the driver for the exact reasons as to why the
+		packets were dropped.
+
+What:		/sys/class/<iface>/statistics/tx_heartbeat_errors
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of packets transmitted that have been
+		reported as heartbeat errors. See the driver for the exact
+		reasons as to why the packets were dropped.
+
+What:		/sys/class/<iface>/statistics/tx_packets
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of packets transmitted by a network
+		device. See the driver for whether this reports the number of all
+		attempted or successful transmissions.
+
+What:		/sys/class/<iface>/statistics/tx_window_errors
+Date:		April 2005
+KernelVersion:	2.6.12
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of packets not successfully transmitted
+		due to a window collision. The specific meaning depends on the
+		MAC layer used.  On Ethernet this is usually used to report
+		late collisions errors.
+
-- 
1.9.1
