From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next 4/4] ipv6 anycast: Convert ipv6_sk_ac_lock to
 spinlock.
Date: Wed, 30 Jan 2013 22:41:42 -0500 (EST)
Message-ID: <20130130.224142.2201083207144491282.davem@davemloft.net>
References: <5109743E.7070308@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48450 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755496Ab3AaDln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 22:41:43 -0500
In-Reply-To: <5109743E.7070308@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 31 Jan 2013 04:27:58 +0900

> Since all users are write-lock, it does not make sense to use
> rwlock here.  Use simple spinlock.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
