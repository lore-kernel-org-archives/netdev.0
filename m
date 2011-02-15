From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: [RFC, PATCH 0/4] net: sh_eth: modify for both modules
Date: Tue, 15 Feb 2011 20:47:20 +0900
Message-ID: <4D5A67C8.3010908@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor4.renesas.com ([210.160.252.174]:39431 "EHLO
	relmlor4.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754690Ab1BOLr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 06:47:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This current driver supports ETHER and GETHER. But we cannot
use them at same time because the defination of registers is
hardcoded by #ifdef in sh_eth.h.
The patches modify the defination to arrays of const. Then
we can choose the array by platform_device's data.
The patches also modify for GETHER. The current driver used
the "#ifdef CONFIG_CPU_SUBTYPE_SH7763". The patches remove it
and check by other method for GETHER.
