From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/3] net: sysfs: add documentation entries for /sys/class/<iface>/queues
Date: Fri, 23 May 2014 16:35:41 -0700
Message-ID: <1400888142-5963-3-git-send-email-f.fainelli@gmail.com>
References: <1400888142-5963-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, therbert@google.com, edumazet@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:56926 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbaEWXfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 19:35:55 -0400
Received: by mail-pb0-f48.google.com with SMTP id rr13so4807746pbb.35
        for <netdev@vger.kernel.org>; Fri, 23 May 2014 16:35:54 -0700 (PDT)
In-Reply-To: <1400888142-5963-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add sysfs documentation for the various attributes of a network
interface exposed in /sys/class/<iface>/queues/{rx,tx}-<queue>/

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/ABI/testing/sysfs-class-net-queues | 79 ++++++++++++++++++++++++
 1 file changed, 79 insertions(+)
 create mode 100644 Documentation/ABI/testing/sysfs-class-net-queues

diff --git a/Documentation/ABI/testing/sysfs-class-net-queues b/Documentation/ABI/testing/sysfs-class-net-queues
new file mode 100644
index 000000000000..5e9aeb91d355
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-class-net-queues
@@ -0,0 +1,79 @@
+What:		/sys/class/<iface>/queues/rx-<queue>/rps_cpus
+Date:		March 2010
+KernelVersion:	2.6.35
+Contact:	netdev@vger.kernel.org
+Description:
+		Mask of the CPU(s) currently enabled to participate into the
+		Receive Packet Steering packet processing flow for this
+		network device queue. Possible values depend on the number
+		of available CPU(s) in the system.
+
+What:		/sys/class/<iface>/queues/rx-<queue>/rps_flow_cnt
+Date:		April 2010
+KernelVersion:	2.6.35
+Contact:	netdev@vger.kernel.org
+Description:
+		Number of Receive Packet Steering flows being currently
+		processed by this particular network device receive queue.
+
+What:		/sys/class/<iface>/queues/tx-<queue>/tx_timeout
+Date:		November 2011
+KernelVersion:	3.3
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of transmit timeout events seen by this
+		network interface transmit queue.
+
+What:		/sys/class/<iface>/queues/tx-<queue>/xps_cpus
+Date:		November 2010
+KernelVersion:	2.6.38
+Contact:	netdev@vger.kernel.org
+Description:
+		Mask of the CPU(s) currently enabled to participate into the
+		Transmit Packet Steering packet processing flow for this
+		network device transmit queue. Possible vaules depend on the
+		number of available CPU(s) in the system.
+
+What:		/sys/class/<iface>/queues/tx-<queue>/byte_queue_limits/hold_time
+Date:		November 2011
+KernelVersion:	3.3
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the hold time in milliseconds to measure the slack
+		of this particular network device transmit queue.
+		Default value is 1000.
+
+What:		/sys/class/<iface>/queues/tx-<queue>/byte_queue_limits/inflight
+Date:		November 2011
+KernelVersion:	3.3
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the number of bytes (objects) in flight on this
+		network device transmit queue.
+
+What:		/sys/class/<iface>/queues/tx-<queue>/byte_queue_limits/limit
+Date:		November 2011
+KernelVersion:	3.3
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the current limit of bytes allowed to be queued
+		on this network device transmit queue. This value is clamped
+		to be within the bounds defined by limit_max and limit_min.
+
+What:		/sys/class/<iface>/queues/tx-<queue>/byte_queue_limits/limit_max
+Date:		November 2011
+KernelVersion:	3.3
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the absolute maximum limit of bytes allowed to be
+		queued on this network device transmit queue. See
+		include/linux/dynamic_queue_limits.h for the default value.
+
+What:		/sys/class/<iface>/queues/tx-<queue>/byte_queue_limits/limit_min
+Date:		November 2011
+KernelVersion:	3.3
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the absolute minimum limit of bytes allowed to be
+		queued on this network device transmit queue. Default value is
+		0.
-- 
1.9.1
