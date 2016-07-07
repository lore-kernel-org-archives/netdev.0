From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RFC net-next 0/4] net: support MPLS in IPv4 and UDP
Date: Wed, 06 Jul 2016 22:12:10 -0700 (PDT)
Message-ID: <20160706.221210.1403622241212743732.davem@davemloft.net>
References: <1467829355-4498-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41788 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208AbcGGFMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 01:12:20 -0400
In-Reply-To: <1467829355-4498-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Wed,  6 Jul 2016 20:22:31 +0200

> This short series provides support for MPLS in IPv4 (RFC4023), and by
> virtue of FOU, MPLS in UDP (RFC7510).
> 
> The changes are as follows:
> 1. Teach tunnel4.c about AF_MPLS, it already understands AF_INET and
>    AF_INET6
> 2. Enhance IPIP and SIT to handle MPLS. Both already handle IPv4.
>    SIT also already handles IPv6.
> 3. Trivially enhance MPLS to allow routes over SIT and IPIP tunnels.
> 
> A corresponding iproute2 patchset will also be posted.

Other than the protocol value test logic problem in patch #2, this looks
fine to me.
