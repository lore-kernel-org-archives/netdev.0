From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 4/7] stmmac: add Rx watchdog optimization to mitigate
 the DMA irqs
Date: Thu, 06 Sep 2012 08:06:14 +0200
Message-ID: <50483D56.1020208@st.com>
References: <1346857432-24657-1-git-send-email-peppe.cavallaro@st.com> <1346857432-24657-5-git-send-email-peppe.cavallaro@st.com> <1346861675.5325.13.camel@bwh-desktop.uk.solarflarecom.com> <20120905.131615.1131246696009291033.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:56918 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751301Ab2IFGGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 02:06:33 -0400
In-Reply-To: <20120905.131615.1131246696009291033.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/5/2012 7:16 PM, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Wed, 5 Sep 2012 17:14:35 +0100
> 
>> On Wed, 2012-09-05 at 17:03 +0200, Giuseppe CAVALLARO wrote:
>>> GMAC devices newer than databook 3.50 has an embedded timer
>>> that can be used for mitigating the number of interrupts.
>>> So this patch adds this optimizations.
>>> Old MAC will continue to use NAPI.
>> [...]
>>
>> Interrupt moderation is *not* a substitute for NAPI; you should continue
>> using NAPI as well.
> 
> Absolutely correct, these two facilities are _complementary_ not _exlusive_.
> 
> In fact, the most optimal driver will use NAPI with relatively short HW
> mitigation settings.
> 

David, Ben,

many thanks for your notes and review. I'll apply them and re-test the
driver using NAPI plus the HW wdt feature.

Regards
Peppe
