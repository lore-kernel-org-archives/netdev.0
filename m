From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] validate variable length ll headers
Date: Wed, 09 Mar 2016 22:13:40 -0500 (EST)
Message-ID: <20160309.221340.1476836223911285635.davem@davemloft.net>
References: <1457578714-36125-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38272 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932750AbcCJDNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 22:13:47 -0500
In-Reply-To: <1457578714-36125-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Wed,  9 Mar 2016 21:58:31 -0500

> Allow device-specific validation of link layer headers. Existing
> checks drop all packets shorter than hard_header_len. For variable
> length protocols, such packets can be valid.
> 
> patch 1 adds header_ops.validate and dev_validate_header
> patch 2 implements the protocol specific callback for AX25
> patch 3 replaces ll_header_truncated with dev_validate_header

Series applied and queued up for -stable, thanks!
