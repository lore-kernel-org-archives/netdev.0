From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4i : Fix -Wmaybe-uninitialized warning.
Date: Wed, 15 Oct 2014 12:14:12 -0400 (EDT)
Message-ID: <20141015.121412.2124734484633968051.davem@davemloft.net>
References: <1413358007-16980-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kxie@chelsio.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52108 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbaJOQOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 12:14:14 -0400
In-Reply-To: <1413358007-16980-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Wed, 15 Oct 2014 00:26:47 -0700

> Identified by kbuild test robot. csk family is always set to be AF_INET or 
> AF_INET6, so skb will always be initialized to some value but there is no harm 
> in silencing the warning anyways.
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>
> Fixes : f42bb57c61fd ('cxgb4i : Fix -Wunused-function warning')

Applied.
