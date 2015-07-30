From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next] r8169:Place dma_alloc_coherent on interrupt
 context
Date: Thu, 30 Jul 2015 22:59:09 +0200
Message-ID: <20150730205909.GA7888@electric-eye.fr.zoreil.com>
References: <1438284801-4188-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Corcodel Marian <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55631 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703AbbG3U71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 16:59:27 -0400
Content-Disposition: inline
In-Reply-To: <1438284801-4188-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corcodel Marian <corcodel.marian@gmail.com> :
>    According to this doc
>  https://www.kernel.org/doc/Documentation/DMA-API.txt   dma_alloc_coherent
>  must run on interrupt context, and flush the chip before use.

You have misunderstood what an irq context is.

-- 
Ueimor
