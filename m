From: Andreas Schwab <schwab@suse.de>
Subject: [PATCH] ip6mr: fix missing include
Date: Sat, 31 Jan 2009 12:03:16 +0100
Message-ID: <jey6wrvitn.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:33065 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751850AbZAaLDS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 06:03:18 -0500
Received: from Relay1.suse.de (relay-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id C7767446B5
	for <netdev@vger.kernel.org>; Sat, 31 Jan 2009 12:03:16 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes:

net/ipv6/ip6mr.c:368: error: implicit declaration of function =E2=80=98=
csum_ipv6_magic=E2=80=99

Signed-off-by: Andreas Schwab <schwab@suse.de>
---
 net/ipv6/ip6mr.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git i/net/ipv6/ip6mr.c w/net/ipv6/ip6mr.c
index d19a84b..e5ba15d 100644
--- i/net/ipv6/ip6mr.c
+++ w/net/ipv6/ip6mr.c
@@ -44,6 +44,7 @@
=20
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
+#include <net/ip6_checksum.h>
 #include <linux/mroute6.h>
 #include <linux/pim.h>
 #include <net/addrconf.h>

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=C3=9Fe 5, 90409 N=C3=BCrnberg, Ge=
rmany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4=
ED5
"And now for something completely different."
