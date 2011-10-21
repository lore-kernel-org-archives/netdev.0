From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] tcp: add const qualifiers where possible
Date: Fri, 21 Oct 2011 02:55:49 -0400 (EDT)
Message-ID: <20111021.025549.113655582134326444.davem@redhat.com>
References: <1319179993.2854.63.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9309 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751124Ab1JUGzv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Oct 2011 02:55:51 -0400
In-Reply-To: <1319179993.2854.63.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 21 Oct 2011 08:53:13 +0200

> Adding const qualifiers to pointers can ease code review, and spot some
> bugs. It might allow compiler to optimize code further.
> 
> For example, is it legal to temporary write a null cksum into tcphdr
> in tcp_md5_hash_header() ? I am afraid a sniffer could catch the
> temporary null value...
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
