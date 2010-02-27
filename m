From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] fix problems with NETIF_F_HIGHDMA in networking
 drivers
Date: Sat, 27 Feb 2010 04:05:02 -0800 (PST)
Message-ID: <20100227.040502.182574085.davem@davemloft.net>
References: <51f3faa71002261908y7cfa62eeicb3e56d5c920887a@mail.gmail.com>
	<20100227.015350.71138134.davem@davemloft.net>
	<201002271259.31596.bzolnier@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hancockrwd@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: bzolnier@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48850
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966434Ab0B0MEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 07:04:45 -0500
In-Reply-To: <201002271259.31596.bzolnier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Date: Sat, 27 Feb 2010 12:59:31 +0100

> Having IOMMU (even if it is only a software one, i.e. this would
> mean swiotlb for x86-32/highmem) always in place would simplify
> things greatly..

I agree, things would be a lot simpler.
