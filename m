From: David Miller <davem@davemloft.net>
Subject: Re: [net-next.git 4/7] stmmac: add Rx watchdog optimization to
 mitigate the DMA irqs
Date: Wed, 05 Sep 2012 13:16:15 -0400 (EDT)
Message-ID: <20120905.131615.1131246696009291033.davem@davemloft.net>
References: <1346857432-24657-1-git-send-email-peppe.cavallaro@st.com>
	<1346857432-24657-5-git-send-email-peppe.cavallaro@st.com>
	<1346861675.5325.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895Ab2IERQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 13:16:17 -0400
In-Reply-To: <1346861675.5325.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 5 Sep 2012 17:14:35 +0100

> On Wed, 2012-09-05 at 17:03 +0200, Giuseppe CAVALLARO wrote:
>> GMAC devices newer than databook 3.50 has an embedded timer
>> that can be used for mitigating the number of interrupts.
>> So this patch adds this optimizations.
>> Old MAC will continue to use NAPI.
> [...]
> 
> Interrupt moderation is *not* a substitute for NAPI; you should continue
> using NAPI as well.

Absolutely correct, these two facilities are _complementary_ not _exlusive_.

In fact, the most optimal driver will use NAPI with relatively short HW
mitigation settings.
