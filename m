From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/8] address: Support NLM_F_EXCL when adding addresses
Date: Mon, 18 Sep 2006 00:14:14 -0700 (PDT)
Message-ID: <20060918.001414.11628327.davem@davemloft.net>
References: <20060901213957.138695086@lsx.localdomain>
	<20060901214015.161907736@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:24021
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965520AbWIRHOS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 03:14:18 -0400
To: tgraf@suug.ch
In-Reply-To: <20060901214015.161907736@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 01 Sep 2006 23:40:05 +0200

> iproute2 doesn't provide the NLM_F_CREATE flag when adding addresses,
> it is assumed to be implied. The existing code issues a check on
> said flag when the modify operation fails (likely due to ENOENT)
> before continueing to create it, this leads to a hard to predict
> result, therefore the NLM_F_CREATE check is removed.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

I hope this doesn't break any existing stuff, but it is certainly
the logically correct thing to do.  If things break I'm reverting
this though.

But for now, applied, thanks.

