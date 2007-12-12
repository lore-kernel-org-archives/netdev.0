From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter : xt_hashlimit should use time_after_eq()
Date: Wed, 12 Dec 2007 20:06:47 +0100
Message-ID: <47603147.90008@trash.net>
References: <47602AE6.6060908@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53610 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751556AbXLLTG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 14:06:56 -0500
In-Reply-To: <47602AE6.6060908@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Hi David & Patrick
> 
> I believe this patch is needed for linux-2.6.24
> 
> Thank you
> 
> [PATCH] netfilter : xt_hashlimit should use time_after_eq()
> 
> In order to avoid jiffies wraparound and its effect, special care must 
> be taken
> when doing comparisons ...


Looks good, thanks Eric. Dave, please apply.
