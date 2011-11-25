From: "Esztermann, Ansgar" <Ansgar.Esztermann@mpi-bpc.mpg.de>
Subject: TCP fast retransmit
Date: Fri, 25 Nov 2011 14:33:18 +0100
Message-ID: <2D9E1426-D432-4D08-BF28-FD2615AAEDBA@mpi-bpc.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imailer.gwdg.de ([134.76.11.19]:41838 "EHLO imailer.gwdg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755223Ab1KYN5T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 08:57:19 -0500
Received: from gwdexc-fe11.exc.top.gwdg.de ([134.76.9.231] helo=smtp-exc.gwdg.de)
	by mailer.gwdg.de with esmtps (TLSv1:RC4-MD5:128)
	(Exim 4.72)
	(envelope-from <Ansgar.Esztermann@mpi-bpc.mpg.de>)
	id 1RTvqL-0004oY-BC
	for netdev@vger.kernel.org; Fri, 25 Nov 2011 14:29:29 +0100
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[originally posted to lkml]
Hello list,

is there some documentation available on TCP fast retransmit? There see=
m to be quite a lot of descriptions -- from informal to scholarly paper=
s -- on the various algorithms available to calculate the proper size o=
f the congestion window, but I have been unable so far to find out *whe=
n* a fast retransmit is triggered. RFC 2581 states the third dupACK "sh=
ould" do it, and this seems to be quoted fairly often. However, I can e=
asily produce connections that fail to perform fast retransmit even aft=
er 5 dupACKs. Some people mention Linux uses a different (presumable mo=
re sophisticated) algorithm to trigger fast retransmits, but no-one see=
ms to elaborate.


Thanks,

A.
--=20
Ansgar Esztermann
DV-Systemadministration
Max-Planck-Institut f=FCr biophysikalische Chemie, Abteilung 105
