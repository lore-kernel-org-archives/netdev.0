From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v7 2/7 RFC] TCPCT part 1b: generate
 Responder Cookie secret
Date: Fri, 20 Nov 2009 09:22:28 -0800 (PST)
Message-ID: <20091120.092228.216274668.davem@davemloft.net>
References: <4B06A1FF.8000202@gmail.com>
	<4B06A659.3020109@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41326
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752775AbZKTRWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 12:22:11 -0500
In-Reply-To: <4B06A659.3020109@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Fri, 20 Nov 2009 09:23:21 -0500

> +static DEFINE_SPINLOCK(tcp_secret_locker);

So connection creation scalability will be limited now because
we'll always have to go through this centralized spinlock even
for independent listening sockets, right?

Just wondering...
