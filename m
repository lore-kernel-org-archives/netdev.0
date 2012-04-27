From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4 net-next] tg3: provide frags as skb head
Date: Fri, 27 Apr 2012 12:38:36 -0400 (EDT)
Message-ID: <20120427.123836.690112554674540119.davem@davemloft.net>
References: <1335522889.2775.231.camel@edumazet-glaptop>
	<1335544386.2618.50.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, therbert@google.com,
	ncardwell@google.com, mcarlson@broadcom.com,
	jeffrey.t.kirsher@intel.com, mchan@broadcom.com,
	herbert@gondor.hengli.com.au, maze@google.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760438Ab2D0Qi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 12:38:57 -0400
In-Reply-To: <1335544386.2618.50.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 27 Apr 2012 17:33:06 +0100

> page_address() may return NULL if CONFIG_HIGHMEM is enabled.  And that's
> going to be a general problem with this scheme on 32-bit machines.

It can only be NULL for highmem pages, which he is not going to
get from the kind of page allocation calls he is using.
