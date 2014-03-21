From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/4] net: use skb_get_hash in tx queue selection
Date: Thu, 20 Mar 2014 18:37:58 -0700
Message-ID: <1395365878.9114.117.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1403201701500.7187@tomh.mtv.corp.google.com>
	 <1395365518.9114.116.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:57030 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933875AbaCUBia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 21:38:30 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so1685426pdb.14
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 18:38:29 -0700 (PDT)
In-Reply-To: <1395365518.9114.116.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-20 at 18:31 -0700, Eric Dumazet wrote:

> Wouldn't it be faster to simply set skb->hash in providers (TCP, UDP),
> to that we do not add this test here ?
> 
> After packet has been a while in a qdisc, access to skb->sk_hash will
> likely trigger a cache line miss.

I meant access to skb->sk->sk_hash will likely trigger a cache line
miss.
