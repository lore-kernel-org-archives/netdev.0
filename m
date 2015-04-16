From: David Miller <davem@davemloft.net>
Subject: Re: Revert "net: Reset secmark when scrubbing packet"
Date: Thu, 16 Apr 2015 14:21:35 -0400 (EDT)
Message-ID: <20150416.142135.1372448954643242617.davem@davemloft.net>
References: <20150416010326.GA10864@gondor.apana.org.au>
	<alpine.LRH.2.11.1504161700130.23392@namei.org>
	<20150416081253.GA13595@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, nicolas.dichtel@6wind.com,
	netdev@vger.kernel.org, ebiederm@xmission.com,
	linux-security-module@vger.kernel.org, tgraf@suug.ch,
	fbl@sysclose.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34599 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754197AbbDPSVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 14:21:37 -0400
In-Reply-To: <20150416081253.GA13595@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 16 Apr 2015 16:12:53 +0800

> On Thu, Apr 16, 2015 at 05:02:15PM +1000, James Morris wrote:
>> 
>> They don't support namespaces, and maintaining the label is critical for 
>> SELinux, at least, which mediates security for the system as a whole.
> 
> Thanks for the confirmation James, I thought this looked a bit
> dodgy :)
> 
> ---8<---
> This patch reverts commit b8fb4e0648a2ab3734140342002f68fb0c7d1602
> because the secmark must be preserved even when a packet crosses
> namespace boundaries.  The reason is that security labels apply to
> the system as a whole and is not per-namespace.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and queued up for -stable.
