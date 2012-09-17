From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Mon, 17 Sep 2012 19:04:53 +0200
Message-ID: <1347901493.26523.151.camel@edumazet-glaptop>
References: <1347868144.26523.71.camel@edumazet-glaptop>
	 <20120917.121243.1665284878800146060.davem@davemloft.net>
	 <1347901326.26523.149.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35272 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755458Ab2IQRE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 13:04:58 -0400
Received: by bkwj10 with SMTP id j10so2647950bkw.19
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2012 10:04:57 -0700 (PDT)
In-Reply-To: <1347901326.26523.149.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-17 at 19:02 +0200, Eric Dumazet wrote:

> A driver already exports a dev->gso_max_size, dev->gso_max_segs, I guess
> it could export a dev->max_seg_order (default to 0)

Oh well, if we use a per thread order-3 page, a driver wont define an
order, but the max size of a segment (dev->max_seg_size).
