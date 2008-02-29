From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/12 net-2.6.26] icmp_socket namespacing
Date: Fri, 29 Feb 2008 11:23:11 -0800 (PST)
Message-ID: <20080229.112311.168388051.davem@davemloft.net>
References: <1204292360.10368.11.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43225
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756661AbYB2TXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 14:23:11 -0500
In-Reply-To: <1204292360.10368.11.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Fri, 29 Feb 2008 16:39:20 +0300

> This set of patches is targeted to create separate icmp_socket inside
> each namespace. Both IPv4 and IPv6 codepaths are affected.
> 
> Though, in order to do this smoothly, a bit of optimisations are
> performed. The kernel from now on will use sock rather than socket on
> the ICMP send path.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

I applied everything except the final patch #12.

I'll reply to that patch posting with my feedback.
