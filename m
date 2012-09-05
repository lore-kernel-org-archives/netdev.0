From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next.git 4/7] stmmac: add Rx watchdog optimization to
 mitigate the DMA irqs
Date: Wed, 5 Sep 2012 17:14:35 +0100
Message-ID: <1346861675.5325.13.camel@bwh-desktop.uk.solarflarecom.com>
References: <1346857432-24657-1-git-send-email-peppe.cavallaro@st.com>
	 <1346857432-24657-5-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:62099 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752001Ab2IEQOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 12:14:38 -0400
In-Reply-To: <1346857432-24657-5-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-05 at 17:03 +0200, Giuseppe CAVALLARO wrote:
> GMAC devices newer than databook 3.50 has an embedded timer
> that can be used for mitigating the number of interrupts.
> So this patch adds this optimizations.
> Old MAC will continue to use NAPI.
[...]

Interrupt moderation is *not* a substitute for NAPI; you should continue
using NAPI as well.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
