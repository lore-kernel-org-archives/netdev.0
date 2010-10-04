From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2] drivers/net/stmmac/: add HAS_IOMEM dependency
Date: Sun, 03 Oct 2010 22:00:35 -0700 (PDT)
Message-ID: <20101003.220035.183055886.davem@davemloft.net>
References: <201010012117.o91LHDCF021161@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, peppe.cavallaro@st.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44006
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752048Ab0JDFAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 01:00:14 -0400
In-Reply-To: <201010012117.o91LHDCF021161@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 01 Oct 2010 14:17:13 -0700

> From: Martin Schwidefsky <schwidefsky@de.ibm.com>
> 
> The stmmac driver does not compile on s390:
> 
> drivers/net/stmmac/stmmac_main.c: In function 'stmmac_adjust_link':
> drivers/net/stmmac/stmmac_main.c:210: error: implicit declaration of function 'readl'
> drivers/net/stmmac/stmmac_main.c:263: error: implicit declaration of function 'writel'
> drivers/net/stmmac/stmmac_main.c: In function 'stmmac_dvr_probe':
> drivers/net/stmmac/stmmac_main.c:1674: error: implicit declaration of function 'ioremap'
> drivers/net/stmmac/stmmac_main.c:1674: warning: assignment makes pointer from integer without a cast
> drivers/net/stmmac/stmmac_main.c:1761: error: implicit declaration of function 'iounmap'
> make[3]: *** [drivers/net/stmmac/stmmac_main.o] Error 1
> 
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

This got fixed by adding a dependency on CPU_SUBTYPE_ST40.
