From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net/hyperv: Fix data corruption in
 rndis_filter_receive()
Date: Sun, 11 Mar 2012 15:51:11 -0700 (PDT)
Message-ID: <20120311.155111.1595145426893784653.davem@davemloft.net>
References: <1331328437-26852-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753846Ab2CKWvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 18:51:16 -0400
In-Reply-To: <1331328437-26852-1-git-send-email-haiyangz@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It is very tiring explaining how to submit patches properly, and
here you've made a poor submission once again.

You haven't indicated what tree you want these changes applied to.

You also mixed bug fixes and feature patches into the same patch set.

So the patch set isn't appropriate for the 'net' tree, because only
the most critical bug fixes can go there now.

And this patch set is also not appropriate for the 'net-next' tree
because I can only presume you want the important bug fix propagated
upstream as fast as possible but it cannot go in with the feature
patch since the feature patch is absolutely not appropriate for the
'net' tree right now.

I really don't see why it's such a hard thing to simply say where you
want patches applied when you submit them.  Do you want me to simply
guess?  How else am I supposed to figure out what you want?
