From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/2] net: sctp: minor: make jsctp_sf_eat_sack static
Date: Wed, 13 Feb 2013 12:03:49 +0100
Message-ID: <7eef4b701794c1bb78819bc6e6c45bf99b49801d.1360752304.git.dborkman@redhat.com>
References: <cover.1360752304.git.dborkman@redhat.com>
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34613 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932451Ab3BMLDy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2013 06:03:54 -0500
In-Reply-To: <cover.1360752304.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function jsctp_sf_eat_sack can be made static, no need to extend
its visibility.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/probe.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sctp/probe.c b/net/sctp/probe.c
index 5f7518d..4eaaaf6 100644
--- a/net/sctp/probe.c
+++ b/net/sctp/probe.c
@@ -122,12 +122,12 @@ static const struct file_operations sctpprobe_fops = {
 	.llseek = noop_llseek,
 };
 
-sctp_disposition_t jsctp_sf_eat_sack(struct net *net,
-				     const struct sctp_endpoint *ep,
-				     const struct sctp_association *asoc,
-				     const sctp_subtype_t type,
-				     void *arg,
-				     sctp_cmd_seq_t *commands)
+static sctp_disposition_t jsctp_sf_eat_sack(struct net *net,
+					    const struct sctp_endpoint *ep,
+					    const struct sctp_association *asoc,
+					    const sctp_subtype_t type,
+					    void *arg,
+					    sctp_cmd_seq_t *commands)
 {
 	struct sctp_transport *sp;
 	static __u32 lcwnd = 0;
-- 
1.7.11.7
