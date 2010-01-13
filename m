From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add CAP_NET_RAW checks to bind() and sendmsg() on a
 AF_PACKET socket
Date: Tue, 12 Jan 2010 16:03:30 -0800 (PST)
Message-ID: <20100112.160330.13265292.davem@davemloft.net>
References: <1263340440.6844.110.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54400
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751191Ab0AMADW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 19:03:22 -0500
In-Reply-To: <1263340440.6844.110.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Tue, 12 Jan 2010 15:54:00 -0800

> So when a packet socket fd is passed to an un-privileged process, it
> can do a re-bind or send a message to any interface.

I think passing such fd's to an unprivileged process is a
very serious security hole.

There are so many anti-social things you can do with
that even if you control how it is bound.
