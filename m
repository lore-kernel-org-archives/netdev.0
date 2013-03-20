From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] chelsio: use netdev_alloc_skb
Date: Wed, 20 Mar 2013 11:44:55 -0700
Message-ID: <1363805095.3333.30.camel@edumazet-glaptop>
References: <1363797199.3333.18.camel@edumazet-glaptop>
	 <20130320113024.00377b99@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f47.google.com ([209.85.210.47]:45245 "EHLO
	mail-da0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754593Ab3CTSo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 14:44:57 -0400
Received: by mail-da0-f47.google.com with SMTP id s35so1145482dak.6
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 11:44:57 -0700 (PDT)
In-Reply-To: <20130320113024.00377b99@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-20 at 11:30 -0700, Stephen Hemminger wrote:

> -		skb = alloc_skb(len + 2, GFP_ATOMIC);
> +		skb = netdev_alloc_skb_ip_align(netdev, len + 2);
>  		if (!skb)
>  			goto use_orig_buf;
>  


If you use the helper, no need for 'len + 2' but :

netdev_alloc_skb_ip_align(netdev, len);
