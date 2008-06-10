From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC][PATCH 3/3] IPv4:Check IP_MULTICAST_LOOP option value
Date: Tue, 10 Jun 2008 17:42:02 +0900 (JST)
Message-ID: <20080610.174202.32087382.yoshfuji@linux-ipv6.org>
References: <484E3293.8000507@cn.fujitsu.com>
	<20080610.171527.86317043.yoshfuji@linux-ipv6.org>
	<484E3C0A.1000808@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:59259 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696AbYFJIlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 04:41:19 -0400
In-Reply-To: <484E3C0A.1000808@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <484E3C0A.1000808@cn.fujitsu.com> (at Tue, 10 Jun 2008 16:32:10 +0800), Shan Wei <shanwei@cn.fujitsu.com> says:

> YOSHIFUJI Hideaki / 吉藤英明 写道:
> > In article <484E3293.8000507@cn.fujitsu.com> (at Tue, 10 Jun 2008 15:51:47 +0800), Shan Wei <shanwei@cn.fujitsu.com> says:
> > 
> >> The IP_MULTICAST_LOOP option can only be set with o or 1. When 
> >> other valuse are set, the kernel should return an error of EINVAL.
> >>
> >> In addition, the option should not be uesd by SOCK_STREAM type,
> >> same as IP_MULTICAST_IF, IP_MULTICAST_TTL.
> >>   
> >> But the kernel doesn't check them.
> > 
> > Is there any standard reference about this?
> > 
> I have not found it.
> But, the IP_MULTICAST_LOOP option is same as IPV6_MULTICAST_LOOP.

I disagree.
We follow what traditional BSDs do, and they do not check if the
value is 0 or 1 for IP_MULTICAST_LOOP.
On the other hand, they do for IPV6_MULTICAST_LOOP.

--yoshfuji
