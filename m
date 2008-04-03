From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [IPV6]: Event type in addrconf_ifdown is mis-used.
Date: Thu, 03 Apr 2008 13:33:56 -0700 (PDT)
Message-ID: <20080403.133356.257567635.davem@davemloft.net>
References: <1206259996.7528.12.camel@iris.sw.ru>
	<20080323.031724.208377895.davem@davemloft.net>
	<1206282899.7528.18.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, kaber@trash.net,
	containers@lists.osdl.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42018
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751262AbYDCUd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 16:33:56 -0400
In-Reply-To: <1206282899.7528.18.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Sun, 23 Mar 2008 17:34:59 +0300

> You are perfectly correct and the place in addrconf_cleanup is that
> place when we believe that we should destroy all the staff.
> 
> You see, it is pretty useless to call addrconf_ifdown(dev, 2) after
> addrconf_dev(dev, 0) for a loopback in the current code! No new cleanups
> will be performed for 2, pls check :)

I've rereviewed these three patches and I agree with your
assesment.

Therefore, I've applied these three patches to net-2.6 and
will push them out after some build validation.

Thanks!
