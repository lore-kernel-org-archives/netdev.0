From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 2/3] stmmac: fix timer setup when use dual mac
 Kconfig
Date: Tue, 27 Jul 2010 20:45:39 -0700 (PDT)
Message-ID: <20100727.204539.108767196.davem@davemloft.net>
References: <1280225387-26240-1-git-send-email-peppe.cavallaro@st.com>
	<1280225387-26240-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48819
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753330Ab0G1DpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 23:45:22 -0400
In-Reply-To: <1280225387-26240-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Tue, 27 Jul 2010 12:09:46 +0200

> The driver erroneously sets the tmrate to zero when the
> TMU initialisation fails. This actually generates problems
> while using the dual GMAC configuration.
> 
> With this patch, enabling both the dual gmac and the timer
> optimisation, the first interface opened will use the tmu
> channel 2, the second one won't be able to use the timer but
> will continue to work without mitigating the interrupts by
> using the external timer (i.e. TMU channel 2).
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
