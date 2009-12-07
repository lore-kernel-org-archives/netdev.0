From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCHv2 0/2] tcp: Stalling connections
Date: Mon, 07 Dec 2009 12:41:20 +0100
Message-ID: <4B1CE9E0.7070106@tvk.rwth-aachen.de>
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
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:46079 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933768AbZLGLlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 06:41:14 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KUA00LZD5SWYED0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Mon, 07 Dec 2009 12:41:20 +0100 (CET)
In-reply-to: <4B1CE45A.9010908@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches fixes a problem with the new RTO
timeout calculation as introduced for 2.6.32. Under some
circumstances, if a retransmission fails, the connection
is likely to die silently.

Changelog since v1:
Moved retransmits_timed_out from include/net/tcp.h
to net/ipv4/tcp_timer.c, where it is used.

Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>

Thanks.
