From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Fri, 09 Dec 2011 13:34:07 -0500 (EST)
Message-ID: <20111209.133407.2156473837364120429.davem@davemloft.net>
References: <1323177878.2448.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1323264929.23681.178.camel@zakaz.uk.xensource.com>
	<1323438427.20077.57.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44307 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753385Ab1LISeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2011 13:34:17 -0500
In-Reply-To: <1323438427.20077.57.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Fri, 9 Dec 2011 13:47:07 +0000

> If we had a concept like MAX_SKB_PAGES then it would perhaps make
> sense to have + 2 there, but AFAICT drivers etc are already
> accounting for this appropriately by adding a further + 2 (or
> sometimes + 1) to MAX_SKB_FRAGS.

Any kind of code like this, including the "+ 2" in the skbuff header,
should be coded to use some kind of macro so we can track this
dependency instead of stumbling onto it and accidently breaking lots
of stuff if we want to change this "2" value.
