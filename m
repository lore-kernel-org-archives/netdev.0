From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/2] openvswitch: Use parallel_ops genl.
Date: Thu, 25 Apr 2013 01:43:34 -0400 (EDT)
Message-ID: <20130425.014334.2026442177034590153.davem@davemloft.net>
References: <1366739328-18224-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, jesse@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48350 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213Ab3DYFnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 01:43:35 -0400
In-Reply-To: <1366739328-18224-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue, 23 Apr 2013 10:48:48 -0700

> OVS locking was recently changed to have private OVS lock which
> simplified overall locking.  Therefore there is no need to have
> another global genl lock to protect OVS data structures.  Following
> patch uses of parallel_ops genl family for OVS.  This also allows
> more granual OVS locking using ovs_mutex for protecting OVS data
> structures, which gives more concurrencey.  E.g multiple genl
> operations OVS_PACKET_CMD_EXECUTE can run in parallel, etc.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied.
