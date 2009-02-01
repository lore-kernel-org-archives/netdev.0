From: David Miller <davem@davemloft.net>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Sun, 01 Feb 2009 12:31:47 -0800 (PST)
Message-ID: <20090201.123147.07028289.davem@davemloft.net>
References: <20090201124220.GA2319@ioremap.net>
	<4985C9F9.1020103@cosmosbay.com>
	<20090201174025.GA9562@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, shemminger@vyatta.com,
	herbert@gondor.apana.org.au, berrange@redhat.com,
	et-mgmt-tools@redhat.com, netdev@vger.kernel.org
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45278
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750930AbZBAUbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 15:31:50 -0500
In-Reply-To: <20090201174025.GA9562@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Sun, 1 Feb 2009 20:40:25 +0300

> On Sun, Feb 01, 2009 at 05:12:41PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> > [PATCH] net: move bsockets outside of read only beginning of struct inet_hashinfo
> > 
> > And switch bsockets to atomic_t since it might be changed in parallel.
> > 
> > Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
> Ok, let's do it this way. Ack.
> Thank you Eric.

Applied, thanks everyone.
