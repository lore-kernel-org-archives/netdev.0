From: Rainer Baumann <baumann@tik.ee.ethz.ch>
Subject: [PATCH 2.6.16.19 0/2] LARTC: trace control for netem
Date: Wed, 02 Aug 2006 19:21:27 +0200
Message-ID: <44D0DF17.6060809@tik.ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>, netdev@VGER.KERNEL.ORG
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

We developed an extension to the network emulator netem, that provides
emulation of long term network properties such as long-range dependence
and self-similarity of cross-traffic. It is not possible to emulate
these properties with the  statistical tables for the packet delay
values used by the original netem.

We read the values for the packet delay, drop, loss and corruption from
a pre-generated trace file. This trace file is obtained by monitoring
network traffic and writing all actions to a trace file. During the
emulation the packets get processed according the values in such a trace
file. Detailed information are available on our
Webseitehttp://tcn.hypert.net

A new option (trace) has been added to the netem command. If the trace
option is used, the values for packet delay etc. are read from a trace
file, afterwards the packets are processed by the normal netem functions.
The packet action values are readout from the trace file in user space
and sent to kernel space via procfs.

The evaluation results show similar behavior for our enhancement and the
original netem with respect to packet delay precision and packet loss at
high load (e.g. 80'000 packets per second).
It is possible to add, change or delete multiple netem qdiscs on-the-fly
(original netem qdiscs and trace qdiscs mixed).

We are looking forward for any comments, feedback and suggestions!

Thanks,
Rainer



