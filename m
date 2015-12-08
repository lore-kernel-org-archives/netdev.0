From: David Miller <davem@davemloft.net>
Subject: Re: Checksum offload queries
Date: Tue, 08 Dec 2015 12:06:54 -0500 (EST)
Message-ID: <20151208.120654.2127200076257822677.davem@davemloft.net>
References: <5665A848.9010001@solarflare.com>
	<20151207.143848.2158761076110518741.davem@davemloft.net>
	<5666EC4B.40800@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbbLHRG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 12:06:56 -0500
In-Reply-To: <5666EC4B.40800@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 8 Dec 2015 14:42:19 +0000

> I'm afraid I still don't see it.

You assume that nothing in the stack mangles the packet and would
benefit from having the 1's complement to work with in order to
assist with checksum adjustments etc.

So we want 1's complement, all the time.

All of the headers get touched anyways as each layer of the stack
demuxes the packet.  Therefore there is _ZERO_ cost to use 1's
complement to validate checksums in input.

It's always superior.
