From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] veth: fix 64bit stats on 32bit arches
Date: Sun, 19 Jun 2011 22:48:42 -0700 (PDT)
Message-ID: <20110619.224842.1099321143557842624.davem@davemloft.net>
References: <1308548772.3539.121.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43013 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489Ab1FTFsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 01:48:45 -0400
In-Reply-To: <1308548772.3539.121.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 Jun 2011 07:46:12 +0200

> Using 64bit stats on 32bit arches must use a synchronization or readers
> can get transient values.
> 
> Fixes bug introduced in commit 6311cc44a2 (veth: convert to 64 bit
> statistics)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
