From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 net-next 0/2] net: implement SMC-R solution
Date: Tue, 25 Aug 2015 11:18:49 -0700 (PDT)
Message-ID: <20150825.111849.1251755515298926543.davem@davemloft.net>
References: <20150726.161530.2192841818929026804.davem@davemloft.net>
	<1440156629-35691-1-git-send-email-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: utz.bacher@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, ursula.braun@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981AbbHYSSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 14:18:50 -0400
In-Reply-To: <1440156629-35691-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Fri, 21 Aug 2015 13:30:27 +0200

> this is V4 of my SMC-R patches:
> Since you are asking for a solution "100% in our own separate module
> with our own can of worms", we have to give up the transparent detection
> whether a communication peer can do SMC-R or not (this has been the
> purpose of the rejected TCP hooks). Instead, we want just the new
> self-contained SMC-R socket family added to the kernel.
> By the way, since August 2015 the SMC-R Informational RFC is no longer
> a draft, but published as RFC7609.

The tcp_set_keepalive() layering hack is still beyond what I'm willing
to apply, sorry.

Also, as a coding style note, all of your code needs to be adjusted to
declare local function variables in "reverse christimas tree" order,
that is longest line to shortest.
