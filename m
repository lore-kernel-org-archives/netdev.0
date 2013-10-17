From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net bridge: remove unused field
Date: Thu, 17 Oct 2013 16:10:37 -0400 (EDT)
Message-ID: <20131017.161037.310607928835493105.davem@davemloft.net>
References: <525C5DED.1080406@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46840 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762520Ab3JQUKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 16:10:39 -0400
In-Reply-To: <525C5DED.1080406@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Mon, 14 Oct 2013 17:11:09 -0400

> Trivial patch

I know it seems rediculous, but anything we export to userspace, as we
do in this UAPI header, could be potentially be used by some piece of
source out there.

I'd rather just leave it be, you can add a comment saying it's unused
if you wish, but I'd really rather not remove it and run the risk of
breaking someone's build out there.

Thanks.
