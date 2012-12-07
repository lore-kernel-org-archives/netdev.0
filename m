From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: doc: add default value for neighbour
 parameters
Date: Fri, 07 Dec 2012 10:27:51 +0800
Message-ID: <50C15427.9060803@gmail.com>
References: <50BED29B.4050805@gmail.com>  <1354758235.17107.131.camel@deadeye.wl.decadent.org.uk>  <50C009E9.6050101@gmail.com> <1354825223.2828.17.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	NetDev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:49722 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422821Ab2LGC2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 21:28:01 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so9540dak.19
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2012 18:28:01 -0800 (PST)
In-Reply-To: <1354825223.2828.17.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings said, at 2012/12/7 4:20:
> 'Secluded' is a fine word but your dictionary should have said that i=
t
> is used to describe places, not events.  You're quite right that this=
 is
> not silent, though.  So a word like 'hidden', 'quiet', 'non-obvious' =
or
> 'unexpected' would be more appropriate.

You are right=EF=BC=8Cgood suggestion :-).
Thanks for your review.

-------------------------
[PATCH net-next] net: doc : use more suitable word 'unexpected' to repl=
ace 'secluded'

 'secluded' is used to describe places, not suitable here.

Suggested-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Shan Wei <davidshan@tencent.com>
---
 Documentation/networking/ip-sysctl.txt |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/net=
working/ip-sysctl.txt
index 0462a71..1b830ca 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -44,7 +44,7 @@ neigh/default/unres_qlen - INTEGER
 	unresolved address by other network layers.
 	(deprecated in linux 3.3) : use unres_qlen_bytes instead.
 	Prior to linux 3.3, the default value is 3 which may cause
-	secluded packet loss. The current default value is calculated
+	unexpected packet loss. The current default value is calculated
 	according to default value of unres_qlen_bytes and true size of
 	packet.
 	Default: 31
--=20
1.7.1
