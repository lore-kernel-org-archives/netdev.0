From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/2] stmmac: extend mac addr reg and fix perfect
 filering
Date: Fri, 11 May 2012 18:11:38 -0400 (EDT)
Message-ID: <20120511.181138.45562480899975594.davem@davemloft.net>
References: <1336381953-18041-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gianni.antoniazzi-ext@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37204 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932637Ab2EKWLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 18:11:43 -0400
In-Reply-To: <1336381953-18041-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon,  7 May 2012 11:12:32 +0200

> +	/* Extra 16 regs are available in cores newer than the 3.40. */
> +	if (id > 34)

No magic constants, even if you describe it in the comment.  Add
an appropriate macro and use it.
> +	/* For MAC Addr registers se have to set the Address Enable (AE)
> +	 * bit that has no effect on the High Reg 0 where the bit 31 (MO)
> +	 * is RO. */

Comments should be formatted as:

	/* For MAC Addr registers se have to set the Address Enable (AE)
	 * bit that has no effect on the High Reg 0 where the bit 31 (MO)
	 * is RO.
	 */
