From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: use a stronger hash for tcp
Date: Thu, 21 Feb 2013 14:48:23 -0800
Message-ID: <1361486903.32484.0.camel@edumazet-glaptop>
References: <1361485132.17413.19.camel@edumazet-glaptop>
	 <20130221224316.GA9671@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:40625 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753004Ab3BUWs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 17:48:26 -0500
Received: by mail-pb0-f41.google.com with SMTP id um15so26394pbc.28
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2013 14:48:26 -0800 (PST)
In-Reply-To: <20130221224316.GA9671@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-21 at 23:43 +0100, Hannes Frederic Sowa wrote:

> 
> Perhaps we should use ipv6_addr_jhash in the destination cache, too, and look
> at other uses of ipv6_addr_hash?

Sure, an audit is needed, but with tcp early demux, TCP lookup was the
first weak point.

Thanks
