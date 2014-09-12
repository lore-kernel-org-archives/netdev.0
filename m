From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: Fix inverted NAPI_GRO_CB(skb)->flush test
Date: Fri, 12 Sep 2014 17:55:52 -0400 (EDT)
Message-ID: <20140912.175552.1008190879873868849.davem@davemloft.net>
References: <1410402198-30811-1-git-send-email-scottwood@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: scottwood@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164AbaILVzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 17:55:54 -0400
In-Reply-To: <1410402198-30811-1-git-send-email-scottwood@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Wood <scottwood@freescale.com>
Date: Wed, 10 Sep 2014 21:23:18 -0500

> Commit 2abb7cdc0d ("udp: Add support for doing checksum unnecessary
> conversion") caused napi_gro_cb structs with the "flush" field zero to
> take the "udp_gro_receive" path rather than the "set flush to 1" path
> that they would previously take.  As a result I saw booting from an NFS
> root hang shortly after starting userspace, with "server not
> responding" messages.
> 
> This change to the handling of "flush == 0" packets appears to be
> incidental to the goal of adding new code in the case where
> skb_gro_checksum_validate_zero_check() returns zero.  Based on that and
> the fact that it breaks things, I'm assuming that it is unintentional.
> 
> Fixes: 2abb7cdc0d ("udp: Add support for doing checksum unnecessary conversion")
> Cc: Tom Herbert <therbert@google.com>
> Signed-off-by: Scott Wood <scottwood@freescale.com>

Applied, thank you.
