From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] network: return errors if we know tcp_connect
 failed
Date: Fri, 12 Nov 2010 13:18:17 -0800 (PST)
Message-ID: <20101112.131817.27796671.davem@davemloft.net>
References: <20101112163543.GB122902@jupiter.n2.diac24.net>
	<4CDD7145.8070606@trash.net>
	<20101112211627.GC122902@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, eric.dumazet@gmail.com, eparis@redhat.com,
	hzhong@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	paul.moore@hp.com
To: equinox@diac24.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39738
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752046Ab0KLVRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 16:17:53 -0500
In-Reply-To: <20101112211627.GC122902@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lamparter <equinox@diac24.net>
Date: Fri, 12 Nov 2010 22:16:27 +0100

> As food for thought I'd like to pose the following rule:
> iptables -A OUTPUT -m statistic --mode nth --every 5 -j DROP
> which should, to my understanding, still allow the connect to complete,
> even if the first SYN got (silently!...) dropped.

Yes, I agree and this is pretty much the point I tried to make
earlier.
