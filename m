From: Wolfgang Walter <linux@stwm.de>
Subject: GRO: forwading ISATAP packets is very slow with kernel 4.1
Date: Wed, 15 Jul 2015 00:16:30 +0200
Message-ID: <17762800.UBb5paxXY3@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:37843 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751863AbbGNWXE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2015 18:23:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I upgraded routers from 3.14.x to 4.1.2. Forwarding ISATAP-packets (IPv=
4=20
packets with IPv6 payload) is very slow with 4.1 if GRO is enabled (you=
tube=20
for example about 64kbit). Disabling GRO on the interfaces restores=20
performance to values comparable to 3.14.x.

The kernel is build with IPv6 support but IPv6 is disabled via kernel c=
ommand=20
line. The router is not a tunnel endpoint, it only forwards the ISATAP-
packets. MTU is 1500 on both interfaces. Netfilter conntrack is not use=
d and=20
disabling netfilter has no effect.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
