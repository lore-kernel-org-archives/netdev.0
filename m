From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 11/14] replace __inline__ by inline in net/key
Date: Wed, 06 Feb 2008 10:14:16 +0100
Message-ID: <20080206092206.966898445@mai.toulouse-stg.fr.ibm.com>
References: <20080206091405.581849582@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:25083 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760776AbYBFJ2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 04:28:52 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate8.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m169SFZY029990
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:28:15 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m169SEs54685834
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:28:14 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m169SAlc026011
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:28:10 GMT
Content-Disposition: inline; filename=remove-__inline__-in-af_key.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace __inline__ by inline in net/key

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/key/af_key.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: net-2.6/net/key/af_key.c
===================================================================
--- net-2.6.orig/net/key/af_key.c
+++ net-2.6/net/key/af_key.c
@@ -92,13 +92,13 @@ static void pfkey_table_grab(void)
 	}
 }
 
-static __inline__ void pfkey_table_ungrab(void)
+static inline void pfkey_table_ungrab(void)
 {
 	write_unlock_bh(&pfkey_table_lock);
 	wake_up(&pfkey_table_wait);
 }
 
-static __inline__ void pfkey_lock_table(void)
+static inline void pfkey_lock_table(void)
 {
 	/* read_lock() synchronizes us to pfkey_table_grab */
 
@@ -107,7 +107,7 @@ static __inline__ void pfkey_lock_table(
 	read_unlock(&pfkey_table_lock);
 }
 
-static __inline__ void pfkey_unlock_table(void)
+static inline void pfkey_unlock_table(void)
 {
 	if (atomic_dec_and_test(&pfkey_table_users))
 		wake_up(&pfkey_table_wait);

-- 
