From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][BNX2X]: New driver for Broadcom 10Gb Ethernet.
Date: Tue, 07 Aug 2007 16:08:08 -0700 (PDT)
Message-ID: <20070807.160808.38709450.davem@davemloft.net>
References: <46B8EF13.40109@garzik.org>
	<200708080020.35701.mb@bu3sch.de>
	<20070807230458.GA9883@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mb@bu3sch.de, jeff@garzik.org, mchan@broadcom.com,
	netdev@vger.kernel.org, eliezert@broadcom.com,
	lusinsky@broadcom.com, eilong@broadcom.com
To: hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50254
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759172AbXHGXII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 19:08:08 -0400
In-Reply-To: <20070807230458.GA9883@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 8 Aug 2007 00:04:59 +0100

> Please take a look at kernel/irq/handle.c.  The irq handler is
> always called with the right dev_id argument.  Everything would be a complete
> nightmare to handle because you usually need to access the device private
> data to check whether the shared irq is for this device.

Absolutely.

I can't believe we're even discussing something so obvious and
wasting everyone's time.
