From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: add limits to ip_default_ttl
Date: Mon, 13 Dec 2010 21:43:09 +0100
Message-ID: <1292272989.2679.48.camel@edumazet-laptop>
References: <20101213.100400.39192396.davem@davemloft.net>
	 <1292270912.2679.42.camel@edumazet-laptop>
	 <20101213.121803.48496655.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38953 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754044Ab0LMUnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 15:43:14 -0500
Received: by wyb28 with SMTP id 28so6316932wyb.19
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 12:43:13 -0800 (PST)
In-Reply-To: <20101213.121803.48496655.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 13 d=C3=A9cembre 2010 =C3=A0 12:18 -0800, David Miller a =C3=A9=
crit :

> Applied, thanks Eric.


I forgot the Documentation changes as well, sorry :(

[PATCH] net: change ip_default_ttl documentation

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 Documentation/networking/ip-sysctl.txt |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/net=
working/ip-sysctl.txt
index 3c5e465..5dfb5f4 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -11,7 +11,9 @@ ip_forward - BOOLEAN
 	for routers)
=20
 ip_default_ttl - INTEGER
-	default 64
+	Default value of TTL field (Time To Live) for outgoing (but not
+	forwarded) IP packets. Should be between 1 and 255 inclusive.
+	Default: 64 (as recommended by RFC1700)
=20
 ip_no_pmtu_disc - BOOLEAN
 	Disable Path MTU Discovery.


