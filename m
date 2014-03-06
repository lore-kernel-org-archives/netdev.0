From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: tcp_release_cb() should release socket ownership
Date: Wed, 05 Mar 2014 18:06:41 -0800
Message-ID: <1394071601.27473.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393942583.26794.107.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140304.134811.86791174090638790.davem@davemloft.net>
	 <1393972752.26794.145.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140305.205938.287751582220842351.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:51561 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757340AbaCFCGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 21:06:50 -0500
Received: by mail-pb0-f50.google.com with SMTP id md12so1911155pbc.9
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 18:06:50 -0800 (PST)
In-Reply-To: <20140305.205938.287751582220842351.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-05 at 20:59 -0500, David Miller wrote:

> It really means that sk_lock.owned cannot ever be accessed without the
> sk_lock spinlock held.
> 
> Most of this is easy to hand audit, except sock_owned_by_user() which
> has call sites everywhere.
> 
> Consider adding a locking assertion to it.

We can do that, but would it be a stable candidate ?

What about I send a followup for net-next ?

Thanks
