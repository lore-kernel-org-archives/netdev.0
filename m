From: Viresh Kumar <viresh.kumar@st.com>
Subject: [PATCH] linux/stmmac.h: include <linux/platform_device.h> to remove compilation warning.
Date: Mon, 2 May 2011 12:00:37 +0530
Message-ID: <2239eca1d15014be7b6d94f883f9492dc1fbc60a.1304317552.git.viresh.kumar@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <shiraz.hashim@st.com>,
	<armando.visconti@st.com>, <deepak.sikri@st.com>,
	<viresh.linux@gmail.com>, Viresh Kumar <viresh.kumar@st.com>
To: <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:54492 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753667Ab1EBGaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2011 02:30:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

stmmac.h uses struct platform_device and doesn't include
<linux/platform_device.h>. And so we get following compilation warning =
while
using this file:
	warning: =E2=80=98struct platform_device=E2=80=99 declared inside para=
meter list

This patch includes <linux/platform_device.h> in stmmac.h to remove thi=
s warning

Signed-off-by: Viresh Kumar <viresh.kumar@st.com>
---
 include/linux/stmmac.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 73d9b4e..d7dfe7d 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -26,6 +26,8 @@
 #ifndef __STMMAC_PLATFORM_DATA
 #define __STMMAC_PLATFORM_DATA
=20
+#include <linux/platform_device.h>
+
 #define STMAC_TYPE_0	0
 #define STMAC_TYPE_1	1
 #define STMAC_TYPE_2	2
--=20
1.7.2.2

