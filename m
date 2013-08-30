From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qdisc: allow setting default queuing
 discipline
Date: Thu, 29 Aug 2013 22:23:48 -0400 (EDT)
Message-ID: <20130829.222348.1264641492942426245.davem@davemloft.net>
References: <20130827161908.26062336@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113Ab3H3CXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 22:23:54 -0400
In-Reply-To: <20130827161908.26062336@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 27 Aug 2013 16:19:08 -0700

> By default, the pfifo_fast queue discipline has been used by default
> for all devices. But we have better choices now.
> 
> This patch allow setting the default queueing discipline with sysctl.
> This allows easy use of better queueing disciplines on all devices
> without having to use tc qdisc scripts. It is intended to allow
> an easy path for distributions to make fq_codel or sfq the default
> qdisc.
> 
> This patch also makes pfifo_fast more of a first class qdisc, since
> it is now possible to manually override the default and explicitly
> use pfifo_fast. The behavior for systems who do not use the sysctl
> is unchanged, they still get pfifo_fast
> 
> Also removes leftover random # in sysctl net core.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks Stpehen.
