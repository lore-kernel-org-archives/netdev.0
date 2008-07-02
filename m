From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: v2 [PATCH net-next 3/7] bridge: Check return of dev_set_promiscuity
Date: Wed, 02 Jul 2008 16:15:54 +0800
Message-ID: <486B393A.5000205@cn.fujitsu.com>
References: <4869A251.108@cn.fujitsu.com> <4869A3A6.9010801@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, NETDEV <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59590 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752604AbYGBIU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 04:20:28 -0400
In-Reply-To: <4869A3A6.9010801@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen said the following on 2008-7-1 11:25:
> dev_set_promiscuity/allmulti might overflow.
> Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
> dev_set_promiscuity/allmulti return error number if overflow happened.
> 
> Here, we check the positive increment for promiscuity to get error return.
> 

Of course, I did the unwind job.

