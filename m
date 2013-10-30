From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: remove the unnecessary statement in find_match()
Date: Wed, 30 Oct 2013 22:11:57 +0100
Message-ID: <20131030211157.GA13902@order.stressinduktion.org>
References: <5270B7AE.9020801@cn.fujitsu.com> <20131030.170837.1882918923249091614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: duanj.fnst@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39656 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753027Ab3J3VL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 17:11:59 -0400
Content-Disposition: inline
In-Reply-To: <20131030.170837.1882918923249091614.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 30, 2013 at 05:08:37PM -0400, David Miller wrote:
> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> Date: Wed, 30 Oct 2013 15:39:26 +0800
> 
> > 
> > After reading the function rt6_check_neigh(), we can
> > know that the RT6_NUD_FAIL_SOFT can be returned only
> > when the IS_ENABLE(CONFIG_IPV6_ROUTER_PREF) is false.
> > so in function find_match(), there is no need to execute
> > the statement !IS_ENABLED(CONFIG_IPV6_ROUTER_PREF).
> > 
> > Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> 
> Applied to net-next, thanks.
> 
> CONFIG_IPV6_ROUTER_PREF is another good candidate for Kconfig
> removal.  I know we've had several bugs that only apply when
> this option is on vs. off.  We're maintaining two different
> code paths, for really no good reason.

I agree and actually thought about that yesterday. Do you think a sysctl
is a good option?
