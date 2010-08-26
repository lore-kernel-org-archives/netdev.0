From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: select(writefds) don't hang up when a peer close
 connection
Date: Wed, 25 Aug 2010 20:51:54 -0700 (PDT)
Message-ID: <20100825.205154.191390581.davem@davemloft.net>
References: <20100825110049.F3C9.A69D9226@jp.fujitsu.com>
	<20100825.153424.246521475.davem@davemloft.net>
	<AANLkTinPhzMSQ01AXZmDQw8h4OnuS8yoQu7eKog637LL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org, bhutchings@solarflare.com
To: kosaki.motohiro@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41486
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751771Ab0HZDvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 23:51:39 -0400
In-Reply-To: <AANLkTinPhzMSQ01AXZmDQw8h4OnuS8yoQu7eKog637LL@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 26 Aug 2010 12:09:55 +0900

> Probably my example is not so good. That's not my point.
> In the example application, client and server socket is in the same process.
> But it's NOT generic. usually, client and server are another process. then,
> client can't expect when server close socket.
> 
> The most big matter is, this is can't be avoided in userland. In addition,
> EVERY application don't want application hang up. we don't hesitate
> userland change.

Ok, you and Ben Hutchings have convinced me to reconsider.

And this matches what even BSD4.4-Lite does (I checked yesterday before
my initial reply), so I will apply this patch.

Thanks for your patience.
