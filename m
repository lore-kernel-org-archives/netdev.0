From: Rainer Baumann <baumann@tik.ee.ethz.ch>
Subject: [PATCH 2.6.18 0/2] LARTC: trace control for netem
Date: Fri, 15 Dec 2006 11:39:24 +0100
Message-ID: <45827B5C.3090402@tik.ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>, netdev@VGER.KERNEL.ORG,
	netem@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen

As discussed yesterday, here our patches to integrate trace control into netem



Trace Control for Netem: Emulate network properties such as long range dependency and self-similarity of cross-traffic.

A new option (trace) has been added to the netem command. If the trace option is used, the values for packet delay etc. are read from a pregenerated trace file, afterwards the packets are processed by the normal netem functions. The packet action values are readout from the trace file in user space and sent to kernel space via configfs.







