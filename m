From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 0/3] net: Alloc NAPI page frags from their own pool
Date: Tue, 02 Dec 2014 19:30:44 -0800 (PST)
Message-ID: <20141202.193044.1797294415230563067.davem@davemloft.net>
References: <20141126235900.1617.10008.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com,
	jeffrey.t.kirsher@intel.com, eric.dumazet@gmail.com,
	ast@plumgrid.com
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55959 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281AbaLCD0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 22:26:23 -0500
In-Reply-To: <20141126235900.1617.10008.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 26 Nov 2014 16:05:50 -0800

> This patch series implements a means of allocating page fragments without
> the need for the local_irq_save/restore in __netdev_alloc_frag.  By doing
> this I am able to decrease packet processing time by 11ns per packet in my
> test environment.

No fundamental objections from me.
