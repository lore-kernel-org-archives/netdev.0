From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ila: Perform only one translation in
 forwarding path
Date: Wed, 08 Jun 2016 00:40:55 -0700 (PDT)
Message-ID: <20160608.004055.1647414276965725415.davem@davemloft.net>
References: <1465340984-3270583-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33615 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040AbcFHHk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 03:40:57 -0400
In-Reply-To: <1465340984-3270583-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 7 Jun 2016 16:09:44 -0700

> When setting up ILA in a router we noticed that the the encapsulation
> is invoked twice: once in the route input path and again upon route
> output. To resolve this we add a flag set_csum_neutral for the
> ila_update_ipv6_locator. If this flag is set and the checksum
> neutral bit is also set we assume that checksum-neutral translation
> has already been performed and take no further action. The
> flag is set only in ila_output path. The flag is not set for ila_input and
> ila_xlat.
> 
> Tested:
> 
> Used 3 netns to set to emulate a router and two hosts. The router
> translates SIR addresses between the two destinations in other two netns.
> Verified ping and netperf are functional.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Applied, thanks Tom.
