From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] tipc: fix bug in broadcast synch message
 create function
Date: Wed, 29 Jul 2015 16:48:32 -0700 (PDT)
Message-ID: <20150729.164832.705060026020098916.davem@davemloft.net>
References: <1438208881-30453-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34971 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753800AbbG2Xsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 19:48:35 -0400
In-Reply-To: <1438208881-30453-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed, 29 Jul 2015 18:28:01 -0400

> In commit d999297c3dbbe7fdd832f7fa4ec84301e170b3e6
> ("tipc: reduce locking scope during packet reception") we introduced
> a new function tipc_build_bcast_sync_msg(), which carries initial
> synchronization data between two nodes at first contact and at
> re-contact. In this function, we missed to add synchronization data,
> with the effect that the broadcast link endpoints will fail to
> synchronize correctly at re-contact between a running and a restarted
> node. All other cases work as intended.
> 
> With this commit, we fix this bug.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks Jon.
