From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: IPV6 stateless address autoconfiguration
Date: Thu, 15 May 2008 17:10:24 +0900 (JST)
Message-ID: <20080515.171024.120368160.yoshfuji@linux-ipv6.org>
References: <BECE1C148A85274EB554378A3E0EDF4906388E17@USA0300MS02.na.xerox.net>
	<20080513.104215.82952085.yoshfuji@linux-ipv6.org>
	<BECE1C148A85274EB554378A3E0EDF490642ED58@USA0300MS02.na.xerox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Joseph.Bonitch@xerox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44207 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754797AbYEOIKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 04:10:06 -0400
In-Reply-To: <BECE1C148A85274EB554378A3E0EDF490642ED58@USA0300MS02.na.xerox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <BECE1C148A85274EB554378A3E0EDF490642ED58@USA0300MS02.na.xerox.net> (at Wed, 14 May 2008 16:05:08 -0400), "Bonitch, Joseph" <Joseph.Bonitch@xerox.com> says:

> I tested your latest patch to addrconf.c.  It worked but I still had the
> problem that the prefix routes had an expiry time until the second
> RA was received.
> 
> I tracked it down to ip6_route_add() inside route.c: lifetime passed
> in was not checked for 0.  I made a minor change (see below) and
> now it is working as expected.

Okay, thank you.  I'll send the final version soon.

--yoshfuji
