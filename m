From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ARC vmac ethernet driver.
Date: Mon, 22 Feb 2010 15:40:10 -0800 (PST)
Message-ID: <20100222.154010.149123575.davem@davemloft.net>
References: <1266798092-25938-1-git-send-email-andreas.fenkart@streamunlimited.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andreas.fenkart@streamunlimited.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43849
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755057Ab0BVXjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 18:39:52 -0500
In-Reply-To: <1266798092-25938-1-git-send-email-andreas.fenkart@streamunlimited.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Fenkart <andreas.fenkart@streamunlimited.com>
Date: Mon, 22 Feb 2010 01:21:32 +0100

>  drivers/net/arcvmac.h      |  122 ++++
>  drivers/net/arcvmac_fifo.h |  109 ++++

There is no reason to create a completely seperate header file just
for one DMA fifo data structure and a bunch of helper inline
functions.

Put this into arcvmac.h, thanks.
