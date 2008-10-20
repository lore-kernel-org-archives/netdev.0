From: Oliver Neukum <oliver@neukum.org>
Subject: r8169 temporary failure to read mac from rom
Date: Mon, 20 Oct 2008 15:06:05 +0200
Message-ID: <200810201506.06382.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:36426 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbYJTNGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 09:06:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

with today's git r8169 failed to read MAC from rom

r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:06:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
r8169 0000:06:00.0: setting latency timer to 64
eth0: RTL8168b/8111b at 0xffffc20000352000, 00:00:00:00:00:00, XID 38000000 IRQ 4346

This persisted until power was physically cut. The system is x86_64,
ftrace is not enabled.

	Regards
		Oliver
