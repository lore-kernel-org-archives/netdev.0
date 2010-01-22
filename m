From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: fix bug in rx page posting
Date: Thu, 21 Jan 2010 22:52:16 -0800 (PST)
Message-ID: <20100121.225216.145277811.davem@davemloft.net>
References: <20100121115617.GA29213@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46866
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751564Ab0AVGwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 01:52:05 -0500
In-Reply-To: <20100121115617.GA29213@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Thu, 21 Jan 2010 17:26:17 +0530

> Pages are posted to the rxq in such a way that more than one frag
> can share the page. The last frag that uses the page unmaps the
> page.  In the case when a page is not fully used (due to lack of space in rxq)
> the last frag that uses the page is not being set as a "last_page_user";
> instead, the next frag in the rxq is incorrectly being set.
> 
> The fix has also been tested on ppc64 with 64k pages...
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied to net-2.6
