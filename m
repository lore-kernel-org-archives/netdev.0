From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mrp: add periodictimer to retry lost packets
Date: Wed, 18 Sep 2013 13:54:06 -0400 (EDT)
Message-ID: <20130918.135406.2253301998172106706.davem@davemloft.net>
References: <CAB5uXS7b2CGjF=1OTzCmEeduGHSO_SOmMDv6=-bZU2VzaEQNfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: noel@burton-krahn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38168 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955Ab3IRRyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 13:54:11 -0400
In-Reply-To: <CAB5uXS7b2CGjF=1OTzCmEeduGHSO_SOmMDv6=-bZU2VzaEQNfA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Noel Burton-Krahn <noel@burton-krahn.com>
Date: Wed, 18 Sep 2013 10:09:25 -0700

> MRP doesn't implement the periodictimer in 802.1Q, so it never retries
> if packets get lost.  I ran into this problem when MRP sent a MVRP
> JoinIn before the interface was fully up.  The JoinIn was lost, MRP
> didn't retry, and MVRP registration failed.
> 
> (Sorry for the repost, my earlier message wasn't formatted correctly)

Still corrupted by your email client, it turned TAB characters
into spaces.

Still missing a signoff.
