From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Ensure tx watchdog failures always print.
Date: Tue, 14 Jun 2011 13:33:29 -0400 (EDT)
Message-ID: <20110614.133329.165803790485169225.davem@davemloft.net>
References: <1308070213-13244-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53749 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580Ab1FNRdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 13:33:32 -0400
In-Reply-To: <1308070213-13244-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: greearb@candelatech.com
Date: Tue, 14 Jun 2011 09:50:13 -0700

> From: Ben Greear <greearb@candelatech.com>
> 
> These are too important to not have some log message
> generated.  But, keep the logic that only prints
> a single stack dump.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

We specifically made this print out only once, and yes
all of it.

Because it spams people's logs to the point that the message
is not useful and only scrolls out other more important
messages.

I'm not applying this, sorry.
