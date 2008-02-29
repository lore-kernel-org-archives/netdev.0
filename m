From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/12 net-2.6.26] [ICMP6]: Consolidate fail path
 icmpv6_sk_init with icmpv6_sk_exit.
Date: Fri, 29 Feb 2008 11:23:42 -0800 (PST)
Message-ID: <20080229.112342.76764059.davem@davemloft.net>
References: <1204292360.10368.11.camel@iris.sw.ru>
	<1204292458-11636-12-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43228
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756372AbYB2TXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 14:23:43 -0500
In-Reply-To: <1204292458-11636-12-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Fri, 29 Feb 2008 16:40:58 +0300

> +static void __net_exit icmpv6_sk_exit(struct net *net)
> +{

Since you call this from __new_init code, won't this
create a section conflict when ipv6 is built statically
into the kernel?
