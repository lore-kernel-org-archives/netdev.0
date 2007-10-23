From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] - trivial - Improve appletalk checksum calculation
Date: Mon, 22 Oct 2007 18:43:40 -0700 (PDT)
Message-ID: <20071022.184340.102771527.davem@davemloft.net>
References: <1193081779.5132.24.camel@localhost>
	<20071022.173545.74561992.davem@davemloft.net>
	<1193103388.5132.38.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60062
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751245AbXJWBnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 21:43:18 -0400
In-Reply-To: <1193103388.5132.38.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 22 Oct 2007 18:36:28 -0700

> On Mon, 2007-10-22 at 17:35 -0700, David Miller wrote:
> > Your code is rotating bit 15 down by one bit and bits 0-14 up by one
> > bit.
> 
> Yes, a 16 bit rotate left.
> 
> There was a discussion a few years ago:
> http://oss.sgi.com/archives/netdev/2003-10/msg00734.html
> 
> >From the spec:
 ...
> Reception of a datagram with CkSum equal to 0 implies that a checksum is
> not performed.

Ok, but again did you test it?
