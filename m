From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/4] Clean up indentation in net/ipv6/transp_v6.h
Date: Sat, 01 Jun 2013 19:58:06 -0700 (PDT)
Message-ID: <20130601.195806.2024506377665086082.davem@davemloft.net>
References: <1370048750-28441-1-git-send-email-lorenzo@google.com>
	<1370049940.10556.100.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lorenzo@google.com, netdev@vger.kernel.org, edumazet@google.com,
	yoshfuji@linux-ipv6.org, segoon@openwall.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52900 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779Ab3FBC6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jun 2013 22:58:07 -0400
In-Reply-To: <1370049940.10556.100.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 31 May 2013 18:25:40 -0700

> externs aren't useful here and I suggest prototypes like
> int ipv6_exthdrs_init(void);

But this is the format used by the entire header file, all functions
are declared extern.

It is not reasonable to ask him to change this.  It's a seperate
cleanup, and that's assuming we actually agree to remove the externs.
I honestly see no reason to, they are harmless, and given that it's
just pure churn.
