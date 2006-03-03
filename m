From: Chris Leech <christopher.leech@intel.com>
Subject: [PATCH 0/8] Intel I/O Acceleration Technology (I/OAT)
Date: Fri, 03 Mar 2006 13:40:36 -0800
Message-ID: <20060303214036.11908.10499.stgit@gitlost.site>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751517AbWCCVkR@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series is the first full release of the Intel(R) I/O
Acceleration Technology (I/OAT) for Linux.  It includes an in kernel API
for offloading memory copies to hardware, a driver for the I/OAT DMA memcpy
engine, and changes to the TCP stack to offload copies of received
networking data to application space.

These changes apply to DaveM's net-2.6.17 tree as of commit
2bd84a93d8bb7192ad8c23ef41008502be1cb603 ([IRDA]: TOIM3232 dongle support)

They are available to pull from
	git://198.78.49.142/~cleech/linux-2.6 ioat-2.6.17

There are 8 patches in the series:
	1) The memcpy offload APIs and class code
	2) The Intel I/OAT DMA driver (ioatdma)
	3) Core networking code to setup networking as a DMA memcpy client
	4) Utility functions for sk_buff to iovec offloaded copy
	5) Structure changes needed for TCP receive offload
	6) Rename cleanup_rbuf to tcp_cleanup_rbuf
	7) Add a sysctl to tune the minimum offloaded I/O size for TCP
	8) The main TCP receive offload changes

--
Chris Leech <christopher.leech@intel.com>
I/O Acceleration Technology Software Development
LAN Access Division / Digital Enterprise Group 
