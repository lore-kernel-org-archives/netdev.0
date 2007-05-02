From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/20][BNX2]: Add 40-bit DMA workaround for 5708.
Date: Wed, 02 May 2007 00:12:43 -0700 (PDT)
Message-ID: <20070502.001243.70193466.davem@davemloft.net>
References: <1178068414.4820.39.camel@dell>
	<46383883.8070209@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57620
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754922AbXEBHMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 03:12:44 -0400
In-Reply-To: <46383883.8070209@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Wed, 02 May 2007 03:06:43 -0400

> Second, CONFIG_HIGHMEM is a bad test for IOMMU presence.  I don't
> think you /can/ test for IOMMU presence.  Maybe DaveM knows a way
> that I do not?

You really can't.

We have platforms that are both IOMMU and non-IOMMU for the same
configuration, it isn't known until run-time.
