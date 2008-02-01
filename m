From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] add if_addrlabel.h to sanitized headers
Date: Thu, 31 Jan 2008 22:37:31 -0800
Message-ID: <20080131223731.78bc6bef@extreme>
References: <20080128.210222.07062540.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:34224 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751260AbYBAGhd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 01:37:33 -0500
In-Reply-To: <20080128.210222.07062540.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if_addrlabel.h is needed for iproute2 usage.

Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>
---
 include/linux/Kbuild |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 85b2482..ce9d0fd 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -218,6 +218,7 @@ unifdef-y += i2c-dev.h
 unifdef-y += icmp.h
 unifdef-y += icmpv6.h
 unifdef-y += if_addr.h
+unifdef-y += if_addrlabel.h
 unifdef-y += if_arp.h
 unifdef-y += if_bridge.h
 unifdef-y += if_ec.h
-- 
1.5.3.8

