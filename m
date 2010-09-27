From: David Miller <davem@davemloft.net>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Sun, 26 Sep 2010 23:44:19 -0700 (PDT)
Message-ID: <20100926.234419.98895535.davem@davemloft.net>
References: <20100926.181202.28824153.davem@davemloft.net>
	<20100927053901.GL12373@1wt.eu>
	<1285566504.2357.549.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42809
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755036Ab0I0Gn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 02:43:59 -0400
In-Reply-To: <1285566504.2357.549.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 27 Sep 2010 07:48:24 +0200

> Its a bit tricky, because you cannot send the FIN flag on the last
> segment, but have to wait for the final ACK coming from client, to
> finally send an RST.

This is going to be incredibly complicated, for something I see
next to zero value.
