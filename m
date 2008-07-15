From: David Miller <davem@davemloft.net>
Subject: Re: v4 [PATCH 4/9] ipv6: Check return of dev_set_allmulti
Date: Mon, 14 Jul 2008 20:54:32 -0700 (PDT)
Message-ID: <20080714.205432.42854585.davem@davemloft.net>
References: <487C0ABA.1070506@cn.fujitsu.com>
	<487C128D.4070605@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48633
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752692AbYGODyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 23:54:31 -0400
In-Reply-To: <487C128D.4070605@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Tue, 15 Jul 2008 10:59:25 +0800

> allmulti might overflow.
> Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
> dev_set_promiscuity/allmulti return error number if overflow happened.
> 
> Here, we check the positive increment for allmulti to get error return.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> Acked-by: Patrick McHardy <kaber@trash.net> 

Applied.
