From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to submit to upper layer
Date: Sat, 14 Mar 2009 02:51:50 +0100
Message-ID: <20090314015150.GL11935@one.firstfloor.org>
References: <1236866906.3221.11.camel@achroite> <1236926602.2567.528.camel@ymzhang> <65634d660903131006n44f068dw18b2fe9dce25399e@mail.gmail.com> <20090313.115137.254924980.davem@davemloft.net> <65634d660903131358h765bef64y6a0f1b0db7400f6f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, yanmin_zhang@linux.intel.com,
	bhutchings@solarflare.com, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au, jesse.brandeburg@intel.com,
	shemminger@vyatta.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:34372 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761977AbZCNBvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 21:51:50 -0400
Content-Disposition: inline
In-Reply-To: <65634d660903131358h765bef64y6a0f1b0db7400f6f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We are trying to follow the decisions scheduler as opposed to leading it.
> This works on very loaded systems, with applications binding to cpusets,

One possible solution would be then to just not bind to cpusets and
give the scheduler the freedom it needs instead?

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
