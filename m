From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] tc_act: export uapi header file
Date: Wed, 3 Dec 2014 09:33:17 -0800
Message-ID: <20141203093317.3c482872@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:63697 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751173AbaLCRd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 12:33:27 -0500
Received: by mail-pa0-f46.google.com with SMTP id lj1so16080594pab.19
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 09:33:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This file is used by iproute2 and should be exported.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/include/uapi/linux/tc_act/Kbuild	2014-02-12 08:21:56.614859066 -0800
+++ b/include/uapi/linux/tc_act/Kbuild	2014-12-03 09:31:10.619225148 -0800
@@ -7,3 +7,4 @@ header-y += tc_mirred.h
 header-y += tc_nat.h
 header-y += tc_pedit.h
 header-y += tc_skbedit.h
+header-y += tc_vlan.h
