From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/01] ipv6: RFC4214 Support (v2.4)
Date: Tue, 20 Nov 2007 17:41:25 -0800 (PST)
Message-ID: <20071120.174125.222831634.davem@davemloft.net>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC2B@XCH-NW-7V2.nw.nos.boeing.com>
	<39C363776A4E8C4A94691D2BD9D1C9A1029EDC3F@XCH-NW-7V2.nw.nos.boeing.com>
	<20071120.173459.88096876.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	vladislav.yasevich@hp.com
To: Fred.L.Templin@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35629
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758263AbXKUBl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 20:41:26 -0500
In-Reply-To: <20071120.173459.88096876.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 20 Nov 2007 17:34:59 -0800 (PST)

> I think we've made Fred jump through enough hoops :-)
> I've added this to net-2.6.25, any fixups should be
> sent relative to this, thanks.

Actually, I'm reverting, the patch doesn't even compile:

net/ipv6/addrconf.c: In function 'ipv6_add_dev':
net/ipv6/addrconf.c:381: error: 'IFF_ISATAP' undeclared (first use in this function)
net/ipv6/addrconf.c:381: error: (Each undeclared identifier is reported only once
net/ipv6/addrconf.c:381: error: for each function it appears in.)
net/ipv6/addrconf.c: In function 'ipv6_generate_eui64':
net/ipv6/addrconf.c:1420: error: 'IFF_ISATAP' undeclared (first use in this function)
net/ipv6/addrconf.c: In function 'addrconf_sit_config':
net/ipv6/addrconf.c:2188: error: 'IFF_ISATAP' undeclared (first use in this function)

Please don't waste developer time like this, test the patches you
submit so that they at least apply cleanly _and_ compile.

Thanks.
