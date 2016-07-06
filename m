From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH net-next 04/24] rxrpc: Avoid using stack memory in SG lists in rxkad
Date: Wed, 06 Jul 2016 16:03:08 +0100
Message-ID: <31310.1467817388@warthog.procyon.org.uk>
References: <CALCETrXYJTvYgyaeOwY6N3T2rH+4J23FSp6FWA7HFXih4=3acQ@mail.gmail.com> <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk> <146772435939.21657.15502992311223735001.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andy Lutomirski <luto@kernel.org>,
	linux-afs@lists.infradead.org
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41247 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753300AbcGFPDL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2016 11:03:11 -0400
In-Reply-To: <CALCETrXYJTvYgyaeOwY6N3T2rH+4J23FSp6FWA7HFXih4=3acQ@mail.gmail.com>
Content-ID: <31309.1467817388.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Lutomirski <luto@amacapital.net> wrote:

> > From: Herbert Xu <herbert@gondor.apana.org.au>
> >
> > rxkad uses stack memory in SG lists which would not work if stacks were
> > allocated from vmalloc memory.  In fact, in most cases this isn't even
> > necessary as the stack memory ends up getting copied over to kmalloc
> > memory.
> 
> This version no longer applies to Linus' tree, so I'm dropping it from
> my series.

This version of your rxrpc patch?  There haven't been any conflicting upstream
changes for a month.  Do you object to me carrying my version of the patch
since it fits in with the changes I've been making?

David
