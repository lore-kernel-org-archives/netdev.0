From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/01] ipv6: RFC4214 Support (v2.4)
Date: Tue, 20 Nov 2007 17:34:59 -0800 (PST)
Message-ID: <20071120.173459.88096876.davem@davemloft.net>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC29@XCH-NW-7V2.nw.nos.boeing.com>
	<39C363776A4E8C4A94691D2BD9D1C9A1029EDC2B@XCH-NW-7V2.nw.nos.boeing.com>
	<39C363776A4E8C4A94691D2BD9D1C9A1029EDC3F@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	vladislav.yasevich@hp.com
To: Fred.L.Templin@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53175
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751832AbXKUBfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 20:35:00 -0500
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC3F@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Date: Tue, 20 Nov 2007 09:36:26 -0800

> From: Fred L. Templin <fred.l.templin@boeing.com>
> 
> This patch includes support for the Intra-Site Automatic Tunnel
> Addressing Protocol (ISATAP) per RFC4214. It uses the SIT
> module, and is configured using extensions to the "iproute2"
> utility. The diffs are specific to the Linux 2.6.24-rc2 kernel
> distribution.
> 
> This version reflects changes based on netdev list discussions
> on 11/14/07 thru 11/15/07. It does away with in-the-kernel RS/RA
> pinging and now asks that the task be performed by an application.
> The application will essentially entail a port of the FreeBSD 'rtsold'
> daemon, and will use the standard socket API.
> 
> Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>

I think we've made Fred jump through enough hoops :-)
I've added this to net-2.6.25, any fixups should be
sent relative to this, thanks.

Although that default router lookup on every packet doesn't
look so cheap, I wonder if there is a less expensive way to
implement that bit.
