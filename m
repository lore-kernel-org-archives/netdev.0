From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8152: add missing Makefile rule
Date: Sat, 02 Aug 2014 20:41:34 -0700 (PDT)
Message-ID: <20140802.204134.360329908595614221.davem@davemloft.net>
References: <53DC2230.9010504@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org
To: jflf-kernel@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51390 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755194AbaHCDlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2014 23:41:35 -0400
In-Reply-To: <53DC2230.9010504@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jflf-kernel@gmx.com
Date: Sat, 02 Aug 2014 01:26:40 +0200

>  Is seems that this issue has existed ever since the driver was
>  added back in 3.10. In Linus' git tree the drivers/net/Makefile was
>  last modified before the inclusion of the driver, so I don't know
>  if it's ever been possible to build it.

It gets built, as long as at least one other USB networking driver has
been selected.

Most people (distributions, developers, maintainers) select all
drivers or some large subset thereof, so would never actually run into
this problem.

You'd have to specifically have a configuration that enabled r8152 and
no other USB networking driver, in order to trigger this.

Anyways, I'll apply this, thanks.
