From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] openvswitch: Respect conntrack zone even if
 invalid
Date: Fri, 11 Dec 2015 23:32:57 -0500 (EST)
Message-ID: <20151211.233257.727456278626170103.davem@davemloft.net>
References: <1449698860-20685-1-git-send-email-joe@ovn.org>
	<1449698860-20685-2-git-send-email-joe@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: joe@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60927 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754486AbbLLEdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 23:33:00 -0500
In-Reply-To: <1449698860-20685-2-git-send-email-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@ovn.org>
Date: Wed,  9 Dec 2015 14:07:40 -0800

> If userspace executes ct(zone=1), and the connection tracker determines
> that the packet is invalid, then the ct_zone flow key field is populated
> with the default zone rather than the zone that was specified. Even
> though connection tracking failed, this field should be updated with the
> value that the action specified. Fix the issue.
> 
> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
> Signed-off-by: Joe Stringer <joe@ovn.org>

Applied and queued up for -stable, thanks.
