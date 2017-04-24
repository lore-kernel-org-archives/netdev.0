From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 0/2] l2tp: add informations about l2tpeth interfaces
 in /sys
Date: Mon, 24 Apr 2017 14:16:04 +0200
Message-ID: <cover.1493035407.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:41034 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1044560AbdDXMQH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 08:16:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch #1 lets userspace retrieve the naming scheme of an l2tpeth
interface, using /sys/class/net/<iface>/name_assign_type.

Patch #2 adds the DEVTYPE field in /sys/class/net/<iface>/uevent so
that userspace can reliably know if a device is an l2tpeth interface.


Guillaume Nault (2):
  l2tp: set name_assign_type for devices created by l2tp_eth.c
  l2tp: define "l2tpeth" device type

 net/l2tp/l2tp_eth.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

-- 
2.11.0
