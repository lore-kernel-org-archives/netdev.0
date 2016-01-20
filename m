From: Wolfgang Walter <linux@stwm.de>
Subject: regression kernel 4.4: stops routing packets with a GRE-payload
Date: Wed, 20 Jan 2016 15:00:52 +0100
Message-ID: <2738275.ziX0sZKPG0@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:43691 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751205AbcATOHF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2016 09:07:05 -0500
Received: from mailhub.studentenwerk.mhn.de (mailhub.studentenwerk.mhn.de [127.0.0.1])
	by email.studentenwerk.mhn.de (Postfix) with ESMTP id 3plpR91F78zMktL
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 15:00:53 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

we tried 4.4 on our routers. We found one problem: 4.4 stops routing GR=
E=20
packets (ipv4 in GRE/ipv4) here. 4.4.15 works fine.

Neither GRE-endpoint is on the router:

gre-endpoint A <=3D=3D internet =3D=3D=3D> (eth0)router(eth1) <=3D=3D n=
etwork =3D=3D> gre-
endpoint B

eth0 and eth1 are intel network-cards (I350).

I see GRE-packets arriving both at eth0 and eth1.

GRE-packets from eth0 are not forwarded to eth1 (that means: I can't se=
e them=20
with tcpdump on eth1 nor on endpoint B). Packtes with an TCP or UDP pay=
load=20
are forwarded.

Some GRE-packets from eth1 are forwarded to eth0 but most just seem to=20
disappear.

On the gre-endpoint B (same hardware) which is also a linux router kern=
el 4.4=20
works. So this seems to be a problem when forwarding ipv4-packets with =
a GRE-
payload.


Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
