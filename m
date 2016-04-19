From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Mon, 18 Apr 2016 23:52:07 -0400 (EDT)
Message-ID: <20160418.235207.395468709808133833.davem@davemloft.net>
References: <1461015356.10638.124.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160418.205755.87909888849343438.davem@davemloft.net>
	<20160418.214851.122286645854721047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	jhs@mojatatu.com, tgraf@suug.ch, nicolas.dichtel@6wind.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58410 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137AbcDSDwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 23:52:10 -0400
In-Reply-To: <20160418.214851.122286645854721047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 18 Apr 2016 21:48:51 -0400 (EDT)

> I think the time has probably come to have a new netlink attribute
> format that doesn't have this multi-decade old problem.
 ...

Scratch this whole idea, I think the padding attribute works a lot
better and is backwards compatible with every properly written
netlink application.
