From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] bridge: per-vlan stats
Date: Fri, 29 Apr 2016 16:12:08 -0400 (EDT)
Message-ID: <20160429.161208.1214717753456694357.davem@davemloft.net>
References: <1461858771-4732-1-git-send-email-nikolay@cumulusnetworks.com>
	<20160429.153326.652947047579122837.davem@davemloft.net>
	<5723BABD.4080005@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, jhs@mojatatu.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55736 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752893AbcD2UMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 16:12:10 -0400
In-Reply-To: <5723BABD.4080005@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Fri, 29 Apr 2016 21:49:17 +0200

> Because that is not needed for the per-vlan stats to work, I did to
> unify the paths and simplify the pvid code but I can easily drop it
> and revert back to using the direct pvid id.  The only fetch will be
> the stats per-cpu pointer then. Would that be acceptable ?

It would be a step in the right direction, for sure.
