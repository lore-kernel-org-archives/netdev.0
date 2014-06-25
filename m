From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: mark packets sent to any local mac address as
 PACKET_HOST
Date: Wed, 25 Jun 2014 16:09:25 -0700 (PDT)
Message-ID: <20140625.160925.2125216104261498290.davem@davemloft.net>
References: <1403534015-28496-1-git-send-email-mbizon@freebox.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39025 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757197AbaFYXJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 19:09:26 -0400
In-Reply-To: <1403534015-28496-1-git-send-email-mbizon@freebox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maxime Bizon <mbizon@freebox.fr>
Date: Mon, 23 Jun 2014 16:33:35 +0200

> The bridge code only set PACKET_HOST on packets sent to the bridge mac
> address, packets sent to other local mac addresses are sent to upper
> layers, but ignored because they are marked as PACKET_OTHERHOST.
> 
> Signed-off-by: Maxime Bizon <mbizon@freebox.fr>

This looks fine to me, Stephen and other bridge hackers please review.
