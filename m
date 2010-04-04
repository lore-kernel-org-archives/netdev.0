From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: use the dma state API instead of the pci
 equivalents
Date: Sun, 04 Apr 2010 01:39:20 -0700 (PDT)
Message-ID: <20100404.013920.120463402.davem@davemloft.net>
References: <20100402115054A.fujita.tomonori@lab.ntt.co.jp>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDC525ADDB@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56902
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752115Ab0DDIjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 04:39:19 -0400
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADDDC525ADDB@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Sun, 4 Apr 2010 01:19:07 -0700

> So, if we don't need to use pci_X() interface anymore, lets replace
> pci_X() properly all over the bnx2x with dma_X() functions.

I think Fujita's plan of gradual and partial transformations is
legitimate, and his changes shouldn't be rejected because he simply
isn't modifying all of the interfaces used by this driver but rather
just a specific subset he is trying to transform across the tree.

Please rescind your objections.

Thanks.
