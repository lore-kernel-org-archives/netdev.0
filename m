From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git)] stmmac: fix dma api misuse
Date: Fri, 29 Aug 2014 19:56:05 -0700 (PDT)
Message-ID: <20140829.195605.177395605884169802.davem@davemloft.net>
References: <53F6E8E8.1030900@st.com>
	<1409131620-16888-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andre.draszik@st.com, hdegoede@redhat.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52493 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbaH3C4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 22:56:07 -0400
In-Reply-To: <1409131620-16888-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Wed, 27 Aug 2014 11:27:00 +0200

> Enabling DMA_API_DEBUG, warnings are reported at runtime
> because the device driver frees DMA memory with wrong functions
> and it does not call dma_mapping_error after mapping dma memory.
> 
> The first problem is fixed by of introducing a flag that helps us
> keeping track which mapping technique was used, so that we can use
> the right API for unmap.
> This approach was inspired by the e1000 driver, which uses a similar
> technique.
> 
> Signed-off-by: Andre Draszik <andre.draszik@st.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Reviewed-by: Denis Kirjanov <kda@linux-powerpc.org>
> Cc: Hans de Goede <hdegoede@redhat.com>

Applied.
