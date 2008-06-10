From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC][PATCH 2/3] IPv6:Check IPV6_MULTICAST_LOOP option value
Date: Tue, 10 Jun 2008 17:13:20 +0900 (JST)
Message-ID: <20080610.171320.54632523.yoshfuji@linux-ipv6.org>
References: <484E3277.5030808@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:59244 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756549AbYFJIMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 04:12:37 -0400
In-Reply-To: <484E3277.5030808@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <484E3277.5030808@cn.fujitsu.com> (at Tue, 10 Jun 2008 15:51:19 +0800), Shan Wei <shanwei@cn.fujitsu.com> says:

> RFC3493 says, IPV6_MULTICAST_LOOP option can only be set with o or 1.
> when other valuse are set, the kernel should return an error of EINVAL.
> 
> In addition, the option should not be uesd by SOCK_STREAM type, same as
> IPV6_MULTICAST_IF, IPV6_MULTICAST_HOPS.
>   
> But the kernel doesn't check them.

I'm goint to queue this with litle change.
Thanks.

--yoshfuji
