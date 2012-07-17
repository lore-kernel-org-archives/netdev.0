From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix unappropriate errno returned for
 non-multicast address
Date: Tue, 17 Jul 2012 01:35:29 -0700 (PDT)
Message-ID: <20120717.013529.750838300674618285.davem@davemloft.net>
References: <5005143B.9000301@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47767 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000Ab2GQIfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 04:35:30 -0400
In-Reply-To: <5005143B.9000301@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Tue, 17 Jul 2012 15:28:59 +0800

> We need to check the passed in multicast address and return
> appropriate errno(EINVAL) if it is not valid. And it's no need
> to walk through the ipv6_mc_list in this situation.
> 
> Signed-off-by: Li Wei <lw@cn.fujitsu.com>

Applied to net-next, thanks.
