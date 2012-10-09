From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] pktgen: set different default min_pkt_size for
 different protocols
Date: Tue, 09 Oct 2012 13:55:31 -0400 (EDT)
Message-ID: <20121009.135531.554326230925730938.davem@davemloft.net>
References: <1349777131-4425-1-git-send-email-amwang@redhat.com>
	<1349777131-4425-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39457 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752195Ab2JIRzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 13:55:33 -0400
In-Reply-To: <1349777131-4425-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue,  9 Oct 2012 18:05:28 +0800

> ETH_ZLEN is too small for IPv6, so this default value is not
> suitable.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

pkt_dev->max_pkt_size is no longer being initialized.

At least set it to whatever you compute in pkt_dev->min_pkt_size
