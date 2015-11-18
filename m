From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/ip6_tunnel: fix dst leak
Date: Wed, 18 Nov 2015 16:26:07 -0500 (EST)
Message-ID: <20151118.162607.1152602905195888144.davem@davemloft.net>
References: <9dd416a82166a27f5cf5eda71a63222a0eb96c04.1447859978.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kafai@fb.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54181 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756394AbbKRV0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 16:26:09 -0500
In-Reply-To: <9dd416a82166a27f5cf5eda71a63222a0eb96c04.1447859978.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Wed, 18 Nov 2015 16:40:19 +0100

> the commit cdf3464e6c6b ("ipv6: Fix dst_entry refcnt bugs in ip6_tunnel")
> introduced percpu storage for ip6_tunnel dst cache, but while clearing
> such cache it used raw_cpu_ptr to walk the per cpu entries, so cached
> dst on non current cpu are not actually reset.
> 
> This patch replaces raw_cpu_ptr with per_cpu_ptr, properly cleaning
> such storage.
> 
> Fixes: cdf3464e6c6b ("ipv6: Fix dst_entry refcnt bugs in ip6_tunnel")
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied and queued up for -stable, thank you.
