From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] icmpv6_filter: allow ICMPv6 messages with
 bodies < 4 bytes
Date: Fri, 02 Aug 2013 15:16:31 -0700 (PDT)
Message-ID: <20130802.151631.410609670256107560.davem@davemloft.net>
References: <cover.1375417279.git.werner@almesberger.net>
	<9ad5a4d95d70d8f75127207d796a544aed1947cc.1375417279.git.werner@almesberger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: werner@almesberger.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42443 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754318Ab3HBWQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 18:16:31 -0400
In-Reply-To: <9ad5a4d95d70d8f75127207d796a544aed1947cc.1375417279.git.werner@almesberger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Werner Almesberger <werner@almesberger.net>
Date: Fri, 2 Aug 2013 10:51:34 -0300

> By using sizeof(_hdr), net/ipv6/raw.c:icmpv6_filter implicitly assumes
> that any valid ICMPv6 message is at least eight bytes long, i.e., that
> the message body is at least four bytes.
> 
> The DIS message of RPL (RFC 6550 section 6.2, from the 6LoWPAN world),
> has a minimum length of only six bytes, and is thus blocked by
> icmpv6_filter.
> 
> RFC 4443 seems to allow even a zero-sized body, making the minimum
> allowable message size four bytes.
> 
> Signed-off-by: Werner Almesberger <werner@almesberger.net>

Applied, thanks Werner.
