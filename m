From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/2] IPV6: remove addresses and routes when carrier is
 lost
Date: Wed, 04 Jun 2008 02:28:36 +0900 (JST)
Message-ID: <20080604.022836.31952523.yoshfuji@linux-ipv6.org>
References: <20080604.011717.77875207.yoshfuji@linux-ipv6.org>
	<20080603102144.571df55b@extreme>
	<20080603.102501.193702820.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58029 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753215AbYFCR2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 13:28:00 -0400
In-Reply-To: <20080603.102501.193702820.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080603.102501.193702820.davem@davemloft.net> (at Tue, 03 Jun 2008 10:25:01 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Tue, 3 Jun 2008 10:21:44 -0700
> 
> > The patch just makes carrier_off respond the same as doing 'ip link set dev eth0 down'
> > (or ifconfig eth0 down). A router needs to be able to re-route when link fails.
> 
> But I can't see how this behavior makes sense for the normal desktop case
> and it disagrees with existing practice for many years.
> 
> If I pull out my network cable while making some adjustments in my
> rack, and then plug it back in, I don't expect to lose my static
> routes on that interface.
> 
> That doesn't make any sense at all.

How about ignoring routes via down interface?

--yoshfuji
