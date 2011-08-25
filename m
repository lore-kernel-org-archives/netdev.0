From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 1/2] af-packet: Added TPACKET_V3 headers.
Date: Wed, 24 Aug 2011 19:43:08 -0700 (PDT)
Message-ID: <20110824.194308.2024908890526228700.davem@davemloft.net>
References: <1313785096-911-1-git-send-email-loke.chetan@gmail.com>
	<1313785096-911-2-git-send-email-loke.chetan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: loke.chetan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405Ab1HYCnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 22:43:10 -0400
In-Reply-To: <1313785096-911-2-git-send-email-loke.chetan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chetan Loke <loke.chetan@gmail.com>
Date: Fri, 19 Aug 2011 16:18:15 -0400

> Added TPACKET_V3 definitions.
> 
> Signed-off-by: Chetan Loke <loke.chetan@gmail.com>

Applied.

I would suggest, as a follow-up patch, we add some appropriate
prefixes to these new datastructures added to if_packet.h as
these are exposed to userspace.

For example "hdr_v1", "bd_ts", "bd_header_u", and "block_desc" are
just asking for namespace conflicts with something other API in
userspace or the user's own datastructures.
