From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Don't drop route cache entry in
 ipv4_negative_advice unless PTMU expired
Date: Sun, 21 Mar 2010 20:53:30 -0700 (PDT)
Message-ID: <20100321.205330.25144309.davem@davemloft.net>
References: <1269009673-25497-1-git-send-email-guenter.roeck@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viro@zeniv.linux.org.uk, den@openvz.org
To: guenter.roeck@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34106
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754057Ab0CVDxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 23:53:08 -0400
In-Reply-To: <1269009673-25497-1-git-send-email-guenter.roeck@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <guenter.roeck@ericsson.com>
Date: Fri, 19 Mar 2010 07:41:13 -0700

> TCP sessions over IPv4 can get stuck if routers between endpoints
> do not fragment packets but implement PMTU instead.

This bug actually only applies to a much more specific case.

It only occurs when the router we end up using is the result of
receiving a redirect to it.

If we use the configured route, and do not get redirected, the problem
never happens.

In any case, your patch is correct, and I'll add some clarification to
the commit message when I check this in.

Thanks a lot!
