From: David Miller <davem@davemloft.net>
Subject: Re: v4 [PATCH 3/9] bridge: Check return of dev_set_promiscuity
Date: Mon, 14 Jul 2008 20:54:02 -0700 (PDT)
Message-ID: <20080714.205402.165820617.davem@davemloft.net>
References: <487C0ABA.1070506@cn.fujitsu.com>
	<487C1288.2010202@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, shemminger@vyatta.com
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48629
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752515AbYGODyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 23:54:01 -0400
In-Reply-To: <487C1288.2010202@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Tue, 15 Jul 2008 10:59:20 +0800

> dev_set_promiscuity/allmulti might overflow.
> Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
> dev_set_promiscuity/allmulti return error number if overflow happened.
> 
> Here, we check the positive increment for promiscuity to get error return.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.

Although I had to apply this by hand since this wasn't generated
against the current tree which has the new dev_disable_lro() calls in
br.f
