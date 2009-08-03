From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] mlx4_en: Fix double pci unmapping.
Date: Sun, 02 Aug 2009 22:10:30 -0700
Message-ID: <adaocqxo52x.fsf@cisco.com>
References: <4A62C9DD.8040506@mellanox.co.il>
	<20090802.202305.119004003.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yevgenyp@mellanox.co.il, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:42348 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbZHCFK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 01:10:29 -0400
In-Reply-To: <20090802.202305.119004003.davem@davemloft.net> (David Miller's
	message of "Sun, 02 Aug 2009 20:23:05 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > Ok, I'm just going to apply this.  Waiting more than a week to get
 > feedback from Roland for a bug fix like this is not reasonable.

Dave, for the mlx4 ethernet (mlx4_en) driver patches you can go ahead
and apply them without worrying about me -- Yevgeny was the original
author of that code and I consider him more than qualified to handle
that.  It's the mlx4_core changes that I prefer to handle, since I wrote
the original driver there, and mlx4_core changes potentially hit the
mlx4_ib InfiniBand driver too.

I realize that it's one more annoying thing to keep track of (although
Yevgeny has been great about sending mlx4_en patches to you and
mlx4_core patches to me -- but I understand your workflow makes looking
at the "To:" line hard).  That's why I suggested moving the mlx4_core
driver out of drivers/net/mlx4.  So that the two drivers are physically
separate, to make things clearer.

 - R.
