From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet6: Fix paramater issue of inet6_csk_xmit
Date: Thu, 31 Jul 2008 20:48:26 -0700 (PDT)
Message-ID: <20080731.204826.189988398.davem@davemloft.net>
References: <48918C49.4070708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36220
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752628AbYHADs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 23:48:26 -0400
In-Reply-To: <48918C49.4070708@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Thu, 31 Jul 2008 17:56:25 +0800

> inet6_csk_xmit() has a paramater ipfragok, but never pass to
> ip6_xmit(), always call it with ipfragok = 0.
> 
> This patch fixed this problem by instead 0 of ipfragok.
> 
> Compiled test only.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

I would like to see someone do some testing of this patch
before I apply it.
