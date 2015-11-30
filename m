From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] packet: Allow packets with only a header (but no
 payload)
Date: Sun, 29 Nov 2015 22:18:49 -0500 (EST)
Message-ID: <20151129.221849.57848790197671069.davem@davemloft.net>
References: <1448067012-15090-1-git-send-email-martin.blumenstingl@googlemail.com>
	<1448210769-15289-1-git-send-email-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com, edumazet@google.com,
	nbd@openwrt.org, sergei.shtylyov@cogentembedded.com
To: martin.blumenstingl@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47862 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbbK3DSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 22:18:51 -0500
In-Reply-To: <1448210769-15289-1-git-send-email-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Date: Sun, 22 Nov 2015 17:46:09 +0100

> Commit 9c7077622dd91 ("packet: make packet_snd fail on len smaller
> than l2 header") added validation for the packet size in packet_snd.
> This change enforces that every packet needs a header (with at least
> hard_header_len bytes) plus a payload with at least one byte. Before
> this change the payload was optional.
> 
> This fixes PPPoE connections which do not have a "Service" or
> "Host-Uniq" configured (which is violating the spec, but is still
> widely used in real-world setups). Those are currently failing with the
> following message: "pppd: packet size is too short (24 <= 24)"
> 
> Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>

Applied, thanks.
