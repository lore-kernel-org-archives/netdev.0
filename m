From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: addrconf: Avoid calling netdevice notifiers
 with RCU read-side lock
Date: Tue, 14 Aug 2012 17:02:57 -0700 (PDT)
Message-ID: <20120814.170257.442769610103100016.davem@davemloft.net>
References: <1344940096-5548-1-git-send-email-amwang@redhat.com>
	<1344970491.2690.8.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com,
	gregory.v.rose@intel.com, tgraf@suug.ch, edumazet@google.com,
	amwang@redhat.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39928 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754878Ab2HOADE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 20:03:04 -0400
In-Reply-To: <1344970491.2690.8.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 14 Aug 2012 19:54:51 +0100

> Cong Wang reports that lockdep detected suspicious RCU usage while
> enabling IPV6 forwarding:
 ...
> addrconf_forward_change() uses RCU iteration over the netdev list,
> which is unnecessary since it already holds the RTNL lock.  We also
> cannot reasonably require netdevice notifier functions not to sleep.
> 
> Reported-by: Cong Wang <amwang@redhat.com>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied and queued up for -stable, thanks Ben.
