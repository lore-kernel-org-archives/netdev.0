From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: exploit skb->xmit_more to conditionally
 send doorbell
Date: Thu, 25 Sep 2014 09:19:53 -0700
Message-ID: <1411661993.16953.34.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411654669.16953.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140925164333.7cba128a@redhat.com>
	 <1411657615.16953.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411659380.16953.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:48823 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350AbaIYQTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 12:19:55 -0400
Received: by mail-pa0-f41.google.com with SMTP id fa1so2845567pad.28
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 09:19:54 -0700 (PDT)
In-Reply-To: <1411659380.16953.29.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-25 at 08:36 -0700, Eric Dumazet wrote:


>     26.36%  [kernel]  [k] __copy_skb_header     

Note to myself :

Time to optimize this thing, doing a memset() to copy a bunch of
consecutive fields.
