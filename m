From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: [net-next-2.6 PATCH 1/7] xfrm: introduce basic mark infrastructure
Date: Tue, 16 Feb 2010 11:43:05 +0100
Message-ID: <m37hqdcvgm.fsf@ursa.amorsen.dk>
References: <1266160732-946-1-git-send-email-hadi@cyberus.ca>
	<1266160732-946-2-git-send-email-hadi@cyberus.ca>
	<4B796B70.2050102@trash.net> <1266253235.6776.90.camel@bigi>
	<4B797F09.5050207@trash.net> <1266254073.6776.109.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, timo.teras@iki.fi,
	herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([94.127.49.2]:39394 "EHLO gate1.ipvision.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932799Ab0BPKnW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2010 05:43:22 -0500
In-Reply-To: <1266254073.6776.109.camel@bigi> (jamal's message of "Mon, 15 Feb
	2010 12:14:33 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal <hadi@cyberus.ca> writes:

> I take it policy routing by mark is insufficient.

xfrm ignores policy routing. You can't route IPSEC in Linux. This is
actually a fairly annoying limitation. The workaround is to do like
Microsoft: Encapsulate everything in l2tp or gre.


/Benny

