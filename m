From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) 1/4] stmmac: remove two useless initialisation
Date: Mon, 04 Jun 2012 11:49:40 -0400 (EDT)
Message-ID: <20120604.114940.813410325113851773.davem@davemloft.net>
References: <1338824270-9222-1-git-send-email-peppe.cavallaro@st.com>
	<1338824270-9222-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40484 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966Ab2FDPtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 11:49:42 -0400
In-Reply-To: <1338824270-9222-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon,  4 Jun 2012 17:37:47 +0200

> This patch removes two useful initialisation in the
> stmmac_rx and stmmac_tx function.
> In the former, count var was already reset and in the
> stmmac_tx we only need to increment the dirty pointer
> w/o setting the entry var.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

There are so many problems with this patch I do not know where
to start.

Your subject line says the initializations are "useless" yet
your commit message says they are "useful".

This is a cleanup, and does not fix any bugs, and is therefore
absolutely not appropriate for the 'net' tree.

I'm tossing this entire series, you need to be more careful
with your submissions.
