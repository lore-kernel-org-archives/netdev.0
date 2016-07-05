From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH net-next 06/24] rxrpc: Dup the main conn list for the proc interface
Date: Tue, 05 Jul 2016 20:53:17 +0100
Message-ID: <17652.1467748397@warthog.procyon.org.uk>
References: <20160705.101745.2191999709401594106.davem@davemloft.net> <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk> <146772437424.21657.5653571141789810019.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160705.101745.2191999709401594106.davem@davemloft.net>
Content-ID: <17651.1467748397.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

> Wouldn't it be better to just code the proc stuff to walk whatever
> table the rest of the stack uses to hold all of the connections
> as TCP et al. do?

I should also mention that this is an intermediate step.  Splitting out the
procfs list makes it easier to fix the reap lists.  I can always make the proc
code do something different once the reap fixes have settled down.

David
