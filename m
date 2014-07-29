From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] tcp: Fix integer-overflows in TCP vegas
Date: Mon, 28 Jul 2014 17:26:27 -0700 (PDT)
Message-ID: <20140728.172627.1679434888082672835.davem@davemloft.net>
References: <1406289159-30498-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com,
	David.Laight@ACULAB.COM, doug.leith@nuim.ie
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34898 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbaG2A02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 20:26:28 -0400
In-Reply-To: <1406289159-30498-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Fri, 25 Jul 2014 13:52:39 +0200

> +				target_cwnd = U32_MAX / rtt * upper + err / rtt;

Doing two divides is probably more expensive than using do_div().

Why don't we go back to the do_div() implementation, sorry about
changing my mind again.

And please resubmit the veno change, it's fine as-is.

Thanks again.
