From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] sunvnet: Schedule maybe_tx_wakeup as a
 tasklet from ldc_rx path
Date: Tue, 12 Aug 2014 23:11:04 -0700 (PDT)
Message-ID: <20140812.231104.1011316861471226204.davem@davemloft.net>
References: <8BE2AE04-EF39-45A0-9AB4-15F5160C1449@oracle.com>
	<20140812.222941.2255442432293393813.davem@davemloft.net>
	<FBAD5ADB-C4DB-40A9-975F-F2E1304AB2DC@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org
To: Raghuram.Kothakota@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41749 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbaHMGLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 02:11:12 -0400
In-Reply-To: <FBAD5ADB-C4DB-40A9-975F-F2E1304AB2DC@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Date: Tue, 12 Aug 2014 22:44:27 -0700

> Thanks, if there is a method to accomplish this with multiple Tx netdev queues
> would be wonderful. We will research on the custom ndo_selec_queue()
> method to direct traffic automatically at the network stack level.
> We probably also need to look for methods to increase parallelism to boost
> performance, I assume multiple Tx queues would be a method to accomplish
> that as well.

It will introduce parallelism only when there is traffic to multiple
peers at the same time.
