From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 2/9] rxrpc: Disable a debugging statement that has been left enabled.
Date: Thu, 07 Apr 2016 20:43:44 +0100
Message-ID: <981.1460058224@warthog.procyon.org.uk>
References: <1460049545.6715.98.camel@perches.com> <1460046677.6715.95.camel@perches.com> <20160407162256.21283.47849.stgit@warthog.procyon.org.uk> <20160407162309.21283.11482.stgit@warthog.procyon.org.uk> <24286.1460048722@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49306 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757219AbcDGTnr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 15:43:47 -0400
In-Reply-To: <1460049545.6715.98.camel@perches.com>
Content-ID: <980.1460058224.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> wrote:

> > Joe Perches <joe@perches.com> wrote:
> > > It might be better to remove kenter and _enter
> > > altogether and use function tracing instead.
> > Possibly - but not at this time.
> 
> Swell.

I didn't say I wouldn't do it - it's just that I'm trying to fix other stuff
at the moment and don't particularly want to add that to the list just now.
kenter, _enter and co. are serving me very well.

> > Besides, isn't the function tracing log lost
> > if the machine crashes?
> 
> I believe yes, but would it matter?

Let's see...  If the machine panics whilst I'm developing stuff (quite likely
if something goes wrong in BH context), how do I get at the function tracing
log to find out why it panicked if the log is then lost?  With the serial
console, at least I automatically capture the output of kenter and co..

David
