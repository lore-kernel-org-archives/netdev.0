From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/6] net: Alloc NAPI page frags from their own
 pool
Date: Wed, 10 Dec 2014 13:32:24 -0500 (EST)
Message-ID: <20141210.133224.1257543275995778285.davem@davemloft.net>
References: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@plumgrid.com, eric.dumazet@gmail.com,
	brouer@redhat.com
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46525 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932479AbaLJSc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 13:32:28 -0500
In-Reply-To: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Tue, 09 Dec 2014 19:40:35 -0800

> This patch series implements a means of allocating page fragments without
> the need for the local_irq_save/restore in __netdev_alloc_frag.  By doing
> this I am able to decrease packet processing time by 11ns per packet in my
> test environment.

Looks great, series applied, thanks Alex.
