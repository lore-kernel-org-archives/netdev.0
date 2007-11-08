From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/05] ipv6: RFC4214 Support
Date: Thu, 08 Nov 2007 15:30:21 -0800 (PST)
Message-ID: <20071108.153021.258449702.davem@davemloft.net>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF5@XCH-NW-7V2.nw.nos.boeing.com>
	<20071108.232640.62039057.yoshfuji@linux-ipv6.org>
	<39C363776A4E8C4A94691D2BD9D1C9A1029EDC09@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: Fred.L.Templin@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51070
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755943AbXKIBuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 20:50:23 -0500
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC09@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Date: Thu, 8 Nov 2007 13:01:34 -0800

> > Hmm, what is missing from API POV?
> 
> This would have to be determined under a follow-on project (hopefully
> with input from others) after we have gained operational experience.

I personally don't buy any of this desire to avoid iproute2
changes at this time.

This is never how we handle this kind of situation.

We add in the new feature, and add support to iproute2 in
parallel.  If we screw it up we figure that out quickly
and fix things before it's been deployed for too long.

I suspect you simply want users to just be able to use the
new feature with only a kernel patch, but that's not an
appropriate reason to not do things correctly when submitting
a feature upstream.

Please use the new name in the kernel side changes and implement
iproute2 support for these ISATAP devices.

Thank you.

