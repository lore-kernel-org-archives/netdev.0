From: David Miller <davem@davemloft.net>
Subject: Re: [net] stmmac: fix driver Kconfig when built as module
Date: Wed, 23 May 2012 14:01:39 -0400 (EDT)
Message-ID: <20120523.140139.197296963542601285.davem@davemloft.net>
References: <1337672336-7378-2-git-send-email-lliubbo@gmail.com>
	<1337753142-13762-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	lliubbo@gmail.com, rayagond@vayavyalabs.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755562Ab2EWSBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 14:01:55 -0400
In-Reply-To: <1337753142-13762-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Wed, 23 May 2012 08:05:42 +0200

> This patches fixes the driver when built as dyn module.
> In fact the platform part cannot be built and the probe fails
> (thanks to Bob Liu that reported this bug).
> The patch also makes the selection of Platform and PCI parts
> mutually exclusive.
> 
> Reported-by: Bob Liu <lliubbo@gmail.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

We have drivers which support both OF (which is implemented as
platform bus) and PCI at the same time.  For example,
drivers/net/ethernet/sun/niu.c

I do not see why stmmac cannot support both at the same time as well.

I absolutely do not want such segregation unless it is absolutely
necessary.  Because it means that no matter what is choosen, a piece
of code is disabled and therefore not getting build and/or runtime
validation.
