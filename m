From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] mlx4: exploit skb->xmit_more to conditionally
 send doorbell
Date: Thu, 25 Sep 2014 13:58:14 -0700
Message-ID: <1411678694.3460.13.camel@joe-AO725>
References: <1411654669.16953.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140925164333.7cba128a@redhat.com>
	 <1411657615.16953.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411659380.16953.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411678046.16953.45.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0153.hostedemail.com ([216.40.44.153]:41272 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751474AbaIYU6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 16:58:18 -0400
In-Reply-To: <1411678046.16953.45.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-25 at 13:47 -0700, Eric Dumazet wrote:
> After patch :
>     32.78%  [kernel]  [k] __copy_skb_header             
> After __copy_skb_header() optimization I get something even nicer ;)
>     19.90%  [kernel]          [k] __copy_skb_header             
> I'll post this patch asap.

Eric, you are _killing_ it.  network ninja indeed...
