From: "Simon Schneider" <simon-schneider@gmx.net>
Subject: DSCP of ICMPv6 Echo Reply not copied from Echo Request
Date: Wed, 8 Jan 2014 15:34:42 +0100 (CET)
Message-ID: <trinity-4fd0752d-8ed9-432f-aa23-28055f886c4a-1389191682248@3capp-gmx-bs32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:57999 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751069AbaAHOen convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 09:34:43 -0500
Received: from 3capp-gmx-bs32.server.lan ([172.19.170.84]) by
 mrigmx.server.lan (mrigmx002) with ESMTP (Nemesis) id
 0MCeiK-1WADce290E-009U3i for <netdev@vger.kernel.org>; Wed, 08 Jan 2014
 15:34:42 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,
with kernel version 2.6.33.32, I noticed for ping6 that the DSCP value =
of an Echo Request is not used for the corresponding Echo Reply.
=C2=A0
With ICMPv4, this is the case and I think it makes sense.
=C2=A0
This is not mandated by ICMP RFCs, but there are good reasons to use th=
e same DSCP in both directions.
=C2=A0
Is there a specific reason for this difference between v4 and v6?
=C2=A0
Or was it even fixed in some newer kernel version?
=C2=A0
best regards, Simon
