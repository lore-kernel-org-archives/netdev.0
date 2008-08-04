From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 2.6.27-rc1] ixp4xx_eth: fix dma_mapping_error() compile errors
Date: Mon, 04 Aug 2008 19:20:43 +0200
Message-ID: <m3bq08snmc.fsf@maximus.localdomain>
References: <200808011801.m71I1YLM006716@harpo.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mikael Pettersson <mikpe@it.uu.se>, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:58046 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755466AbYHDRUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2008 13:20:46 -0400
In-Reply-To: <200808011801.m71I1YLM006716@harpo.it.uu.se> (Mikael Pettersson's message of "Fri\, 1 Aug 2008 20\:01\:34 +0200 \(MEST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mikael Pettersson <mikpe@it.uu.se> writes:

> dma_mapping_error() changed in 2.6.27-rc1 to also take a device parameter,
> but nobody bothered updating ixp4xx_eth.c. Fixed by passing the appropriate
> device value in the dma_mapping_error() calls.

Thanks for fixing it.

Jeff, can you apply this patch? Alternatively I'll take it and
resend. Thanks.

Acked-by: Krzysztof Halasa <khc@pm.waw.pl>
-- 
Krzysztof Halasa
