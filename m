From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IOAT: Fix ioatdma descriptor cache miss
Date: Tue, 14 Aug 2007 17:37:35 -0700 (PDT)
Message-ID: <20070814.173735.93210644.davem@davemloft.net>
References: <BAE9DCEF64577A439B3A37F36F9B691C02DBB8B7@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: shannon.nelson@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48583
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753963AbXHOAhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 20:37:41 -0400
In-Reply-To: <BAE9DCEF64577A439B3A37F36F9B691C02DBB8B7@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Nelson, Shannon" <shannon.nelson@intel.com>
Date: Tue, 14 Aug 2007 14:20:02 -0700

> The layout for struct ioat_desc_sw is non-optimal and causes an extra
> cache hit for every descriptor processed.  By tightening up the struct
> layout and removing one item, we pull in the fields that get used in
> the speedpath and get a little better performance.
...
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>

Patch applied, thanks.

> @@ -347,8 +347,7 @@ ioat_dma_prep_memcpy(struct dma_chan *chan, size_t
> len, int int_en)

Your email client is wrapping long lines in patches, corrupting
them.

I fixed it up this time, but please take care of this in the
future.
