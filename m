From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) 0/2] stmmac: review and fix the dwmac-sti
 glue-logic
Date: Tue, 14 Oct 2014 16:41:17 -0400 (EDT)
Message-ID: <20141014.164117.553206792335727136.davem@davemloft.net>
References: <1413267176-325-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maxime.coquelin@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44499 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755270AbaJNUlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 16:41:19 -0400
In-Reply-To: <1413267176-325-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Tue, 14 Oct 2014 08:12:54 +0200

> This patch is to review the whole glue logic adopted on STi SoCs that
> was bugged.
> In the old glue-logic there was a lot of confusion when setup the
> retiming especially for STiD127 where, for example, the bits 6 and 7
> (in the GMAC  control register) have a different meaning of what is
> used for STiH4xx SoCs. So we cannot adopt the same glue for all these
> SoCs.
> Moreover, GiGa on STiD127 didn't work and, for all the SoCs, the RGMII
> couldn't run when the speed was 10Mbps (because the clock was not properly
> managed).
> Note that the phy clock needs to be provided by the platform as well as
> documented in the related binding file (updated as consequence).
> 
> The old code supported too many configurations never adopted and validated.
> This made the code very complex to maintain and debug in case of issues.
> 
> The patch simplifies all the configurations as commented in the tables
> inside the file and obviously it has been tested on all the boards
> based on the SoCs mentioned.
> 
> With this patch, the dwmac-sti is also ready to support new configurations that
> will be available on next SoC generations.

Series applied.
