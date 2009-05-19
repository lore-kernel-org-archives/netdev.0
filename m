From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] myri10ge: allow LRO to be enabled via ethtool
Date: Tue, 19 May 2009 15:26:08 -0700 (PDT)
Message-ID: <20090519.152608.149436309.davem@davemloft.net>
References: <4A131364.5050402@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49865
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752919AbZESW0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 18:26:10 -0400
In-Reply-To: <4A131364.5050402@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <brice@myri.com>
Date: Tue, 19 May 2009 22:15:32 +0200

> Allow myri10ge LRO to be enabled/disabled via ethtool
> (and by the stack for packet forwarding).
> 
> Signed-off-by: Brice Goglin <brice@myri.com>

So I applied these two patches for now to net-next-2.6
but in the long term I think it's probably better to convert
this driver to GRO as we're trying to get rid of LRO and
GRO handles forwarding and all of that stuff transparently.

And I also still want the myri10ge_lro module option removed
regardless of whether you do a GRO conversion or not.

If LRO/GRO causes a performance regression in some situation,
we should fix it instead of papering over this junk with
module options.

Thanks.
