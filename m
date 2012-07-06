From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Avoid overhead when no custom FIB rules are
 installed.
Date: Fri, 06 Jul 2012 11:53:17 -0700 (PDT)
Message-ID: <20120706.115317.360680535322848526.davem@davemloft.net>
References: <20120705.223142.2236039770560842377.davem@davemloft.net>
	<1341595171.2923.2.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38309 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757440Ab2GFSxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 14:53:20 -0400
In-Reply-To: <1341595171.2923.2.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 6 Jul 2012 18:19:31 +0100

> Do you really mean to set fib_has_custom_rules = true on deletion?

Yes, because someone could delete one of the default rules, which
would make our shortcut invalid.
