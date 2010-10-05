From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2] drivers/net/stmmac/: add HAS_IOMEM dependency
Date: Tue, 05 Oct 2010 11:41:14 -0700 (PDT)
Message-ID: <20101005.114114.55873887.davem@davemloft.net>
References: <201010012117.o91LHDCF021161@imap1.linux-foundation.org>
	<20101003.220035.183055886.davem@davemloft.net>
	<4CAB0219.40007@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57135
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751563Ab0JESky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 14:40:54 -0400
In-Reply-To: <4CAB0219.40007@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Date: Tue, 5 Oct 2010 12:46:49 +0200

> This dependency was removed in driver included in net-next Git (because
> the CPU_SUBTYPE_ST40 is a dead option).

Oh yes, I missed that.  Thanks for noticing.

> I've seen that other drivers depend on HAS_IOMEM that is always  defined
> for STM and ARM targets (where the I know the stmmac is used); No
> problem for me to add this new dependency to in HAS_IOMEM the stmmac's
> Kconfig if actually needed.

I'll add the patch Andrew posted, it is needed now.

Thanks again.
