From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Mon, 27 Aug 2007 14:11:50 -0700 (PDT)
Message-ID: <20070827.141150.59660845.davem@davemloft.net>
References: <1188212049.6756.18.camel@johannes.berg>
	<20070827.134131.41639376.davem@davemloft.net>
	<1188248263.18004.131.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59965
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754941AbXH0VLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2007 17:11:51 -0400
In-Reply-To: <1188248263.18004.131.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 27 Aug 2007 13:57:42 -0700

> On Mon, 2007-08-27 at 13:41 -0700, David Miller wrote:
> > From: Johannes Berg <johannes@sipsolutions.net>
> > Date: Mon, 27 Aug 2007 12:54:09 +0200
> > > #define MAC_FMT "%s"
> > > #define MAC_ARG(a) ({char __buf[18]; print_mac(a, __buf); __buf;})
> 
> > I don't think this works.
> 
> $ cat test_fmt.c
> #include <stdio.h>
> #include <stdlib.h>

You're just getting lucky in this test case.

The language does not allow what you are doing, so you're
playing with fire.
