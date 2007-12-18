From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: After many hours all outbound connections get stuck in SYN_SENT
Date: Tue, 18 Dec 2007 22:20:32 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0712182218000.4422@fbirervta.pbzchgretzou.qr>
References: <83a51e120712141239u52d2dd68p1b6ee7ed08f2cecf@mail.gmail.com>
 <Pine.LNX.4.64.0712180009390.32270@fbirervta.pbzchgretzou.qr>
 <83a51e120712180734i334399dbl51f44fe32d815f7d@mail.gmail.com>
 <Pine.LNX.4.64.0712181704380.4422@fbirervta.pbzchgretzou.qr>
 <83a51e120712180845k6cadf67bn5dd66fb2d3ac72d4@mail.gmail.com>
 <Pine.LNX.4.64.0712181818360.4422@fbirervta.pbzchgretzou.qr>
 <83a51e120712181009pf954f43mcb63ea4dab638458@mail.gmail.com>
 <Pine.LNX.4.64.0712181910580.4422@fbirervta.pbzchgretzou.qr>
 <83a51e120712181021p4c4c2a13g8820271f1e00361b@mail.gmail.com>
 <4768123A.7040603@cosmosbay.com> <83a51e120712181144l65633b32r72cc369f9d012f47@mail.gmail.com>
 <47682F8C.20205@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: James Nichols <jamesnichols3@gmail.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:45447 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755050AbXLRVUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 16:20:34 -0500
In-Reply-To: <47682F8C.20205@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 18 2007 21:37, Eric Dumazet wrote:
>
> If turning off tcp_sack makes the problem go away, why dont you
> turn it off all the time ?
>
That would just be workaround. I welcome the efforts to track this;
not all users have the time to do so.
Disabling tcp_sack also disabled it kernel-wide, which, well... for
2.6.25 there is a TCPOPTSTRIP netfilter target slated with which
SACK could be stripped only for a given host list or processes from
a UID.
