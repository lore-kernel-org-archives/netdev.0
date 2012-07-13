From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] ax25: Fix missing break
Date: Fri, 13 Jul 2012 17:33:08 +0100
Message-ID: <20120713163247.22674.82793.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:33480 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756667Ab2GMQQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 12:16:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>

At least there seems to be no reason to disallow ROSE sockets when
NETROM is loaded.

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 net/ax25/af_ax25.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 051f7ab..779095d 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -842,6 +842,7 @@ static int ax25_create(struct net *net, struct socket *sock, int protocol,
 		case AX25_P_NETROM:
 			if (ax25_protocol_is_registered(AX25_P_NETROM))
 				return -ESOCKTNOSUPPORT;
+			break;
 #endif
 #ifdef CONFIG_ROSE_MODULE
 		case AX25_P_ROSE:
