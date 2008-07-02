From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: Do cleanup for ip_mr_init
Date: Wed, 02 Jul 2008 16:49:16 +0800
Message-ID: <486B410C.6020501@cn.fujitsu.com>
References: <48606D1B.3040507@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60907 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754320AbYGBIxz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 04:53:55 -0400
In-Reply-To: <48606D1B.3040507@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen said the following on 2008-6-24 11:42:
> If do not do it, we will get following issues:
> 1. Leaving junks after inet6_init failing halfway.
> 2. Leaving proc and notifier junks after ipv6 modules unloading.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> ---
>  include/linux/mroute6.h |    1 +
>  net/ipv6/af_inet6.c     |    5 +++++
>  net/ipv6/ip6mr.c        |   10 ++++++++++
>  3 files changed, 16 insertions(+), 0 deletions(-)

Yoshifuji-san, would please take a look at this patch.

