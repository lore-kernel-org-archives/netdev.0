From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 04/05] ipv6: RFC4214 Support
Date: Thu, 08 Nov 2007 23:26:40 +0900 (JST)
Message-ID: <20071108.232640.62039057.yoshfuji@linux-ipv6.org>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF3@XCH-NW-7V2.nw.nos.boeing.com>
	<20071107104524.2bd738cb@freepuppy.rosehill>
	<39C363776A4E8C4A94691D2BD9D1C9A1029EDBF5@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: Fred.L.Templin@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:39743 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753972AbXKHO0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 09:26:36 -0500
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF5@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF5@XCH-NW-7V2.nw.nos.boeing.com> (at Wed, 7 Nov 2007 11:12:47 -0800), "Templin, Fred L" <Fred.L.Templin@boeing.com> says:

> > > The goal was to avoid requiring changes to applications such as
> > > 'iproute2', i.e., the intention was for a standalone code 
> > insertion point
> > > within the kernel itself. What do you suggest?
> > 
> > Agreed, magic names are evil.
> > 
> > Change iproute2 utilities, if it is more logical for administration.
> 
> This being an experimental release, I would prefer to go
> forward with a standalone kernel solution for the first
> iteration then come back with the iproute2 changes at a
> later time. IMHO, we should only touch iproute2 once, and
> it should be an architected solution - not just a quick
> hack. For the short term, timeliness of interoperability testing
> with the other major OS's should be the highest priority, IMHO.

Hmm, what is missing from API POV?

Since even if you do not change iproute2 now, users may need
to change their configuration script twice anyway, we should
be careful.

--yoshfuji
