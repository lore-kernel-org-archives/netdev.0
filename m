From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 8/8] enic: do tx cleanup in napi poll
Date: Sun, 22 Jun 2014 13:16:28 -0700 (PDT)
Message-ID: <20140622.131628.2112570456050562317.davem@davemloft.net>
References: <1403077088-4818-9-git-send-email-_govind@gmx.com>
	<20140621.152440.2152576710542860161.davem@davemloft.net>
	<alpine.LNX.2.03.1406221250230.1311@ws.cisco>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48620 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbaFVUQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2014 16:16:31 -0400
In-Reply-To: <alpine.LNX.2.03.1406221250230.1311@ws.cisco>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Sun, 22 Jun 2014 12:55:30 +0530 (IST)

> So I should ignore the budget value and clean all packets
> possible. And what should the NAPIs return value should be? I can
> not be > 64 right?

Pretend there was no work to do, as if you didn't need to use any
of the quota.
