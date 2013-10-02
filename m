From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] l2tp: fix kernel panic when using IPv4-mapped IPv6
 addresses
Date: Wed, 02 Oct 2013 17:10:25 -0400 (EDT)
Message-ID: <20131002.171025.1337077381989126490.davem@davemloft.net>
References: <524BD642.3020102@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jchapman@katalix.com, netdev@vger.kernel.org
To: f.cachereul@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49494 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753991Ab3JBVK2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 17:10:28 -0400
In-Reply-To: <524BD642.3020102@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Fran=E7ois Cachereul <f.cachereul@alphalink.fr>
Date: Wed, 02 Oct 2013 10:16:02 +0200

> IPv4 mapped addresses cause kernel panic.
> The patch juste check whether the IPv6 address is an IPv4 mapped
> address. If so, use IPv4 API instead of IPv6.
 ...
> Signed-off-by: Fran=E7ois CACHEREUL <f.cachereul@alphalink.fr>
> ---
> v3: add panic message
> Sorry for the dumb oversight

Applied and queued up for -stable, thank you.
