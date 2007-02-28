From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4]: Kill fastpath_{skb,cnt}_hint.
Date: Wed, 28 Feb 2007 13:12:17 -0800 (PST)
Message-ID: <20070228.131217.92582224.davem@davemloft.net>
References: <20070228.114949.18302561.davem@davemloft.net>
	<20070228130808.4b7a9ea8@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51773
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751996AbXB1VMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 16:12:19 -0500
In-Reply-To: <20070228130808.4b7a9ea8@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 28 Feb 2007 13:08:08 -0800

> I would be happy to see this go.  Have you tried this code with
> a SACK DoS stream? I.e. before you could consume a huge amount
> of cpu time by giving an certain bad sequence of SACK's. This
> code should have a better worst case run time.

No I didn't do that.

In fact this new code wedged my workstation overnight somehow
and I need to debug that at some point as well. :-)

