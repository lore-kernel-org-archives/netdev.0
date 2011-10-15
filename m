From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net-next [PATCH 1/1] ipv4: compat_ioctl is local to af_inet.c,
 make it static
Date: Sat, 15 Oct 2011 13:26:56 -0600
Message-ID: <20111015192656.GA4066@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:44956 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754610Ab1JOT1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Oct 2011 15:27:07 -0400
Received: from laptev.erg.abdn.ac.uk (Debian-exim@ra-gerrit.erg.abdn.ac.uk [139.133.204.38])
	by erg.abdn.ac.uk (8.13.4/8.13.4) with ESMTP id p9FJQuWh023385
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sat, 15 Oct 2011 20:27:00 +0100 (BST)
Received: from gerrit by laptev.erg.abdn.ac.uk with local (Exim 4.72)
	(envelope-from <gerrit@laptev.erg.abdn.ac.uk>)
	id 1RF9sm-000148-L5
	for netdev@vger.kernel.org; Sat, 15 Oct 2011 13:26:56 -0600
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv4: compat_ioctl is local to af_inet.c, make it static

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/ipv4/af_inet.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -893,7 +893,7 @@ int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 EXPORT_SYMBOL(inet_ioctl);
 
 #ifdef CONFIG_COMPAT
-int inet_compat_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+static int inet_compat_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
 	int err = -ENOIOCTLCMD;
