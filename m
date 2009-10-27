From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: sja1000: fix bug using library functions for skb
 allocation
Date: Mon, 26 Oct 2009 17:34:06 -0700 (PDT)
Message-ID: <20091026.173406.101747247.davem@davemloft.net>
References: <4AE5C444.9030804@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Socketcan-core@lists.berlios.de,
	kurt.van.dijck@eia.be
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53775
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755732AbZJ0Adn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 20:33:43 -0400
In-Reply-To: <4AE5C444.9030804@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Mon, 26 Oct 2009 16:46:12 +0100

> Commit 7b6856a0 "can: provide library functions for skb allocation"
> did not properly remove two lines of the SJA1000 driver resulting in
> a 'skb_over_panic' when calling skb_put, as reported by Kurt.
> 
> Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>

Applied, thanks.
