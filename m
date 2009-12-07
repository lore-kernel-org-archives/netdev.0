From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCHv3 0/2] tcp: Stalling connections
Date: Mon, 07 Dec 2009 17:06:11 +0100
Message-ID: <4B1D27F3.2000601@tvk.rwth-aachen.de>
References: <4B1C4C25.1070104@tvk.rwth-aachen.de> <4B1C9D94.3070504@gmail.com>
 <4B1CE45A.9010908@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
Cc: Netdev <netdev@vger.kernel.org>,
	=?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Frederic Leroy <fredo@starox.org>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:61811 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932496AbZLGQGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 11:06:07 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KUA00LABI2CX820@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Mon, 07 Dec 2009 17:06:12 +0100 (CET)
In-reply-to: <4B1CE45A.9010908@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches fixes a problem with the new RTO
timeout calculation as introduced for 2.6.32 in
commit 6fa12c85031485dff38ce550c24f10da23b0adaa.
Under some circumstances, if a retransmission fails, the connection
is likely to die silently.

Changes since v2:
The bugfix has to be applied first, so that the code cleanup
is optional.

Thanks

Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
---
