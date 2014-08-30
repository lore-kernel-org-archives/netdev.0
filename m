From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) (v2)] stmmac: ptp: fix the reference clock
Date: Fri, 29 Aug 2014 19:55:55 -0700 (PDT)
Message-ID: <20140829.195555.556471914848484099.davem@davemloft.net>
References: <1409033072-10508-1-git-send-email-peppe.cavallaro@st.com>
	<1409128669-14276-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889AbaH3Czz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 22:55:55 -0400
In-Reply-To: <1409128669-14276-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Wed, 27 Aug 2014 10:37:49 +0200

> The PTP reference clock, used for setting the addend in the Timestamp Addend
> Register, was erroneously hard-coded (as reported in the databook just as
> example).
> 
> The patch removes the macro named: STMMAC_SYSCLOCK and allows to use a
> reference clock (clk_ptp_ref_i) that can be passed from the platform.
> 
> If not passed, the main driver clock will be used as default; note that
> this can be fine on some platforms.
> 
> Note that, prior this patch, using the old STMMAC_SYSCLOCK on some platforms,
> as side effect, the ptp clock can move faster/slower than the system clock.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
> v2: fixed the release function in case of the new clock is not provided by the
>     platform.

Applied.
