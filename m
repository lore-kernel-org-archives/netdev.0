From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] tc_act: export all user headers
Date: Fri, 22 Apr 2016 10:06:38 -0700
Message-ID: <20160422100638.4f4280bf@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <hadi@mojatatu.com>,
	David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35853 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754142AbcDVRG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 13:06:27 -0400
Received: by mail-pf0-f180.google.com with SMTP id e128so42876990pfe.3
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 10:06:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The file tc_ife.h was missing from the export list.
Rather than continue to cherry-pick, just export all headers in the directory.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/include/uapi/linux/tc_act/Kbuild	2015-05-21 15:13:05.121132983 -0700
+++ b/include/uapi/linux/tc_act/Kbuild	2016-04-22 10:03:24.733449078 -0700
@@ -1,12 +1,2 @@
 # UAPI Header export list
-header-y += tc_csum.h
-header-y += tc_defact.h
-header-y += tc_gact.h
-header-y += tc_ipt.h
-header-y += tc_mirred.h
-header-y += tc_nat.h
-header-y += tc_pedit.h
-header-y += tc_skbedit.h
-header-y += tc_vlan.h
-header-y += tc_bpf.h
-header-y += tc_connmark.h
+header-y += *.h
