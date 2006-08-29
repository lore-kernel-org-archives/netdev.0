From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH IPv6] Fix race condition in ipv6_add_addr
Date: Tue, 29 Aug 2006 18:21:28 +0900 (JST)
Message-ID: <20060829.182128.23425629.yoshfuji@linux-ipv6.org>
References: <20060829083536.GA10403@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, keir.fraser@cl.cam.ac.uk,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:64269 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932252AbWH2JTh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 05:19:37 -0400
To: okir@suse.de, davem@davemloft.net
In-Reply-To: <20060829083536.GA10403@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060829083536.GA10403@suse.de> (at Tue, 29 Aug 2006 10:35:36 +0200), Olaf Kirch <okir@suse.de> says:

> During stress testing, machines were frequently crashing in
> __ipv6_ifa_notify on dst_hold(&ifp->rt.u_dst), with ifp->rt being a
> NULL pointer.
> 
> The attached patch fixes the problem.

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
