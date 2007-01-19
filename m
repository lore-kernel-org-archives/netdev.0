From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [IPV6] fixed the size of the netlink message notified
 by inet6_rt_notify().
Date: Fri, 19 Jan 2007 13:26:40 +0900 (JST)
Message-ID: <20070119.132640.107067447.yoshfuji@linux-ipv6.org>
References: <20070117105006.GV8693@postel.suug.ch>
	<45AE1792.1010002@trash.net>
	<20070119.013108.465780507.takamiya@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, tgraf@suug.ch, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:46301 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964817AbXASEZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jan 2007 23:25:35 -0500
To: takamiya@linux-ipv6.org
In-Reply-To: <20070119.013108.465780507.takamiya@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070119.013108.465780507.takamiya@linux-ipv6.org> (at Fri, 19 Jan 2007 01:31:08 +0900 (JST)), Noriaki TAKAMIYA <takamiya@linux-ipv6.org> says:

> >> Wed, 17 Jan 2007 13:33:22 +0100
> >> [Subject: Re: [PATCH] [IPV6] fixed the size of the netlink message notified by inet6_rt_notify().]
> >> Patrick McHardy <kaber@trash.net> wrote...
> 
> > Somewhat related: I have this patch for 2.6.21 to get rid of the
> > BUG_ON()s.
> 
>   I think the problem is the return value of inet6_rt_notify() is less
>   than expected.

I guess Patrick meant that using "BUG_ON()" would be an overkill.

--yoshfuji
