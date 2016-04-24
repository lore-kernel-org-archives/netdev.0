From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net merged into net-next
Date: Sat, 23 Apr 2016 18:39:58 -0700
Message-ID: <1461461998.7627.50.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160423.201230.364025148300253838.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Craig Gallek <kraig@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:37801 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751893AbcDXBkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2016 21:40:02 -0400
Received: by mail-ig0-f174.google.com with SMTP id g8so47741136igr.0
        for <netdev@vger.kernel.org>; Sat, 23 Apr 2016 18:40:02 -0700 (PDT)
In-Reply-To: <20160423.201230.364025148300253838.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-04-23 at 20:12 -0400, David Miller wrote:
> Eric, please double check my merge work for net/ipv4/udp.c
> 
> In net we fixed a soreuseport bug that added a hlist_nulls_add_tail_rcu()
> call to net/ipv4/udp.c
> 
> And in net-next you converted UDP sockets away from nulls lists.
> 
> Therefore I had to add a hlist_add_tail_rcu() implementation to
> linux/rculist.h and use it in net/ipv4/udp.c
> 
> Please make sure this is fine and will work safely.
> 
> Thanks!

Looks fine to me, thanks David

Craig, please have a look ?

( commit 1602f49b58abcb0d34a5f0a29d68e7c1769547aa in net-next)
