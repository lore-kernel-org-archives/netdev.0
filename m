From: Wolfgang Walter <linux@stwm.de>
Subject: GRO: very bad routing performance with 3.14.4 for GRE-packets
Date: Tue, 08 Jul 2014 22:35:41 +0200
Message-ID: <1442942.x8F4o95O8x@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:43860 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753857AbaGHUl3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2014 16:41:29 -0400
Received: from mailhub.studentenwerk.mhn.de (mailhub.studentenwerk.mhn.de [127.0.0.1])
	by email.studentenwerk.mhn.de (Postfix) with ESMTP id 3h7Fld68G3z2hYf
	for <netdev@vger.kernel.org>; Tue,  8 Jul 2014 22:35:41 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I upgraded a router from 3.10.46 to 3.14.4 and I see a dramatic perfoma=
nce=20
loss for GRE-pakets if (and only if) GRO is enabled on the incoming or=20
outgoing interface (drops to 1/50th to 1/100th).

Other traffic is just fine.

The router itself is not endpoint of the GRE-tunnel.

The router has connection tracking enabled and does NAT (but most of th=
e=20
traffic is not NATed nor are GRE-packets).

The network card is an Intel Corporation I350 Gigabit (both interfaces)=
=2E

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
