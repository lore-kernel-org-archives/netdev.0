From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4 v3] net: Add rxhash utility hash functions
Date: Tue, 17 Dec 2013 16:36:53 -0500 (EST)
Message-ID: <20131217.163653.2105961427411132477.davem@davemloft.net>
References: <alpine.DEB.2.02.1312152204580.20359@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49245 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060Ab3LQVgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 16:36:55 -0500
In-Reply-To: <alpine.DEB.2.02.1312152204580.20359@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 15 Dec 2013 22:11:50 -0800 (PST)

> v3:
> 
> There's really nothing specific about rxhash that constrains
> it to be a value just for these receive path. Drop the 'rx'
> part in utility functions, including skb_get_rxhash. In subsequent
> patches, we can change the rxhash and l4_rxhash names also, as
> well as abstracting out the interface to the hash.
> 
> Added comments about hash types per feedback.
> 
> In this version I'm omitting the changes to drivers to make the
> patch set manageable. Will add those changes in followup pathes.
> 
> -----
> This patch series introduce skb_set_rxhash and skb_clear_rxhash
> which are called to set the rxhash (from network drivers) and
> to clear the rxhash. This API should be used instead of updating
> fields in the skbuff directly.

Looks great, series applied, thanks Tom.
