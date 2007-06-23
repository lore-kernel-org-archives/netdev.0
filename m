From: David Miller <davem@davemloft.net>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS
 autoconfiguration
Date: Sat, 23 Jun 2007 13:41:21 -0700 (PDT)
Message-ID: <20070623.134121.35817571.davem@davemloft.net>
References: <200706230139.50064.mb@bu3sch.de>
	<c6d9bea0706221709h72dfa5bao7f51d4a611950094@mail.gmail.com>
	<200706231107.14649.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cscott@laptop.org, netdev@vger.kernel.org
To: mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52258
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750938AbXFWUlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 16:41:04 -0400
In-Reply-To: <200706231107.14649.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Buesch <mb@bu3sch.de>
Date: Sat, 23 Jun 2007 11:07:14 +0200

> Yeah, it might work. But I think the compiler doesn't guarantee
> you anything about it.

The compiler actually does guarentee these things, and that's why we
have the endian bitfield macros.  You're overreacting, we've
been using this stuff for more than 10 years in the basic
IPV4 header structure, so stop this nonsense.

