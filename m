From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV6]: dst_entry leak in ip4ip6_err. (resend)
Date: Mon, 18 Feb 2008 20:50:09 -0800 (PST)
Message-ID: <20080218.205009.116589985.davem@davemloft.net>
References: <1203325178.28825.5.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53671
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752644AbYBSEtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 23:49:32 -0500
In-Reply-To: <1203325178.28825.5.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Mon, 18 Feb 2008 11:59:38 +0300

> The result of the ip_route_output is not assigned to skb. This means that
> - it is leaked
> - possible OOPS below dereferrencing skb->dst
> - no ICMP message for this case
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

This bug has been there for a few releases :-)

Applied and I'll queue this up for -stable too.

Thanks!
