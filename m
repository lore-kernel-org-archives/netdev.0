From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 07/12] bna: CQ Read Fix
Date: Sat, 14 Dec 2013 01:55:38 -0500 (EST)
Message-ID: <20131214.015538.1434478935532675070.davem@davemloft.net>
References: <1386899678-18591-1-git-send-email-rmody@brocade.com>
	<1386899678-18591-8-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@Brocade.COM
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48896 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077Ab3LNGzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 01:55:42 -0500
In-Reply-To: <1386899678-18591-8-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Thu, 12 Dec 2013 17:54:33 -0800

> Valid bit check for completion needs read fence, so that it does not get
> reordered with other loads.
> 
> Signed-off-by: Rasesh Mody <rmody@brocade.com>

All memory barriers added to code should have a big, verbose, comment
above it explaining exactly what the requirements are that will be
satisfied by the memory barrier.

Ie. what memory operation must be visible before or after what other
memory operation, and why?
