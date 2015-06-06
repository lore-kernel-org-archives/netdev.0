From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Fix static checker warning
Date: Fri, 05 Jun 2015 21:32:31 -0700 (PDT)
Message-ID: <20150605.213231.1340269654914172673.davem@davemloft.net>
References: <1433495193-8658-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60449 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbbFFEVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jun 2015 00:21:19 -0400
In-Reply-To: <1433495193-8658-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Fri,  5 Jun 2015 14:36:33 +0530

> The patch e85c9a7abfa4: ("cxgb4/cxgb4vf: Add code to calculate T5 BAR2
> Offsets for SGE Queue Registers") from Dec 3, 2014, leads to the
> following static checker warning:
> 
>         drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:5358
> 	t4_bar2_sge_qregs()
>         warn: should '(qid >> qpp_shift) << page_shift' be a 64 bit type?
> 
> This patch fixes it
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
