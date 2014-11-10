From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] cxgb4/cxgb4vf: Misc. fixes for cxgb4vf
Date: Mon, 10 Nov 2014 14:15:53 -0500 (EST)
Message-ID: <20141110.141553.69503749630771413.davem@davemloft.net>
References: <1415360191-25395-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46941 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbaKJTP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 14:15:58 -0500
In-Reply-To: <1415360191-25395-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Fri,  7 Nov 2014 17:06:28 +0530

> For T5 use Packing and Padding Boundaries for SGE DMA transfers, move
> fl_starve_thres to adpater structure, since they are different for each
> adapter. The cxgb4vf driver's Free List Starvation Threshold needs to be larger
> than the SGE's Egress Congestion Threshold or we'll end up in a mutual stall
> where the driver waits for Ingress Packets to drive replacing Free List
> Pointers and the SGE waits for Free List Pointers before pushing Ingress
> Packets to the host.
> 
> The patches series is created against 'net' tree.
> And includes patches on cxgb4 and cxgb4vf driver.
> 
> We have included all the maintainers of respective drivers. Kindly review the
> change and let us know in case of any review comments.

Series applied, thanks.
