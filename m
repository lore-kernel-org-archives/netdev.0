From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [2.6 PATCH] IPV6: Check length of optval provided by user in
 setsockopt()
Date: Fri, 11 Apr 2008 16:15:44 +0900 (JST)
Message-ID: <20080411.161544.75421417.yoshfuji@linux-ipv6.org>
References: <47F0C101.9090302@cn.fujitsu.com>
	<20080331.195323.83430743.yoshfuji@linux-ipv6.org>
	<47F97BEF.2070205@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33260 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755166AbYDKHOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 03:14:00 -0400
In-Reply-To: <47F97BEF.2070205@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <47F97BEF.2070205@cn.fujitsu.com> (at Mon, 07 Apr 2008 09:42:07 +0800), Wang Chen <wangchen@cn.fujitsu.com> says:

> YOSHIFUJI Hideaki said the following on 2008-3-31 18:53:
> > POSIX, as we have some comments in that file ;-).
> > If it is shorter than expected, -EINVAL, otherwise, no error.
> > We need to fix other sites as well.
> > 
> 
> Check length of setsockopt's optval, which provided by user, before copy it
> from user space.
> For POSIX compliant, return -EINVAL for setsockopt of short lengths.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied, thanks.

--yoshfuji
