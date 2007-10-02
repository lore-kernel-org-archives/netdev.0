From: lm@bitmover.com (Larry McVoy)
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 15:36:44 -0700
Message-ID: <20071002223644.GA14331@bitmover.com>
References: <20071002212608.GG29944@bitmover.com> <20071002.144709.123999983.davem@davemloft.net> <4702C37F.4030601@hp.com> <20071002.153216.82129058.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rick.jones2@hp.com, lm@bitmover.com, torvalds@linux-foundation.org,
	herbert@gondor.apana.org.au, wscott@bitmover.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.bitmover.com ([192.132.92.15]:44075 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752116AbXJBWgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 18:36:44 -0400
Content-Disposition: inline
In-Reply-To: <20071002.153216.82129058.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 02, 2007 at 03:32:16PM -0700, David Miller wrote:
> I'm starting to have a theory about what the bad case might
> be.
> 
> A strong sender going to an even stronger receiver which can
> pull out packets into the process as fast as they arrive.
> This might be part of what keeps the receive window from
> growing.

I can back you up on that.  When I straced the receiving side that goes
slowly, all the reads were short, like 1-2K.  The way that works the 
reads were a lot larger as I recall.
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
