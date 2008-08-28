From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RDS: Add AF and PF defines for RDS sockets
Date: Thu, 28 Aug 2008 00:24:57 -0700 (PDT)
Message-ID: <20080828.002457.26700892.davem@davemloft.net>
References: <75428E88-423C-492F-AE72-3157D968DC04@holtmann.org>
	<20080825.212914.197506339.davem@davemloft.net>
	<1219907200.7107.228.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, andy.grover@oracle.com, netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60608
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752830AbYH1HZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 03:25:01 -0400
In-Reply-To: <1219907200.7107.228.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Thu, 28 Aug 2008 08:06:40 +0100

> On Mon, 2008-08-25 at 21:29 -0700, David Miller wrote:
> > From: Marcel Holtmann <marcel@holtmann.org>
> > Date: Tue, 26 Aug 2008 06:16:28 +0200
> > 
> > > and where is the protocol? Adding new constants without posting the
> > > implementation normally doesn't fly anymore.
> > 
> > That's correct :)
> 
> That's kind of unfortunate, and leads to the problems we have with
> compatibility for AF_ISDN, where userspace built for the _older_
> versions has a different value.
> 
> Is there really any harm in reserving it up-front?

If you're commiting a userspace to a kernel component
that hasn't been blessed upstream yet, you're already
up the creek without a paddle.
