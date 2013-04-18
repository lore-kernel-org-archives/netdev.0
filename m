From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use lockless genl.
Date: Thu, 18 Apr 2013 17:18:46 -0400 (EDT)
Message-ID: <20130418.171846.2215092862903415243.davem@davemloft.net>
References: <1366319812-16625-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, jesse@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57123 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968Ab3DRVTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 17:19:17 -0400
In-Reply-To: <1366319812-16625-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu, 18 Apr 2013 14:16:52 -0700

> OVS locking was recently changed to have private OVS lock which
> simplified overall locking.  Therefore there is no need to have
> another global genl lock to protect OVS data structures.  Following
> patch uses of lockless genl family for OVS.  This also allows
> more granual OVS locking using ovs_mutex for protecting OVS data
> structures, which gives more consurrencey.  E.g multiple genl
> operations OVS_PACKET_CMD_EXECUTE can run in parallel, etc.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Three problems with this submission:

1) When you resubmit a patch that's part of a series, you must repost
   the entire series.

2) When you post a new version of a patch, you must list (after the
   "---" delimiter) what has changed in this version.

3) When you post a new version of a patch, you must indicate this by
   putting "[PATCH v2 ...] ...", for example, in the Subject line.
