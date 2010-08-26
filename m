From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] tcp: select(writefds) don't hang up when a peer close connection
Date: Thu, 26 Aug 2010 13:02:29 +0900 (JST)
Message-ID: <20100826130200.F66A.A69D9226@jp.fujitsu.com>
References: <AANLkTinPhzMSQ01AXZmDQw8h4OnuS8yoQu7eKog637LL@mail.gmail.com> <20100825.205154.191390581.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:46590 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710Ab0HZECc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 00:02:32 -0400
In-Reply-To: <20100825.205154.191390581.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Thu, 26 Aug 2010 12:09:55 +0900
> 
> > Probably my example is not so good. That's not my point.
> > In the example application, client and server socket is in the same process.
> > But it's NOT generic. usually, client and server are another process. then,
> > client can't expect when server close socket.
> > 
> > The most big matter is, this is can't be avoided in userland. In addition,
> > EVERY application don't want application hang up. we don't hesitate
> > userland change.
> 
> Ok, you and Ben Hutchings have convinced me to reconsider.
> 
> And this matches what even BSD4.4-Lite does (I checked yesterday before
> my initial reply), so I will apply this patch.
> 
> Thanks for your patience.

Great!

Thank you!!



