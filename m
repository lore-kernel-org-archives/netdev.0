From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/2] IPv6: Fix the return value of get destination
 options with NULL data pointer
Date: Wed, 28 May 2008 21:07:22 +0900 (JST)
Message-ID: <20080528.210722.59120277.yoshfuji@linux-ipv6.org>
References: <483D1693.4080805@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@sunset.davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: yanghy@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53518 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbYE1MGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 08:06:51 -0400
In-Reply-To: <483D1693.4080805@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <483D1693.4080805@cn.fujitsu.com> (at Wed, 28 May 2008 16:23:47 +0800), Yang Hongyang <yanghy@cn.fujitsu.com> says:

> If we pass NULL data buffer to getsockopt(), it will return 0,
> and the option length is set to -EFAULT:
>     getsockopt(sk, IPPROTO_IPV6, IPV6_DSTOPTS, NULL, &len);
> 
> This is because ipv6_getsockopt_sticky() will return -EFAULT or
> -EINVAL if some error occur.
> 
> This patch fix this problem.

I'm going to apply this in my tree.  Thanks.

--yoshfuji
