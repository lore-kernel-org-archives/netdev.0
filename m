From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/2] Remove dead code and replace byte-oder
 functions
Date: Tue, 19 May 2015 16:47:52 -0400 (EDT)
Message-ID: <20150519.164752.1499182180114852620.davem@davemloft.net>
References: <1432039844-23326-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48032 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274AbbESUry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 16:47:54 -0400
In-Reply-To: <1432039844-23326-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue, 19 May 2015 18:20:42 +0530

> This series removes dead fn t4_read_edc and t4_read_mc, also replaces
> ntoh{s,l} and hton{s,l} calls with the generic byteorder.
> 
> PATCH 2/2 was sent as a single PATCH, but had some byte-ordering issues
> in t4_read_edc and t4_read_mc function. Found that t4_read_edc and
> t4_read_mc is unused, so PATCH 1/2 is added to remove it.
> 
> This patch series is created against net-next tree and includes
> patches on cxgb4 driver.
> 
> We have included all the maintainers of respective drivers. Kindly review
> the change and let us know in case of any review comments.

Series applied, thanks.
