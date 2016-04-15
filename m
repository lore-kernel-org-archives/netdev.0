From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 1/3] rxrpc: Don't permit use of connect() op and simplify sendmsg() op
Date: Fri, 15 Apr 2016 04:26:10 +0100
Message-ID: <4962.1460690770@warthog.procyon.org.uk>
References: <20160414.210713.1128991767536792390.davem@davemloft.net> <20160412150533.20637.23952.stgit@warthog.procyon.org.uk> <20160412150540.20637.31886.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57335 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752344AbcDOD0N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 23:26:13 -0400
In-Reply-To: <20160414.210713.1128991767536792390.davem@davemloft.net>
Content-ID: <4961.1460690770.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

> > Simplify the RxRPC user interface and remove the use of connect() to direct
> > client calls.  It is redundant given that sendmsg() can be given the target
> > address and calls to multiple targets are permitted from a client socket
> > and also from a service socket.
> 
> You can't just change completely the socket semantics for your
> protocol like this, every single userland application is going to
> break.
> 
> Sorry, there is no way I am applying changes like this.

Okay, fair enough.[*]

David

[*] I could point out that there is only one (under construction) userspace
application that uses this - and that doesn't use connect - but I can't quite
be 100% sure of that, so your point stands.
