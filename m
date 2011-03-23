From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipv6: ip6_route_output does not modify sk
 parameter, so make it const
Date: Tue, 22 Mar 2011 19:17:45 -0700 (PDT)
Message-ID: <20110322.191745.48495271.davem@davemloft.net>
References: <1300831292-25378-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43451
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752626Ab1CWCRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 22:17:07 -0400
In-Reply-To: <1300831292-25378-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 22 Mar 2011 23:01:32 +0100

> This avoids explicit cast to avoid 'discards qualifiers'
> compiler warning in a netfilter patch that i've been working on.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks a lot Florian.
