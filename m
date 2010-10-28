From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] stmmac: enable/disable rx/tx in the core with a
 single write.
Date: Thu, 28 Oct 2010 11:38:11 -0700 (PDT)
Message-ID: <20101028.113811.189711758.davem@davemloft.net>
References: <1288069094-25365-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, armando.visconti@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60366
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760765Ab0J1Shr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 14:37:47 -0400
In-Reply-To: <1288069094-25365-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Tue, 26 Oct 2010 06:58:14 +0200

> From: avisconti <armando.visconti@st.com>
> 
> This patch enables and disables the rx and tx bits in the MAC control reg
> by using a single write operation.
> This also solves a possible problem (spotted on SPEAr platforms) at 10Mbps
> where two consecutive writes to a MAC control register can take more than
> 4 phy_clk cycles.
> 
> Signed-off-by: Armando Visconti <armando.visconti@st.com>
> Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied, thanks.
