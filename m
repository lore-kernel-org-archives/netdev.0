From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] openvswitch: Make IPv6 packet parsing dependent on
 IPv6 config
Date: Sun, 18 Nov 2012 02:34:55 -0500 (EST)
Message-ID: <20121118.023455.254802182635926499.davem@davemloft.net>
References: <20121116.135341.453792886356015492.davem@davemloft.net>
	<1353094881-28867-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com, dev@openvswitch.org,
	fengguang.wu@intel.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485Ab2KRHe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Nov 2012 02:34:57 -0500
In-Reply-To: <1353094881-28867-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Fri, 16 Nov 2012 14:41:21 -0500

> Ok.  How about this approach instead.  This keeps core functions we need
> still dependent on CONFIG_NET and makes new GSO stuff depend on CONFIG_INET
> since its quite useless without CONFIG_INET anyway...
 ...
> Subject: [PATCH] ipv6: Preserve ipv6 functionality needed by NET
> 
> Some pieces of network use core pieces of IPv6 stack.  Keep
> them available while letting new GSO offload pieces depend
> on CONFIG_INET.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Looks good, applied, thanks Vlad.
