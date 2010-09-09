From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] atlx: make strings const
Date: Wed, 8 Sep 2010 18:54:14 -0700
Message-ID: <20100908185414.52f6f35a@nehalam>
References: <20100908151836.3c40cc81@nehalam>
	<1283986691.24986.31.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60038 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754993Ab0IIByR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Sep 2010 21:54:17 -0400
In-Reply-To: <1283986691.24986.31.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 08 Sep 2010 15:58:11 -0700
Joe Perches <joe@perches.com> wrote:

> On Wed, 2010-09-08 at 15:18 -0700, Stephen Hemminger wrote:
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > Acked-by: Chris Snook <chris.snook@gmail.com>
> > 
> 
> Shouldn't that be done with all of the global
> static char foo[] = "bar"; declarations?

Yes, that what I was looking at when I found some of these.
Those that are __initdata don't matter as much since they
get dropped (although they could be changed to __initconst).
