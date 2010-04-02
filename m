From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] acenic: fix the misusage of zero dma address
Date: Thu, 01 Apr 2010 18:44:03 -0700 (PDT)
Message-ID: <20100401.184403.255389199.davem@davemloft.net>
References: <1270109586-9193-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-acenic@sunsite.dk, netdev@vger.kernel.org
To: fujita.tomonori@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44810
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759067Ab0DBBoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 21:44:01 -0400
In-Reply-To: <1270109586-9193-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Thu,  1 Apr 2010 17:13:05 +0900

> acenic wrongly assumes that zero is an invalid dma address (calls
> dma_unmap_page for only non zero dma addresses). Zero is a valid dma
> address on some architectures. The dma length can be used here.
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

Applied to net-next-2.6
