From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH] tcp: fix ICMP-RTO war
Date: Fri, 29 Jan 2010 17:15:57 +0200
Message-ID: <201001291715.57557.denys@visp.net.lb>
References: <201001271556.16156.denys@visp.net.lb> <4B62D0DE.9050706@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ilpo =?iso-8859-1?q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:60635 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596Ab0A2PQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 10:16:47 -0500
In-Reply-To: <4B62D0DE.9050706@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 29 January 2010 14:13:18 Damian Lukowski wrote:
> Denys Fedoryshchenko schrieb:
> > On Wednesday 27 January 2010 14:36:18 you wrote:
> >> Unless they are for a different connection? We might have to print sk
> >> (%p) in all those printouts to be sure which maps to which. If a peer
> >> becomes unreachable, it may well have multiple connections open (this
> >> was a proxy, iirc?).
> >
> > Ok i will try to do that today.
> >
> > Most probably different connections, on this proxy i have 10-15k
> > established connections at peak time.
http://www.nuclearcat.com/files/report1.txt
http://www.nuclearcat.com/files/report2.txt

Here with %p and sk.
