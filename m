From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] korina: add error-handling to korina_alloc_ring
Date: Thu, 13 Aug 2009 16:27:43 -0700 (PDT)
Message-ID: <20090813.162743.29979567.davem@davemloft.net>
References: <20090812222249.39EAB4CEAA@orbit.nwl.cc>
	<20090812225234.82E6E4CEAA@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	florian@openwrt.org, roel.kluin@gmail.com
To: n0-1@freewrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56557
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756477AbZHMX1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 19:27:33 -0400
In-Reply-To: <20090812225234.82E6E4CEAA@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <n0-1@freewrt.org>
Date: Thu, 13 Aug 2009 00:52:32 +0200

> This also avoids a potential buffer overflow in case the very first
> receive descriptor fails to allocate, as an index of -1 would be used
> afterwards. Kudos to Roel Kluin for pointing this out and providing an
> initial patch.
> 
> Signed-off-by: Phil Sutter <n0-1@freewrt.org>

Applied to net-next-2.6
