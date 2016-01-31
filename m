From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] flow_dissector: Fix unaligned access in
 __skb_flow_dissector when used by eth_get_headlen
Date: Sun, 31 Jan 2016 11:17:36 -0800 (PST)
Message-ID: <20160131.111736.885803938247704593.davem@davemloft.net>
References: <CAKgT0UfyK1HO6vp4F9S3rB400A74OhS=qRX_N9RuPRYg2KazLg@mail.gmail.com>
	<20160130.194507.777391919166997236.davem@davemloft.net>
	<CAKgT0UepN041H4QcWkoNWnzGgf=yo71w8_3-JQKFFNBegQVpzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, sowmini.varadhan@oracle.com,
	aduyck@mirantis.com, netdev@vger.kernel.org, tom@herbertland.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933388AbcAaTRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2016 14:17:39 -0500
In-Reply-To: <CAKgT0UepN041H4QcWkoNWnzGgf=yo71w8_3-JQKFFNBegQVpzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Sun, 31 Jan 2016 01:12:03 -0800

> If nothing else we can discuss this further in Seville as I am just
> not convinced changing the drivers is the right way to go about fixing
> this, and I won't have the time to really get around to doing any of
> it until I have come back from the conference.

Ok, let me think about this some more.

It's a shame that "put two garbage bytes into the FIFO at the
beginning of every frame" isn't a standard hw feature.  Or maybe
I misunderstand what's going on in all of these drivers...
