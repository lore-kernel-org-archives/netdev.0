From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Thu, 24 Apr 2008 02:35:13 -0700 (PDT)
Message-ID: <20080424.023513.116464364.davem@davemloft.net>
References: <20080424.171644.106117727.yoshfuji@linux-ipv6.org>
	<20080424.014956.94335109.davem@davemloft.net>
	<20080424.182834.104940176.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34705
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751370AbYDXJfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 05:35:17 -0400
In-Reply-To: <20080424.182834.104940176.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Apr 2008 18:28:34 +0900 (JST)

> Most (if not all) compat_XXX{} do not have such attribute,
> and sockaddr_storage{} shuould actually be aligned on 32bit on
> 32bit archs, so I think we should declare, no?
> 
> For example, if we have
>     struct foobar {
>         char a;
>         struct sockaddr_storage b;
>     };
> Then, offsetof(struct foobar, b) should be 4, not 1 nor 2.
> (Of course all other fields of group_xxx structures are of
> u32 here, so it is safe so far...)

You're right, it seems the aligned(4) is the best way.
