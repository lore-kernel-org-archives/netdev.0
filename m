From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ip: add loose reverse path filtering
Date: Mon, 23 Feb 2009 13:46:46 -0800
Message-ID: <20090223134646.655abc1a@extreme>
References: <20090220102536.2d39ddb9@extreme>
	<20090221130907.GA28765@gondor.apana.org.au>
	<20090221.235601.92406212.davem@davemloft.net>
	<20090222083436.GA1975@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hawk@diku.dk,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45627 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751979AbZBWVqu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2009 16:46:50 -0500
In-Reply-To: <20090222083436.GA1975@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 22 Feb 2009 16:34:36 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Sat, Feb 21, 2009 at 11:56:01PM -0800, David Miller wrote:
> >
> > > Rather than extending the rp_filter stuff any further, I'd prefer
> > > to see this replaced with netfilter plugin.
> > 
> > Normally I would agree, but in this case the cost is exactly
> > zero for the added flexibility.
> 
> Ah I thought there was another patch coming :) But obviously as
> this is all that's needed for it sure it looks good to me too.
> 
> Cheers,

Also, the purpose of reverse path filtering is to block Dos attacks.
So it is important to do any rejection with least overhead. If the
filter is iptables rules, it takes longer and requires another route
lookup.
