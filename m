From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next] net: remove needless (now buggy) & from
	dev->dev_addr (part2)
Date: Wed, 13 May 2009 10:40:12 +0200
Message-ID: <20090513084011.GC3517@psychotron.englab.brq.redhat.com>
References: <20090512093714.GD3399@psychotron.englab.brq.redhat.com> <4A0A2059.8040607@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, sfr@canb.auug.org.au, sachinp@in.ibm.com,
	Wei Yongjun <yjwei@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:44840 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750860AbZEMIkY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 04:40:24 -0400
Content-Disposition: inline
In-Reply-To: <4A0A2059.8040607@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Missed part of "&" removal.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index febae70..9208cf5 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -935,7 +935,7 @@ static int llc_ui_getname(struct socket *sock, struct sockaddr *uaddr,
 
 		if (llc->dev) {
 			sllc.sllc_arphrd = llc->dev->type;
-			memcpy(&sllc.sllc_mac, &llc->dev->dev_addr,
+			memcpy(&sllc.sllc_mac, llc->dev->dev_addr,
 			       IFHWADDRLEN);
 		}
 	}
