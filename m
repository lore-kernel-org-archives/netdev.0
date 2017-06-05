From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip: link add vxcan support
Date: Mon, 5 Jun 2017 12:28:31 -0700
Message-ID: <20170605122831.09a13387@xeon-e3>
References: <20170602170447.2913-1-socketcan@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, mkl@pengutronix.de,
        netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:36315 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751181AbdFET2k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 15:28:40 -0400
Received: by mail-pg0-f46.google.com with SMTP id a70so17442939pge.3
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 12:28:40 -0700 (PDT)
In-Reply-To: <20170602170447.2913-1-socketcan@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  2 Jun 2017 19:04:47 +0200
Oliver Hartkopp <socketcan@hartkopp.net> wrote:

> Since commit a8f820a380a2a06 ('can: add Virtual CAN Tunnel driver (vxcan)')
> for Linux 4.12 a virtual CAN tunnel driver analogue to veth is available in
> Linux.
> 
> This patch adds the ability to create vxcan device pairs.
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

Applied, with minor header cleanup so that sanitized headers are used.

diff --git a/include/linux/can/vxcan.h b/include/linux/can/vxcan.h
index ffb0b7156f7e..5b29e8a7bc27 100644
--- a/include/linux/can/vxcan.h
+++ b/include/linux/can/vxcan.h
@@ -1,5 +1,5 @@
-#ifndef _UAPI_CAN_VXCAN_H
-#define _UAPI_CAN_VXCAN_H
+#ifndef _CAN_VXCAN_H
+#define _CAN_VXCAN_H
 
 enum {
        VXCAN_INFO_UNSPEC,
