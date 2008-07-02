From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: v2 [PATCH net-next 2/7] bonding: Check return of dev_set_promiscuity/allmulti
Date: Wed, 02 Jul 2008 16:15:06 +0800
Message-ID: <486B390A.3000003@cn.fujitsu.com>
References: <4869A251.108@cn.fujitsu.com> <4869A331.3080902@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, NETDEV <netdev@vger.kernel.org>,
	fubar@us.ibm.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51592 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752586AbYGBITk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 04:19:40 -0400
In-Reply-To: <4869A331.3080902@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen said the following on 2008-7-1 11:23:
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

I've checked this one, all the unwind jobs, which can be done, were done.

