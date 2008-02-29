From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [IPV6]: Fix source address selection for ORCHID
 addresses
Date: Thu, 28 Feb 2008 20:55:56 -0800 (PST)
Message-ID: <20080228.205556.74897536.davem@davemloft.net>
References: <20080221100842.GA24905@verkkotelakka.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jmtapio@verkkotelakka.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46196
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754832AbYB2Ez4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 23:55:56 -0500
In-Reply-To: <20080221100842.GA24905@verkkotelakka.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Juha-Matti Tapio <jmtapio@verkkotelakka.net>
Date: Thu, 21 Feb 2008 12:08:42 +0200

> Skip the prefix length matching in source address selection for
> orchid -> non-orchid addresses.
> 
> Overlay Routable Cryptographic Hash IDentifiers (RFC 4843,
> 2001:10::/28) are currenty not globally reachable. Without this
> check a host with an ORCHID address can end up preferring those over
> regular addresses when talking to other regular hosts in the 2001::/16
> range thus breaking non-orchid connections.
> 
> Signed-off-by: Juha-Matti Tapio <jmtapio@verkkotelakka.net>

Also applied to net-2.6.26, thanks.
