From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [patch 2/2] drivers/net/stmmac/: add HAS_IOMEM dependency
Date: Tue, 5 Oct 2010 12:46:49 +0200
Message-ID: <4CAB0219.40007@st.com>
References: <201010012117.o91LHDCF021161@imap1.linux-foundation.org>
 <20101003.220035.183055886.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>,
	"heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:47617 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752108Ab0JEKtA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Oct 2010 06:49:00 -0400
In-Reply-To: <20101003.220035.183055886.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

On 10/04/2010 07:00 AM, David Miller wrote:
> From: akpm@linux-foundation.org
> Date: Fri, 01 Oct 2010 14:17:13 -0700
> 
>  > From: Martin Schwidefsky <schwidefsky@de.ibm.com>
>  >
>  > The stmmac driver does not compile on s390:
>  >
>  > drivers/net/stmmac/stmmac_main.c: In function 'stmmac_adjust_link':
>  > drivers/net/stmmac/stmmac_main.c:210: error: implicit declaration of function 
> 'readl'
>  > drivers/net/stmmac/stmmac_main.c:263: error: implicit declaration of function 
> 'writel'
>  > drivers/net/stmmac/stmmac_main.c: In function 'stmmac_dvr_probe':
>  > drivers/net/stmmac/stmmac_main.c:1674: error: implicit declaration of 
> function 'ioremap'
>  > drivers/net/stmmac/stmmac_main.c:1674: warning: assignment makes pointer from 
> integer without a cast
>  > drivers/net/stmmac/stmmac_main.c:1761: error: implicit declaration of 
> function 'iounmap'
>  > make[3]: *** [drivers/net/stmmac/stmmac_main.o] Error 1
>  >
>  > Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
>  > Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
>  > Cc: David S. Miller <davem@davemloft.net>
>  > Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
>  > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> This got fixed by adding a dependency on CPU_SUBTYPE_ST40.

This dependency was removed in driver included in net-next Git (because
the CPU_SUBTYPE_ST40 is a dead option).

I've seen that other drivers depend on HAS_IOMEM that is always  defined
for STM and ARM targets (where the I know the stmmac is used); No
problem for me to add this new dependency to in HAS_IOMEM the stmmac's
Kconfig if actually needed.

Regards
Peppe
