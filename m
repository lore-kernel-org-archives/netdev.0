From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: Fix net exit.
Date: Fri, 20 Feb 2015 15:32:35 -0500 (EST)
Message-ID: <20150220.153235.1956277452015954678.davem@davemloft.net>
References: <1424200990-1558-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, amuller@redhat.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46096 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754891AbbBTUch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 15:32:37 -0500
In-Reply-To: <1424200990-1558-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue, 17 Feb 2015 11:23:10 -0800

> Open vSwitch allows moving internal vport to different namespace
> while still connected to the bridge. But when namespace deleted
> OVS does not detach these vports, that results in dangling
> pointer to netdevice which causes kernel panic as follows.
> This issue is fixed by detaching all ovs ports from the deleted
> namespace at net-exit.
 ...
> Reported-by: Assaf Muller <amuller@redhat.com>
> Fixes: 46df7b81454("openvswitch: Add support for network namespaces.")
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied and queued up for -stable, thanks.
