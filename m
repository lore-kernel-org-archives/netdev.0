From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: Wed, 16 Aug 2006 02:05:03 -0700 (PDT)
Message-ID: <20060816.020503.74744144.davem@davemloft.net>
References: <20060816053545.GB22921@2ka.mipt.ru>
	<20060816084808.GA7366@infradead.org>
	<20060816090028.GA25476@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, arnd@arndb.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:35719
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751037AbWHPJFt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 05:05:49 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060816090028.GA25476@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Wed, 16 Aug 2006 13:00:31 +0400

> So I would like to know how to determine which node should be used for
> allocation. Changes of __get_user_pages() to alloc_pages_node() are
> trivial.

netdev_alloc_skb() knows the netdevice, and therefore you can
obtain the "struct device;" referenced inside of the netdev,
and therefore you can determine the node using the struct
device.

Christophe is working on adding support for this using existing
allocator.
