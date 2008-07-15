From: David Miller <davem@davemloft.net>
Subject: Re: v4 [PATCH 6/9] ipv4: Check return of dev_set_allmulti
Date: Mon, 14 Jul 2008 20:55:43 -0700 (PDT)
Message-ID: <20080714.205543.13885497.davem@davemloft.net>
References: <487C0ABA.1070506@cn.fujitsu.com>
	<487C1297.6080002@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48642
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754570AbYGODzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 23:55:42 -0400
In-Reply-To: <487C1297.6080002@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Tue, 15 Jul 2008 10:59:35 +0800

> allmulti might overflow.
> Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
> dev_set_promiscuity/allmulti return error number if overflow happened.
> 
> Here, we check the positive increment for allmulti to get error return.
> 
> PS: For unwinding tunnel creating, we let ipip->ioctl() to handle it.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Unwinding is ugly, but I can't suggest a better way right now :)

Applied, thanks.
