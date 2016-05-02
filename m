From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb3: fix out of bounds read
Date: Sun, 01 May 2016 21:00:00 -0400 (EDT)
Message-ID: <20160501.210000.607575204509045130.davem@davemloft.net>
References: <1461920810-15228-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, santosh@chelsio.com, jstancek@redhat.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53857 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752736AbcEBBAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 21:00:03 -0400
In-Reply-To: <1461920810-15228-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Fri, 29 Apr 2016 11:06:50 +0200

> An out of bounds read of 2 bytes was discovered in cxgb3 with KASAN.
> 
> t3_config_rss() expects both arrays it gets as parameters to have
> terminators. setup_rss(), the caller, forgets to add a terminator to
> one of the arrays. Thankfully the iteration in t3_config_rss() stops
> anyway, but in the last iteration the check for the terminator
> is an out of bounds read.
> 
> Add the missing terminator to rspq_map[].
> 
> Reported-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Applied.
