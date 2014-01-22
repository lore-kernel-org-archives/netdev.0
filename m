From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] tcp: metrics: Handle v6/v4-mapped sockets
 in tcp-metrics
Date: Wed, 22 Jan 2014 06:49:31 -0800
Message-ID: <1390402171.27806.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1390395524-27930-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:58376 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755316AbaAVOte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 09:49:34 -0500
Received: by mail-pd0-f176.google.com with SMTP id w10so454349pde.7
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 06:49:33 -0800 (PST)
In-Reply-To: <1390395524-27930-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-22 at 13:58 +0100, Christoph Paasch wrote:
> A socket may be v6/v4-mapped. In that case sk->sk_family is AF_INET6,
> but the IP being used is actually an IPv4-address.
> Current's tcp-metrics will thus represent it as an IPv6-address:
> 
> root@server:~# ip tcp_metrics
> ::ffff:10.1.1.2 age 22.920sec rtt 18750us rttvar 15000us cwnd 10
> 10.1.1.2 age 47.970sec rtt 16250us rttvar 10000us cwnd 10
> 
> This patch modifies the tcp-metrics so that they are able to handle the
> v6/v4-mapped sockets correctly.
> 
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
