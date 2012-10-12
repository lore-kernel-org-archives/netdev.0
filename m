From: Niels Baggesen <nba@users.sourceforge.net>
Subject: [PATCH] Ip6{In,Out}BcastPkts statistics missing from /proc/net/snmp6
Date: Fri, 12 Oct 2012 01:57:41 -0400
Message-ID: <S1754219Ab2JLF5l/20121012055742Z+351@vger.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:51280 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752518Ab2JLF5k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2012 01:57:40 -0400
Received: from webmail.baggesen.net (unknown [2.106.159.170])
	by pasmtpA.tele.dk (Postfix) with ESMTP id CCA38800267
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2012 07:39:45 +0200 (CEST)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by webmail.baggesen.net (Postfix) with ESMTP id 7ED445915
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2012 07:39:45 +0200 (CEST)
Received: from webmail.baggesen.net ([127.0.0.1])
	by localhost (baggesen.mine.nu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id cfG41D6YNdH3 for <netdev@vger.kernel.org>;
	Fri, 12 Oct 2012 07:39:44 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The subject line says it all:

Ip6{In,Out}BcastPkts statistics missing from /proc/net/snmp6

Signed-off-by: Niels Baggesen <nba@users.sourceforge.net>


--- net/ipv6/proc.c.orig    2012-10-01 12:52:09.452543199 +0200
+++ net/ipv6/proc.c    2012-10-01 12:53:19.794660628 +0200
@@ -90,6 +90,8 @@
      SNMP_MIB_ITEM("Ip6OutMcastOctets", IPSTATS_MIB_OUTMCASTOCTETS),
      SNMP_MIB_ITEM("Ip6InBcastOctets", IPSTATS_MIB_INBCASTOCTETS),
      SNMP_MIB_ITEM("Ip6OutBcastOctets", IPSTATS_MIB_OUTBCASTOCTETS),
+     SNMP_MIB_ITEM("Ip6InBcastPkts", IPSTATS_MIB_INBCASTPKTS),
+     SNMP_MIB_ITEM("Ip6OutBcastPkts", IPSTATS_MIB_OUTBCASTPKTS),
      SNMP_MIB_SENTINEL
  };

/Niels

--=20
Niels Baggesen - @home - =C5rhus - Denmark - nba@users.sourceforge.net
The purpose of computing is insight, not numbers   ---   R W Hamming
