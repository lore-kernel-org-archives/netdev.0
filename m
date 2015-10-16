From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] ipv6: Initialize rt6_info properly in
 ip6_blackhole_route()
Date: Fri, 16 Oct 2015 00:39:47 -0700 (PDT)
Message-ID: <20151016.003947.1166514608710189826.davem@davemloft.net>
References: <1444952398-1505791-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51767 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222AbbJPHXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 03:23:39 -0400
In-Reply-To: <1444952398-1505791-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Thu, 15 Oct 2015 16:39:56 -0700

> This patchset ensures the rt6_info's fields are initialized properly
> in ip6_blackhole_route() where xfrm_policy is the primarily user.
> The first patch is a prep work.  The second patch is the fix.  It
> fixes d52d3997f843 ("ipv6: Create percpu rt6_info").
> 
> Here is the oops reported by Phil Sutter <phil@nwl.cc>:
 ...

Applied and queued up for -stable, thanks Martin.
