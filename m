From: David Howells <dhowells@redhat.com>
Subject: Re: private netdev flags into UAPI?
Date: Tue, 27 Nov 2012 02:03:09 +0000
Message-ID: <990.1353981789@warthog.procyon.org.uk>
References: <CAJZOPZLQSCNTfSm63z1P_S4ZmwL+9mbP7rOCH7yHgBFcjaz1UA@mail.gmail.com> <50B1CC1B.20104@mellanox.com> <10845.1353921761@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, Or Gerlitz <ogerlitz@mellanox.com>,
	netdev <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7125 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932366Ab2K0CDR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2012 21:03:17 -0500
In-Reply-To: <CAJZOPZLQSCNTfSm63z1P_S4ZmwL+9mbP7rOCH7yHgBFcjaz1UA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <or.gerlitz@gmail.com> wrote:

> On Mon, Nov 26, 2012 at 11:22 AM, David Howells <dhowells@redhat.com> wrote:
> > They were exposed to userspace already
> 
> So the script carries the bug into a new directory... why? AFAIK,
> intentionally there's no way to read private flags from user space, so
> what's the point in defining them there?

How should the script know what's private and what's not?  By the
encapsulation of code inside __KERNEL__ blocks.  In their absence, everything
is assumed to be public - given it is already part of the UAPI.  I don't know
that the code is private rather than the comment is wrong.

David
