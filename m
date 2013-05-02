From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Thu, 02 May 2013 04:16:25 -0400 (EDT)
Message-ID: <20130502.041625.412316202038784117.davem@davemloft.net>
References: <CA+55aFxoP1vybnqdDwGmd-m0j=x=KDm7GHV6J1i8wGOaU0=5qw@mail.gmail.com>
	<20130502.024552.1513488878160820332.davem@davemloft.net>
	<20130502070256.GA29502@macbook.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, hayeswang@realtek.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50901 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910Ab3EBIQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 04:16:27 -0400
In-Reply-To: <20130502070256.GA29502@macbook.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 2 May 2013 09:03:37 +0200

> I'll also have a look at this.

By the mere existence of /sys/devices/${DEV_PATH}/net/${netdev_name}/flags
we have to preserve the bit layout.

So Linus was right.

So network manager is probably reading that flags sysfs file and
interpreting it.

I'll fix the layout to how it was before.
