From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend] net: mvneta: Fix big endian issue in
 mvneta_txq_desc_csum()
Date: Tue, 08 Jul 2014 20:52:08 -0700 (PDT)
Message-ID: <20140708.205208.1742283754280003313.davem@davemloft.net>
References: <m3wqbnpgag.fsf@fitzsim.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	jason@lakedaemon.net, andrew@lunn.ch,
	sebastian.hesselbarth@gmail.com,
	gregory.clement@free-electrons.com,
	linux-arm-kernel@lists.infradead.org
To: fitzsim@fitzsim.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56258 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbaGIDwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 23:52:09 -0400
In-Reply-To: <m3wqbnpgag.fsf@fitzsim.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Fitzsimmons <fitzsim@fitzsim.org>
Date: Tue, 08 Jul 2014 19:44:07 -0400

> This commit fixes the command value generated for CSUM calculation
> when running in big endian mode.  The Ethernet protocol ID for IP was
> being unconditionally byte-swapped in the layer 3 protocol check (with
> swab16), which caused the mvneta driver to not function correctly in
> big endian mode.  This patch byte-swaps the ID conditionally with
> htons.
> 
> Cc: <stable@vger.kernel.org> # v3.13+
> Signed-off-by: Thomas Fitzsimmons <fitzsim@fitzsim.org>
> ---
> The mvneta driver existed prior to v3.13, but it has only supported big
> endian from v3.13 onward.  If it's accepted, this patch needs to be
> backported for stable only as far back as v3.13.

Applied and queued up for -stable, thanks.
