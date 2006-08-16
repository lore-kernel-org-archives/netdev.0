From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: Wed, 16 Aug 2006 02:40:08 -0700 (PDT)
Message-ID: <20060816.024008.74744877.davem@davemloft.net>
References: <20060816091029.GA6375@infradead.org>
	<20060816093159.GA31882@2ka.mipt.ru>
	<20060816093837.GA11096@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, arnd@arndb.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:27856
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751066AbWHPJky (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 05:40:54 -0400
To: hch@infradead.org
In-Reply-To: <20060816093837.GA11096@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 16 Aug 2006 10:38:37 +0100

> We could, but I'd rather waste 4 bytes in struct net_device than
> having such ugly warts in common code.

Why not instead have struct device store some default node value?
The node decision will be sub-optimal on non-pci but it won't crash.
