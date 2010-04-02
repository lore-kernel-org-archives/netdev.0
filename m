From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: fix kconfig for crc32 build error
Date: Thu, 01 Apr 2010 17:26:42 -0700 (PDT)
Message-ID: <20100401.172642.117466667.davem@davemloft.net>
References: <1270107844-23457-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, carmelo.amoroso@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60842
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755865Ab0DBA0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 20:26:42 -0400
In-Reply-To: <1270107844-23457-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu,  1 Apr 2010 09:44:03 +0200

> From: Carmelo AMOROSO <carmelo.amoroso@st.com>
> 
> stmmac uses crc32 functions so it needs to select CRC32.
> 
> Fixes build error:
> drivers/built-in.o: In function `dwmac1000_set_filter':
> dwmac1000_core.c:(.text+0x3c380): undefined reference to `crc32_le'
> dwmac1000_core.c:(.text+0x3c384): undefined reference to `bitrev32'
> 
> Signed-off-by: Carmelo Amoroso <carmelo.amoroso@st.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
