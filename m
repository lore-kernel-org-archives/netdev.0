From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next 0/5] xen-netback: IPv6 offload support
Date: Tue, 8 Oct 2013 11:44:36 +0100
Message-ID: <1381229081-17814-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:27155 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756948Ab3JHKot (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Oct 2013 06:44:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for checksum and large packet offloads into
xen-netback.
Testing has mainly been done using the Microsoft network hardware
certification suite running in Server 2008R2 VMs with Citrix PV frontends.
