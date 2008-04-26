From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Fri, 25 Apr 2008 22:32:36 -0700 (PDT)
Message-ID: <20080425.223236.81693355.davem@davemloft.net>
References: <20080426.123359.14563419.yoshfuji@linux-ipv6.org>
	<OF326F3AF9.7322F5FB-ON88257437.00174874-88257437.00194F7B@us.ibm.com>
	<20080426.135337.101775890.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53434
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751701AbYDZFch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 01:32:37 -0400
In-Reply-To: <20080426.135337.101775890.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Sat, 26 Apr 2008 13:53:37 +0900 (JST)

> In article <OF326F3AF9.7322F5FB-ON88257437.00174874-88257437.00194F7B@us.ibm.com> (at Fri, 25 Apr 2008 21:36:29 -0700), David Stevens <dlstevens@us.ibm.com> says:
> 
> > > net/compat.c is not the right place.
> > > Please put this in net/ipv4/compat.c or so.
> > > Or at least, these must be guarded by CONFIG_INET.
> > 
> >         This code is for both v4 and v6, so I'd rather it not be in
> > net/ipv4/compat.c. I didn't try without CONFIG_INET, -- will look
> > at that.
> 
> We've been putting ipv4/ipv6 common things in net/ipv4/*.c,
> so please put it in net/ipv4/compat.c.

I see no reason not to put this in net/compat.c, it's acting
like fs/compat_ioctl.c which even has networking compat
ioctls implemented there, among other things ;-)
