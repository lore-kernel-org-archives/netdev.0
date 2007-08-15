From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [IPv6]: Invalid semicolon after if statement
Date: Thu, 16 Aug 2007 00:57:00 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0708151509520.15670@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1965966608-1187180594=:15670"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55423 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090AbXHOV5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 17:57:03 -0400
Content-ID: <Pine.LNX.4.64.0708160055260.21858@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1965966608-1187180594=:15670
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0708160055261.21858@kivilampi-30.cs.helsinki.fi>


A similar fix to netfilter from Eric Dumazet inspired me to
look around a bit by using some grep/sed stuff as looking for
this kind of bugs seemed easy to automate. This is one of them
I found where it looks like this semicolon is not valid.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv6/ipv6_sockglue.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index d684639..761a910 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -820,7 +820,7 @@ static int ipv6_getsockopt_sticky(struct sock *sk, struct ipv6_txoptions *opt,
 		return 0;
 
 	len = min_t(unsigned int, len, ipv6_optlen(hdr));
-	if (copy_to_user(optval, hdr, len));
+	if (copy_to_user(optval, hdr, len))
 		return -EFAULT;
 	return ipv6_optlen(hdr);
 }
-- 
1.5.0.6
---696243703-1965966608-1187180594=:15670--
