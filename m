From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Sat, 26 Apr 2008 14:56:11 +0900 (JST)
Message-ID: <20080426.145611.18597942.yoshfuji@linux-ipv6.org>
References: <OF326F3AF9.7322F5FB-ON88257437.00174874-88257437.00194F7B@us.ibm.com>
	<20080426.135337.101775890.yoshfuji@linux-ipv6.org>
	<20080425.223236.81693355.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33787 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbYDZF4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 01:56:15 -0400
In-Reply-To: <20080425.223236.81693355.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080425.223236.81693355.davem@davemloft.net> (at Fri, 25 Apr 2008 22:32:36 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> Date: Sat, 26 Apr 2008 13:53:37 +0900 (JST)
> 
> > In article <OF326F3AF9.7322F5FB-ON88257437.00174874-88257437.00194F7B@us.ibm.com> (at Fri, 25 Apr 2008 21:36:29 -0700), David Stevens <dlstevens@us.ibm.com> says:
> > 
> > > > net/compat.c is not the right place.
> > > > Please put this in net/ipv4/compat.c or so.
> > > > Or at least, these must be guarded by CONFIG_INET.
> > > 
> > >         This code is for both v4 and v6, so I'd rather it not be in
> > > net/ipv4/compat.c. I didn't try without CONFIG_INET, -- will look
> > > at that.
> > 
> > We've been putting ipv4/ipv6 common things in net/ipv4/*.c,
> > so please put it in net/ipv4/compat.c.
> 
> I see no reason not to put this in net/compat.c, it's acting
> like fs/compat_ioctl.c which even has networking compat
> ioctls implemented there, among other things ;-)

Okay

--yoshfuji
