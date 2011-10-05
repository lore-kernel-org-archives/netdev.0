From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] skb fragment API: convert network drivers (part IV)
Date: Wed, 05 Oct 2011 17:36:31 -0400 (EDT)
Message-ID: <20111005.173631.1683862156493452092.davem@davemloft.net>
References: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregkh@suse.de
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34086 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754579Ab1JEVgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 17:36:39 -0400
In-Reply-To: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Wed, 5 Oct 2011 11:28:30 +0100

> The following series converts a forth batch of network drivers to the
> SKB pages fragment API introduced in 131ea6675c76.
> 
> There are two drivers/staging patches in here. I'm not sure who normally
> takes these, I'm sure you guys know though.
> 
> After this batch there are ~4 drivers which need a little more thought
> (the inevitable fifth out of four series...). Specifically these drivers
> will switch from skb_frag_t -> struct subpage (which I am going to
> introduce shortly) in their internal data structures, this will isolate
> them from changes to skb_frag_t coming from the network core.

All applied with the mentioned vxge adjustments, thanks Ian.
