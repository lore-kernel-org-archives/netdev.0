From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] netfilter: Fix potential use after free in
 ip6_route_me_harder()
Date: Wed, 07 May 2014 17:12:23 -0400 (EDT)
Message-ID: <20140507.171223.1084178052085813237.davem@davemloft.net>
References: <1399389441-20095-1-git-send-email-popovich_sergei@mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: popovich_sergei@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51963 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111AbaEGVMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 17:12:25 -0400
In-Reply-To: <1399389441-20095-1-git-send-email-popovich_sergei@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergey Popovich <popovich_sergei@mail.ru>
Date: Tue,  6 May 2014 18:17:19 +0300

> Dst is released one line before we access it again with dst->error.
> 
> Fixes: 58e35d147128 netfilter: ipv6: propagate routing errors from
> ip6_route_me_harder()
> 
> Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>

Sergey, please do not submit patch series crossing multiple maintainers
(here Netfilter vs. generic networking) without first coordinating with
those maintainers as to who will take your entire series in.

Another option is to submit things in the usual manner, submit the
netfilter change to the netfilter maintainer, and then seperately
the other two patches to me.

I'm dropping these patches.
