From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: Fix ip-header identification for gso packets.
Date: Sun, 24 Mar 2013 17:13:45 -0400 (EDT)
Message-ID: <20130324.171345.2090371435636317842.davem@davemloft.net>
References: <1364098248-1766-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754161Ab3CXVNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 17:13:46 -0400
In-Reply-To: <1364098248-1766-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Sat, 23 Mar 2013 21:10:48 -0700

> For TCP protocol ip-header id needs to be incremented even if
> IP_DF flag is set. This behaviour was changed in commit
> 490ab08127cebc25e3a26 (IP_GRE: Fix IP-Identification).
> 
> Following patch fixes it so that identification is always
> incremented for TCP.
> 
> Reported-by: Cong Wang <amwang@redhat.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

We should do this increment for all protocols when DF is set,
not just TCP.
