From: Andy Zhou <azhou@nicira.com>
Subject: [datapath minor fixes 1/3] datapath: avoid hard code OVS_VPORT_TYPE_GENEVE
Date: Wed,  1 Oct 2014 00:55:46 -0700
Message-ID: <1412150148-9991-2-git-send-email-azhou@nicira.com>
References: <1412150148-9991-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:40233 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750981AbaJAHyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 03:54:55 -0400
Received: by mail-pa0-f41.google.com with SMTP id eu11so355211pac.0
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 00:54:55 -0700 (PDT)
In-Reply-To: <1412150148-9991-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OVS_VPORT_TYPE_GENEVE is currently hard coded to 6. This is not
necessary since slot 5 has not been taken yet. Drop the hard
coded value to before upstreaming GENEVE support to Linux kernel.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 datapath/linux/compat/include/linux/openvswitch.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/datapath/linux/compat/include/linux/openvswitch.h b/datapath/linux/compat/include/linux/openvswitch.h
index 306ea86..5d40da5 100644
--- a/datapath/linux/compat/include/linux/openvswitch.h
+++ b/datapath/linux/compat/include/linux/openvswitch.h
@@ -222,7 +222,7 @@ enum ovs_vport_type {
 	OVS_VPORT_TYPE_INTERNAL, /* network device implemented by datapath */
 	OVS_VPORT_TYPE_GRE,	 /* GRE tunnel. */
 	OVS_VPORT_TYPE_VXLAN,    /* VXLAN tunnel */
-	OVS_VPORT_TYPE_GENEVE = 6,  /* Geneve tunnel */
+	OVS_VPORT_TYPE_GENEVE,   /* Geneve tunnel */
 	OVS_VPORT_TYPE_GRE64 = 104, /* GRE tunnel with 64-bit keys */
 	OVS_VPORT_TYPE_LISP = 105,  /* LISP tunnel */
 	__OVS_VPORT_TYPE_MAX
-- 
1.9.1
