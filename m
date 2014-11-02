From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] uapi: add missing network related headers to kbuild
Date: Sun, 2 Nov 2014 11:31:41 -0800
Message-ID: <20141102113141.7aa1065c@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:48818 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254AbaKBTbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2014 14:31:53 -0500
Received: by mail-pd0-f170.google.com with SMTP id z10so10260595pdj.15
        for <netdev@vger.kernel.org>; Sun, 02 Nov 2014 11:31:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The makefile for sanitizing kernel headers uses the kbuild file
to determine which files to do. Several networking related headers
were missing. Without these headers iproute2 build would break.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/include/uapi/linux/Kbuild	2014-11-02 11:18:59.918650081 -0800
+++ b/include/uapi/linux/Kbuild	2014-11-02 11:24:32.304658688 -0800
@@ -125,6 +125,7 @@ header-y += filter.h
 header-y += firewire-cdev.h
 header-y += firewire-constants.h
 header-y += flat.h
+header-y += fou.h
 header-y += fs.h
 header-y += fsl_hypervisor.h
 header-y += fuse.h
@@ -141,6 +142,7 @@ header-y += hid.h
 header-y += hiddev.h
 header-y += hidraw.h
 header-y += hpet.h
+header-y += hsr_netlink.h
 header-y += hyperv.h
 header-y += hysdn_if.h
 header-y += i2c-dev.h
@@ -251,6 +253,7 @@ header-y += mii.h
 header-y += minix_fs.h
 header-y += mman.h
 header-y += mmtimer.h
+header-y += mpls.h
 header-y += mqueue.h
 header-y += mroute.h
 header-y += mroute6.h
@@ -424,6 +427,7 @@ header-y += virtio_net.h
 header-y += virtio_pci.h
 header-y += virtio_ring.h
 header-y += virtio_rng.h
+header=y += vm_sockets.h
 header-y += vt.h
 header-y += wait.h
 header-y += wanrouter.h
