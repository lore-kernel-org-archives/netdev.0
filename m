From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 1/2] net: fix a compile error when
 CONFIG_NET_LL_RX_POLL is not set
Date: Thu, 01 Aug 2013 13:03:38 -0700 (PDT)
Message-ID: <20130801.130338.1147816900371465134.davem@davemloft.net>
References: <1375326625-21427-1-git-send-email-amwang@redhat.com>
	<51FA060A.2060202@linux.intel.com>
	<1375344487.7780.14.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eliezer.tamir@linux.intel.com, netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53261 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989Ab3HAUDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 16:03:40 -0400
In-Reply-To: <1375344487.7780.14.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Thu, 01 Aug 2013 16:08:07 +0800

> Thinking about it again, what is the point of your commit commit
> 89bf1b5a683df497c572c4d3bd3f9c9aa919d773 (net: remove NET_LL_RX_POLL
> config menue)? After that commit, CONFIG_NET_LL_RX_POLL is not visible
> by user and no other configs select it, also since it defaults to y, it
> will be _always_ enabled. If this is really what you want, we can simply
> remove all !CONFIG_NET_LL_RX_POLL code.

Yes we could do that, it has no dependencies which is the usual reason
to have a hidden Kconfig var like this.
