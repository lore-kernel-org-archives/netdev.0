From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen: Error return off by one in
 'netxen_nic_set_pauseparam()'.
Date: Mon, 25 Jun 2012 15:27:20 -0700 (PDT)
Message-ID: <20120625.152720.464331582776852175.davem@davemloft.net>
References: <1340177259-14083-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sony.chacko@qlogic.com, rajesh.borundia@qlogic.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: santoshprasadnayak@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56171 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755941Ab2FYW1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 18:27:21 -0400
In-Reply-To: <1340177259-14083-1-git-send-email-santoshprasadnayak@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: santosh nayak <santoshprasadnayak@gmail.com>
Date: Wed, 20 Jun 2012 12:57:39 +0530

> From: Santosh Nayak <santoshprasadnayak@gmail.com>
> 
> There are 'NETXEN_NIU_MAX_GBE_PORTS'  GBE ports. Port indexing starts
> from zero. 
> Hence we should also return error for "port == NETXEN_NIU_MAX_GBE_PORTS"
> 
> Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>

Applied.
