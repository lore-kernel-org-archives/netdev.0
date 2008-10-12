From: David Miller <davem@davemloft.net>
Subject: Re: m68knommu, net and DMA compile error
Date: Sun, 12 Oct 2008 12:42:05 -0700 (PDT)
Message-ID: <20081012.124205.193717562.davem@davemloft.net>
References: <20081012111547.GE31153@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerg@uclinux.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44403
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751657AbYJLTm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Oct 2008 15:42:29 -0400
In-Reply-To: <20081012111547.GE31153@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Sun, 12 Oct 2008 14:15:47 +0300

> In the CONFIG_PCI=n case (the PCI code will be removed during this merge 
> window) m68knommu does not set the Kconfig NO_DMA variable, but also 
> does not provide the required functions, resulting in the following 
> build error triggered by commit a40c24a13366e324bc0ff8c3bb107db89312c984
> (net: Add SKB DMA mapping helper functions.):

I would recommend that m68knommu set NO_DMA in it's arch Kconfig
