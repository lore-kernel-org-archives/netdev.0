From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add rtnetlink init_rcvwnd to set the TCP initial
 receive window
Date: Wed, 23 Dec 2009 14:16:30 -0800 (PST)
Message-ID: <20091223.141630.115937361.davem@davemloft.net>
References: <pvm1viwx7kf.fsf@chavey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, eric.dumazet@gmail.com
To: chavey@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44646
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757469AbZLWWQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 17:16:28 -0500
In-Reply-To: <pvm1viwx7kf.fsf@chavey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chavey@google.com
Date: Tue, 15 Dec 2009 13:15:28 -0800

> Add rtnetlink init_rcvwnd to set the TCP initial receive window size
> advertised by passive and active TCP connections.
> The current Linux TCP implementation limits the advertised TCP initial
> receive window to the one prescribed by slow start. For short lived
> TCP connections used for transaction type of traffic (i.e. http
> requests), bounding the advertised TCP initial receive window results
> in increased latency to complete the transaction.
> Support for setting initial congestion window is already supported
> using rtnetlink init_cwnd, but the feature is useless without the
> ability to set a larger TCP initial receive window.
> The rtnetlink init_rcvwnd allows increasing the TCP initial receive
> window, allowing TCP connection to advertise larger TCP receive window
> than the ones bounded by slow start.
> 
> Signed-off-by: Laurent Chavey <chavey@google.com>

Applied.
