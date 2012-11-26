From: David Miller <davem@davemloft.net>
Subject: Re: [net-next.git 0/6 (V5)] stmmac: remove dead code for
 STMMAC_TIMER and add new mitigation schema
Date: Mon, 26 Nov 2012 17:23:03 -0500 (EST)
Message-ID: <20121126.172303.1672761221381936338.davem@davemloft.net>
References: <1353921046-5121-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54934 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932133Ab2KZWXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 17:23:06 -0500
In-Reply-To: <1353921046-5121-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon, 26 Nov 2012 10:10:40 +0100

> These patch series remove the STMMAC_TIMER option no longer updated
> and never used and add a new mitigation schema.
> Having removed the Timer opt, this has made the driver slim.
> On top of this work, it has been easier to introduce the new
> mitigation schema based on HW RX-watchdog (available in new cores).
> In fact, 3.50 and newer cores have an HW RX-Watchdog that can be used for 
> mitigating the Rx-interrupts and first results look promising.

All applied to net-next
