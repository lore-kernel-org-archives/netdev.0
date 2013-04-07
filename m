From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] tcp: add a global sysctl to control TCP
 delayed ack
Date: Sun, 07 Apr 2013 17:09:58 -0400 (EDT)
Message-ID: <20130407.170958.338519719729552895.davem@davemloft.net>
References: <1365070560-11544-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, rick.jones2@hp.com,
	shemminger@vyatta.com, tgraf@suug.ch, David.Laight@ACULAB.COM
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58500 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934238Ab3DGVKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 17:10:00 -0400
In-Reply-To: <1365070560-11544-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Thu,  4 Apr 2013 18:16:00 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> Change from RFC:
> * make the sysctl per netns
> 
> According to previous discussion, it seems there is no
> reasonable heuristics.
> 
> Similar to TCP_QUICK_ACK option, but for people who can't
> modify the source code and still wants to control
> TCP delayed ACK behavior.
> 
> David, do you still have any objection?
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Rick Jones <rick.jones2@hp.com>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Thomas Graf <tgraf@suug.ch>
> CC: David Laight <David.Laight@ACULAB.COM>
> Signed-off-by: Cong Wang <amwang@redhat.com>

I'm not applying a patch that adds a global parameter for
an attribute which has per-path scope.
