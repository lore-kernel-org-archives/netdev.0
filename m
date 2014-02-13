From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: do not set "u" bit for temporary
 addresses
Date: Thu, 13 Feb 2014 18:22:01 -0500 (EST)
Message-ID: <20140213.182201.1286350698724437652.davem@davemloft.net>
References: <1392203286-17833-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florent.fourcot@enst-bretagne.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51290 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbaBMXWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 18:22:03 -0500
In-Reply-To: <1392203286-17833-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Date: Wed, 12 Feb 2014 12:08:06 +0100

> The bit 6 of interface identifier was before the "universal/local bit",
> indicating local significance only. This rule is now obsoleted by the
> RFC 7136, removing all significance of bits in interface identifier.
> 
> The new rule is "In all cases, the bits in an IID have no generic
> semantics; in other words, they have opaque values.", so we can remove
> the setting of bit 6, it will improve the entropy of random addresses.
> 
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>

I'm hesistent to apply this given the feedback you've been given.
