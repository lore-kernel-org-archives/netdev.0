From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 04/16] tipc: Eliminate unnecessary initialization in native API send routines
Date: Tue, 11 May 2010 20:30:06 -0400
Message-ID: <57c657804abd07f01ab7dec918db11f4a905c7f6.1273621271.git.paul.gortmaker@windriver.com>
References: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35222 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366Ab0ELAa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 20:30:27 -0400
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id o4C0UQh0000096
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 17:30:26 -0700 (PDT)
In-Reply-To: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
References: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminate a couple of instances where TIPC's native API send routines
were doing pointless initialization of local variables.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index c703ecb..7641db6 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -1452,7 +1452,7 @@ int tipc_forward2name(u32 ref,
 	struct port *p_ptr;
 	struct tipc_msg *msg;
 	u32 destnode = domain;
-	u32 destport = 0;
+	u32 destport;
 	int res;
 
 	p_ptr = tipc_port_deref(ref);
@@ -1524,7 +1524,7 @@ int tipc_forward_buf2name(u32 ref,
 	struct port *p_ptr;
 	struct tipc_msg *msg;
 	u32 destnode = domain;
-	u32 destport = 0;
+	u32 destport;
 	int res;
 
 	p_ptr = (struct port *)tipc_ref_deref(ref);
-- 
1.7.1.rc2

