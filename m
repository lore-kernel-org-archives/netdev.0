From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] net: handle addr_type of 0 properly
Date: Fri, 25 Feb 2011 13:59:06 -0800 (PST)
Message-ID: <20110225.135906.245410645.davem@davemloft.net>
References: <1298648721-3026-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46768
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754912Ab1BYV63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 16:58:29 -0500
In-Reply-To: <1298648721-3026-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Fri, 25 Feb 2011 16:45:15 +0100

> addr_type of 0 means that the type should be adopted from from_dev and
> not from __hw_addr_del_multiple(). Unfortunately it isn't so and
> addr_type will always be considered. Fix this by implementing the
> considered and documented behavior.
> 
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

Applied to net-2.6, thanks.
