From: "Simon Schneider" <simon-schneider@gmx.net>
Subject: MLD maturity in kernel version 2.6.32.60
Date: Mon, 18 Nov 2013 13:17:28 +0100 (CET)
Message-ID: <trinity-825e48d2-0bab-4020-84f0-77800e55f25a-1384777048114@3capp-gmx-bs16>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:53552 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751171Ab3KRMR3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 07:17:29 -0500
Received: from 3capp-gmx-bs16.server.lan ([172.19.170.68]) by
 mrigmx.server.lan (mrigmx001) with ESMTP (Nemesis) id
 0MKwO6-1ViNlg0xTE-000206 for <netdev@vger.kernel.org>; Mon, 18 Nov 2013
 13:17:28 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,
in a development project, we started evaluating MLD functionality.
=C2=A0
Our development is based on kernel version 2.6.32.60.
=C2=A0
We noticed some pretty basic issues:
=C2=A0
- With force_mld_version set to 0 (we expect "MLDv2 with MLDv1 fallback=
"), we saw only MLDv2 messages, the fallback to MLDv1 didn't seem to wo=
rk, when we sent MLDv1 messages to the unit.
- With force_mld_version set to 1 (we expect "MLDv1 only mode"), we als=
o saw MLDv2 messages being generated.
=C2=A0
Can someone give a general statement about the MLD implementation matur=
ity in kernel 2.6.32.60? Are there known bugs that would explain the ab=
ove observations?

We need to see whether it makes sense to put further effort in investig=
ating/fixing any MLD related issue we see.

If this is the wrong list to ask this kind of question, please point me=
 to the correct one.

Thanks in advance,
best regards, Simon Schneider
=C2=A0
