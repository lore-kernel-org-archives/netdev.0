From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] [ISDN]: Do not validate ISDN net device address
 prior to interface-up
Date: Sun, 13 Apr 2008 23:32:04 -0700 (PDT)
Message-ID: <20080413.233204.150014156.davem@davemloft.net>
References: <20080414060114.GA4016@ff.dom.local>
	<4802F24B.7060104@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, pebolle@tiscali.nl, netdev@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de, jgarzik@redhat.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56979
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752950AbYDNGcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 02:32:03 -0400
In-Reply-To: <4802F24B.7060104@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 14 Apr 2008 07:57:31 +0200

> Jarek Poplawski wrote:
> > Maybe I missed Patrick point, but it seems this patch isn't good:
> > it omits address validation hiding possible problems.
> The ISDN device's address is computed from the IP addresses
> in ->open(), so there is nothing to validate at the time
> eth_validate_addr() is called.

Right.
