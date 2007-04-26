From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][XFRM] export SAD info
Date: Thu, 26 Apr 2007 08:55:54 -0400
Message-ID: <1177592154.4077.2.camel@localhost>
References: <1177515761.9923.3.camel@localhost>
	 <20070426.001050.97294686.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-/1iDFpApc/2RDHlklj+R"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.224]:42775 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031217AbXDZMz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 08:55:58 -0400
Received: by wx-out-0506.google.com with SMTP id h31so569136wxd
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2007 05:55:57 -0700 (PDT)
In-Reply-To: <20070426.001050.97294686.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-/1iDFpApc/2RDHlklj+R
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Thanks Dave.
Here's a missing bit to get in sync with latest net-2.6

I will send you the policy side sometime tonight or tommorow.

cheers,
jamal

--=-/1iDFpApc/2RDHlklj+R
Content-Disposition: attachment; filename=xfrm_sadinfo-net26
Content-Type: text/plain; name=xfrm_sadinfo-net26; charset=us-ascii
Content-Transfer-Encoding: 7bit

[XFRM] missing bits to SAD info

This brings the SAD info in sync with net-2.6.22/net-2.6

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit e1dbdd993637d14c17bc30ba55e5c66640d39907
tree fef4015f92e4e50f98e1a1630333cc59ed4ec523
parent bfbf3c0968498f5232c02965cf41695edae1bc4d
author Jamal Hadi Salim <hadi@cyberus.ca> Thu, 26 Apr 2007 08:52:29 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Thu, 26 Apr 2007 08:52:29 -0400

 net/xfrm/xfrm_user.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index cb4cc1b..69110fe 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1878,6 +1878,7 @@ static const int xfrm_msg_min[XFRM_NR_MSGTYPES] = {
 	[XFRM_MSG_GETAE       - XFRM_MSG_BASE] = XMSGSIZE(xfrm_aevent_id),
 	[XFRM_MSG_REPORT      - XFRM_MSG_BASE] = XMSGSIZE(xfrm_user_report),
 	[XFRM_MSG_MIGRATE     - XFRM_MSG_BASE] = XMSGSIZE(xfrm_userpolicy_id),
+	[XFRM_MSG_GETSADINFO  - XFRM_MSG_BASE] = NLMSG_LENGTH(sizeof(u32)),
 };
 
 #undef XMSGSIZE
@@ -1905,7 +1906,7 @@ static struct xfrm_link {
 	[XFRM_MSG_NEWAE       - XFRM_MSG_BASE] = { .doit = xfrm_new_ae  },
 	[XFRM_MSG_GETAE       - XFRM_MSG_BASE] = { .doit = xfrm_get_ae  },
 	[XFRM_MSG_MIGRATE     - XFRM_MSG_BASE] = { .doit = xfrm_do_migrate    },
-	[XFRM_MSG_GETSADINFO  - XFRM_MSG_BASE] = { .doit = xfrm_get_sadinfo    },
+	[XFRM_MSG_GETSADINFO  - XFRM_MSG_BASE] = { .doit = xfrm_get_sadinfo   },
 };
 
 static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)

--=-/1iDFpApc/2RDHlklj+R--

