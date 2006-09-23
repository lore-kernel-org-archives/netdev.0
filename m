From: Rainer Baumann <baumann@tik.ee.ethz.ch>
Subject: [PATCH 2.6.17.13 2/2] LARTC: trace control for netem: kernelspace
Date: Sat, 23 Sep 2006 09:04:58 +0200
Message-ID: <4514DC9A.2000505@tik.ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>, netdev@VGER.KERNEL.ORG,
	netem@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Trace Control for Netem: Emulate network properties such as long range dependency and self-similarity of cross-traffic.

kernel space:
The delay, drop, duplication and corruption values are readout in user space and sent to kernel space via configfs. The userspace process will "hang on write" until the kernel needs new data.

In order to have always packet action values ready to apply, there are two buffers that hold these values. Packet action values can be read from one buffer and the other buffer can be refilled with new values simultaneously. The synchronization of "need more delay values" and "return from write" is done with the use of wait queues.

Having applied the delay value to a packet, the packet gets processed by the original netem functions.

Signed-off-by: Rainer Baumann <baumann@tik.ee.ethz.ch>

---

Patch for linux kernel 2.6.17.13: http://tcn.hypert.net/tcn_kernel_configfs.patch







