From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v2] packet: remove handling of tx_ring
Date: Tue, 23 Jun 2015 06:53:49 -0700 (PDT)
Message-ID: <20150623.065349.610373425224187451.davem@davemloft.net>
References: <1434956956-34121-1-git-send-email-maninder1.s@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, dborkman@redhat.com, al.drozdov@gmail.com,
	viro@zeniv.linux.org.uk, eyal.birger@gmail.com, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fransklaver@gmail.com, pankaj.m@samsung.com
To: maninder1.s@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33608 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754378AbbFWNmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 09:42:00 -0400
In-Reply-To: <1434956956-34121-1-git-send-email-maninder1.s@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maninder Singh <maninder1.s@samsung.com>
Date: Mon, 22 Jun 2015 12:39:16 +0530

> Remove handling of tx_ring in prb_setup_retire_blk_timer
> for TPACKET_V3 because init_prb_bdqc is called only for zero tx_ring 
> and thus prb_setup_retire_blk_timer for zero tx_ring only.
> 
> And also in functon init_prb_bdqc there is no usage of tx_ring.
> Thus removing tx_ring from init_prb_bdqc.
> 
> Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
> Suggested-by: Frans Klaver <fransklaver@gmail.com>

Applied to net-next, thanks.
