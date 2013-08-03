From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_rules: fix suppressor names and default values
Date: Sat, 03 Aug 2013 10:37:22 -0700 (PDT)
Message-ID: <20130803.103722.780534029060943275.davem@davemloft.net>
References: <20130803121443.GL21970@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stefan.tomanek@wertarbyte.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51459 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677Ab3HCRhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 13:37:23 -0400
In-Reply-To: <20130803121443.GL21970@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Date: Sat, 3 Aug 2013 14:14:43 +0200

> This change brings the suppressor attribute names into line; it also changes
> the data types to provide a more consistent interface.
> 
> While -1 indicates that the suppressor is not enabled, values >= 0 for
> suppress_prefixlen or suppress_ifgroup  reject routing decisions violating the
> constraint.
> 
> This changes the previously presented behaviour of suppress_prefixlen, where a
> prefix length _less_ than the attribute value was rejected. After this change,
> a prefix length less than *or* equal to the value is considered a violation of
> the rule constraint.
> 
> It also changes the default values for default and newly added rules (disabling
> any suppression for those).
> 
> Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>

Applied, thanks.
