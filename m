From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] vxlan: Allow setting destination to unicast address.
Date: Mon, 15 Apr 2013 15:49:12 -0400 (EDT)
Message-ID: <20130415.154912.544691845102828799.davem@davemloft.net>
References: <87hajcm7ym.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	xiyou.wangcong@gmail.com
To: atzm@stratosphere.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753161Ab3DOTtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 15:49:15 -0400
In-Reply-To: <87hajcm7ym.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atzm Watanabe <atzm@stratosphere.co.jp>
Date: Fri, 12 Apr 2013 18:09:05 +0900

> This patch allows setting VXLAN destination to unicast address.
> It allows that VXLAN can be used as peer-to-peer tunnel without
> multicast.
> 
> v3: move a new attribute REMOTE into the last of an enum list
>     based by Stephen Hemminger's comments.
> 
> v2: use a new attribute REMOTE instead of GROUP based by
>     Cong Wang's comments.
> 
> Signed-off-by: Atzm Watanabe <atzm@stratosphere.co.jp>

Can someone familiar with the semantics and goals of vxlan please
review this patch?

Thanks.
