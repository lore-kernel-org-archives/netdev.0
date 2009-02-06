From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: remove useless synchronize_net()
Date: Fri, 06 Feb 2009 14:10:26 -0800 (PST)
Message-ID: <20090206.141026.85510254.davem@davemloft.net>
References: <498ABDA2.5040603@dev.6wind.com>
	<20090205.234520.149982266.davem@davemloft.net>
	<498C403D.9040500@dev.6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@dev.6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33426
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752280AbZBFWKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 17:10:30 -0500
In-Reply-To: <498C403D.9040500@dev.6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Date: Fri, 06 Feb 2009 14:50:53 +0100

> If namespace is destroyed after this function, then cleanup_net()
> will ensure that nobody is looking at it

Maybe, but you better get some opinions from the people who wrote
and maintain the network namespace code before I can consider
your change seriously.

None of them responded to your patch posting, probably because
you failed to CC: any of them.
