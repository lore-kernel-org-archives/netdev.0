From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: introduce netdevice gso_min_segs attribute
Date: Mon, 06 Oct 2014 05:17:56 -0700
Message-ID: <1412597876.11091.59.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
		 <54312F50.2060608@mellanox.com>
		 <1412524252.11091.3.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1412529087.11091.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5432399B.3060406@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:49408 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895AbaJFMR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 08:17:58 -0400
Received: by mail-pa0-f51.google.com with SMTP id lj1so5231602pab.38
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 05:17:57 -0700 (PDT)
In-Reply-To: <5432399B.3060406@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-10-06 at 09:41 +0300, Amir Vadai wrote:
> On 10/5/2014 8:11 PM, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Some TSO engines might have a too heavy setup cost, that impacts
> > performance on hosts sending small bursts (2 MSS per packet).
> > 
> > This patch adds a device gso_min_segs, allowing drivers to set
> > a minimum segment size for TSO packets, according to the NIC
> > performance.
> > 
> > Tested on a mlx4 NIC, this allows to get a ~110% increase of
> > throughput when sending 2 MSS per packet.
> > 
> 
> Amazing!
> 
> Shouldn't there be a netif_set_gso_min_size() too?

Good point, I'll add it in v2, thanks !
