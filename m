From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net/mlx4: use one page fragment per incoming
 frame
Date: Mon, 03 Jun 2013 11:12:30 -0700
Message-ID: <1370283150.24311.179.camel@edumazet-glaptop>
References: <1370282095.24311.171.camel@edumazet-glaptop>
	 <51ACDAF5.2040008@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:59467 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757041Ab3FCSMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 14:12:32 -0400
Received: by mail-pb0-f53.google.com with SMTP id un4so6075367pbc.12
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 11:12:31 -0700 (PDT)
In-Reply-To: <51ACDAF5.2040008@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-03 at 11:05 -0700, Rick Jones wrote:

> I take it this is a > 10 Gbit/s NIC?
> 

Well, I guess so !

Or something is really strange with this NIC !

> What if any is the downside to an incoming stream of small packets?

These kind of NIC are aimed for performance, I was told.

1) It would be strange to use them on memory constrained machines.

2) using 1536 bytes fragments is better than most other NIC drivers, as
they usually use 2048 or 4096 bytes frags

3) Current memory allocations done in mlx4 uses order-2 pages, and
nobody yet complained that these allocation might fail...
