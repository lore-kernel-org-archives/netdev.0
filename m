From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: skb_orphan() changes
Date: Wed, 31 Jul 2013 15:44:51 -0700
Message-ID: <1375310691.10515.113.camel@edumazet-glaptop>
References: <1375225875.10515.36.camel@edumazet-glaptop>
	 <20130731.152458.92056892741307118.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f178.google.com ([209.85.213.178]:58263 "EHLO
	mail-ye0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753740Ab3GaWoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 18:44:55 -0400
Received: by mail-ye0-f178.google.com with SMTP id r9so493374yen.9
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 15:44:54 -0700 (PDT)
In-Reply-To: <20130731.152458.92056892741307118.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-31 at 15:24 -0700, David Miller wrote:

> Applied, but personally I would have considered adding an
> else clause checking BUG_ON(skb->sk), or are you not so
> confident in your assertion? :-)

I considered this but this was adding a significant overhead, as this
is an inline function.

What about doing that for a limited time, say until 3.12 is released ?
