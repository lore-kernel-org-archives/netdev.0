From: Rainer Baumann <baumann@tik.ee.ethz.ch>
Subject: [PATCH 2.6.16.19 2/2] LARTC: trace control for netem: kernelspace
Date: Wed, 02 Aug 2006 19:21:56 +0200
Message-ID: <44D0DF34.4020405@tik.ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>, netdev@VGER.KERNEL.ORG
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Trace Control for Netem: Emulate network properties such as
long-dependency and self-similarity of cross-traffic.

The delay, drop, duplication and corruption values are readout in user
space and sent to kernel space via procfs.
The kernel determines the time when new values should be sent by the use
of SIGSTOP and SIGCONT signals.
In order to have always packet action values ready to apply, there are
two buffers that hold these values.
Packet action values can be read from one buffer and the other buffer
can be refilled with new values simultaneously.
If a buffer is empty it will be switched to the other buffer and a
SIGCONT signal is sent in order to receive new packet action values.

Having applied the delay value to a packet, the packet gets processed by
the original netem functions.

Signed-off-by: Rainer Baumann <baumann@tik.ee.ethz.ch>

---

Patch for linux kernel 2.6.16.19: http://tcn.hypert.net/tcnKernel.patch



