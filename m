From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: fix calculation of option len in
 ip6_append_data
Date: Wed, 14 May 2014 00:40:47 -0400 (EDT)
Message-ID: <20140514.004047.1550271032303990926.davem@davemloft.net>
References: <1399842073-1072-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, preobr@google.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47872 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728AbaENEkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 00:40:49 -0400
In-Reply-To: <1399842073-1072-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 11 May 2014 23:01:13 +0200

> tot_len does specify the size of struct ipv6_txoptions. We need opt_flen +
> opt_nflen to calculate the overall length of additional ipv6 extensions.
> 
> I found this while auditing the ipv6 output path for a memory corruption
> reported by Alexey Preobrazhensky while he fuzzed an instrumented
> AddressSanitizer kernel with trinity. This may or may not be the cause
> of the original bug.
> 
> Fixes: 4df98e76cde7c6 ("ipv6: pmtudisc setting not respected with UFO/CORK")
> Reported-by: Alexey Preobrazhensky <preobr@google.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks!
