From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: Don't allocate adapter structure for all
 PF's
Date: Mon, 15 Sep 2014 17:43:21 -0400 (EDT)
Message-ID: <20140915.174321.1346937613262227470.davem@davemloft.net>
References: <1410816526-19355-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40218 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754195AbaIOVnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:43:24 -0400
In-Reply-To: <1410816526-19355-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue, 16 Sep 2014 02:58:46 +0530

> commit 35b1de557970 ("rdma/cxgb4: Fixes cxgb4 probe failure in VM when PF is
> exposed through PCI Passthrough") moved the code to check for SR-IOV PF[0..3]
> much further down in init_one() past the point where we allocate a (struct
> adapter) for PF[0..3]. As a result, we left four of these on ever module remove.
> 
> Fix: Allocate adapter structure only for PF4
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied.
