From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git)] stmmac: fix adjust link call in case of a
 switch is attached
Date: Wed, 06 Apr 2016 16:35:03 -0400 (EDT)
Message-ID: <20160406.163503.481176843308939572.davem@davemloft.net>
References: <1459838817-24905-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexandre.torgue@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44921 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbcDFUfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 16:35:05 -0400
In-Reply-To: <1459838817-24905-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Tue, 5 Apr 2016 08:46:57 +0200

> While initializing the phy, the stmmac driver sets the
> PHY_IGNORE_INTERRUPT so the PAL won't call the adjust hook
> that is needed, on some platforms, e.g. STi, to invoke the glue.
> 
> The patch allows the PAL to poll the stmmac_adjust_link just one time
> in case of a switch is attached, setting later the PHY_IGNORE_INTERRUPT
> flag.
> Moving this kind of logic inside the adjust_link it makes sense to
> anticipate the check for EEE that will never initialized in this
> scenario.
> 
> Reported-by: Gabriel Fernandez <gabriel.fernandez@linaro.org>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Tested-by: Gabriel Fernandez <gabriel.fernandez@linaro.org>
> Cc: Alexandre TORGUE <alexandre.torgue@st.com>

Applied, thank you.
