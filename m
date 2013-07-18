From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] vlan: mask vlan prio bits
Date: Wed, 17 Jul 2013 18:08:26 -0700
Message-ID: <1374109706.6097.20.camel@edumazet-glaptop>
References: <1374083074.6097.18.camel@edumazet-glaptop>
	 <20130717.175823.1205139202025326865.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, florz@florz.de, sesse@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:54262 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754263Ab3GRBI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 21:08:28 -0400
Received: by mail-pb0-f42.google.com with SMTP id un1so2530240pbc.15
        for <netdev@vger.kernel.org>; Wed, 17 Jul 2013 18:08:28 -0700 (PDT)
In-Reply-To: <20130717.175823.1205139202025326865.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-17 at 17:58 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 17 Jul 2013 10:44:34 -0700
> 
> > Should we clear skb->vlan_tci in iptunnel_xmit(), or should we clear it
> > in __netif_receive_skb_core() like in this patch ?
> 
> The safest thing to do is as early as possible, so yes your patch here
> doing it in __netif_receive_skb_core() looks good to me.

OK then, I'll send an official patch ;)

Thanks !
