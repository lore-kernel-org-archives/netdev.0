From: David Miller <davem@davemloft.net>
Subject: Re: v4 [PATCH 2/9] bonding: Check return of
 dev_set_promiscuity/allmulti
Date: Mon, 14 Jul 2008 20:51:44 -0700 (PDT)
Message-ID: <20080714.205144.39453296.davem@davemloft.net>
References: <487C0ABA.1070506@cn.fujitsu.com>
	<487C1284.1060605@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46511
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753921AbYGODvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 23:51:44 -0400
In-Reply-To: <487C1284.1060605@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Tue, 15 Jul 2008 10:59:16 +0800

> dev_set_promiscuity/allmulti might overflow.
> Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
> dev_set_promiscuity/allmulti return error number if overflow happened.
> 
> In bond_alb and bond_main, we check all positive increment for promiscuity
> and allmulti to get error return.
> But there are still two problems left.
> 1. Some code path has no mechanism to signal errors upstream.
> 2. If there are multi slaves, it's hard to tell which slaves increment
>    promisc/allmulti successfully and which failed.
> So I left these problems to be FIXME.
> Fortunately, the overflow is very rare case.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.
