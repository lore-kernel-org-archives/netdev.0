From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: introduce netdevice gso_min_segs attribute
Date: Mon, 06 Oct 2014 15:26:23 -0700
Message-ID: <1412634383.11091.91.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412529087.11091.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141006.172149.1596496098013953331.davem@davemloft.net>
	 <1412631778.11091.84.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141006.175410.2083551367207718756.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, edumazet@google.com, netdev@vger.kernel.org,
	yevgenyp@mellanox.com, ogerlitz@mellanox.com, idos@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36039 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbaJFW0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 18:26:25 -0400
Received: by mail-pa0-f49.google.com with SMTP id hz1so5906663pad.8
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 15:26:25 -0700 (PDT)
In-Reply-To: <20141006.175410.2083551367207718756.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-10-06 at 17:54 -0400, David Miller wrote:

> Ok I'm sold on your patch then if two major chipsets already benefit
> from differing values.
> 
> I'll apply this, thanks Eric.

I did the experiment on I40e, and no difference on this NIC.

(Note it stills lacks xmit_more support atm)

Thanks David
