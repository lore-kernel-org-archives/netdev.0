From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] xfrm: export sysctl_xfrm_acq_expires
Date: Wed, 22 Aug 2007 15:42:02 -0400
Message-ID: <20070822194202.GB17694@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@coreworks.de,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2063 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758651AbXHVTrI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 15:47:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey all-
	I had noticed that an extra sysctl for xfrm had been added while back
(specifically sysctl_xfrm_acq_expires).  Unlike its related sysctl's however,
this was never exported so that out-of-tree modules could access it, and I
thought it would be a good idea if it was.  This patch handles that.

Thanks & Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 xfrm_state.c |    1 +
 1 file changed, 1 insertion(+)


diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index d4356e6..62ae5a2 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -34,6 +34,7 @@ u32 sysctl_xfrm_aevent_rseqth __read_mostly = XFRM_AE_SEQT_SIZE;
 EXPORT_SYMBOL(sysctl_xfrm_aevent_rseqth);
 
 u32 sysctl_xfrm_acq_expires __read_mostly = 30;
+EXPORT_SYMBOL(sysctl_xfrm_acq_expires);
 
 /* Each xfrm_state may be linked to two tables:
 
-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@tuxdriver.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/
