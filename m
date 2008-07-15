From: David Miller <davem@davemloft.net>
Subject: Re: v4 [PATCH 9/9] 8021q: Check return of
 dev_set_promiscuity/allmulti
Date: Mon, 14 Jul 2008 21:00:56 -0700 (PDT)
Message-ID: <20080714.210056.47426171.davem@davemloft.net>
References: <487C0ABA.1070506@cn.fujitsu.com>
	<487C12A5.8010505@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47111
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750770AbYGOEAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 00:00:55 -0400
In-Reply-To: <487C12A5.8010505@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Tue, 15 Jul 2008 10:59:49 +0800

> dev_set_promiscuity/allmulti might overflow.
> Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
> dev_set_promiscuity/allmulti return error number if overflow happened.
> 
> Here, we check all positive increment for promiscuity and allmulti
> to get error return.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied.

But I had to apply this one also by hand, as it conflicted with
Patrick's GVRP changes already in the tree.

When you are maintaining a patch set like this, you have to update
your tree and regenerate your patches in order to make sure no new
conflicts exist before submitting your patches.

That part isn't my job :)

Thanks.
