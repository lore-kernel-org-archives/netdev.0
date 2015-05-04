From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 0/3] Clean-up some bits related to netpoll
Date: Mon, 04 May 2015 00:07:13 -0400 (EDT)
Message-ID: <20150504.000713.94433995444786513.davem@davemloft.net>
References: <20150501173049.1029.54421.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	intel-wired-lan@lists.osuosl.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128AbbEDEHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 00:07:15 -0400
In-Reply-To: <20150501173049.1029.54421.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Fri, 01 May 2015 10:34:32 -0700

> This patch set cleans up some minor items related to netpoll.  The first
> patch addresses an Rx clean-up bug that is triggered due to an assumption
> that napi->poll wouldn't be called with a budget of 0.  The other two
> patches address dev_kfree_skb being called in the xmit path which isn't
> valid since netpoll will call ndo_start_xmit with IRQs disabled.

Series applied, thanks Alex.
