From: David Miller <davem@davemloft.net>
Subject: Re: on-link assumption in ipv4 routing cache
Date: Mon, 20 Oct 2008 22:13:12 -0700 (PDT)
Message-ID: <20081020.221312.211946478.davem@davemloft.net>
References: <48FD2A34.7020702@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54207
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751032AbYJUFNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 01:13:35 -0400
In-Reply-To: <48FD2A34.7020702@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 20 Oct 2008 21:02:44 -0400

> This was somewhat of a surprise since I expected a EHOSTUNRACH error since
> there were no routes to the destination and SO_DONTROUTE was not set.
> 
> I am really curious as to reason for this behavior?

In general the Linux ipv4 stack tries to do things that make it more
likely for successful communication between two nodes.

This is one such example, another is the choice of using the host
based addressing model rather than the interface based addressing
model.

Alexey Kuznetsov is responsible for most of these decisions, he is
a genius.
