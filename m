From: Flavio Leitner <fbl@redhat.com>
Subject: Re: restoring IP multicast addresses when restarting the interface.
Date: Tue, 24 Apr 2012 15:30:23 -0300
Message-ID: <20120424153023.0913956e@asterix.rh>
References: <20120420212533.78903e3a@asterix.rh>
	<20120423121425.GA29883@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43115 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756815Ab2DXSaf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2012 14:30:35 -0400
In-Reply-To: <20120423121425.GA29883@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Apr 2012 22:14:25 +1000
Herbert Xu <herbert@gondor.hengli.com.au> wrote:

> On Fri, Apr 20, 2012 at 09:25:33PM -0300, Flavio Leitner wrote:
> >
> > Although the new behavior seems nice and save some user space
> > work, I think it was unintentional and likely to be a bug.
> > 
> > What you guys think?
> 
> Are you talking about multicast subscriptions on the interface?
 
Yes.

> I don't see why they should disappear when the interface goes
> down and then comes back up since these ultimately come from
> application sockets which continue to exist after a down/up.

Yeah, but that's not how things used to work before, so my
question is if the kernel should be responsible for keeping
the subscription or the application.

If the admin puts down the interface and remove the module,
for instance, then the multicast subscription is gone.
Should the application monitor for that then?

David? Any thoughts?

thanks,
fbl
