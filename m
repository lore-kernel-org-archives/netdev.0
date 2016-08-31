From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/5] rxrpc: fix last_call processing
Date: Wed, 31 Aug 2016 13:53:09 +0200
Message-ID: <5882481.rHsi0mzMry@wuerfel>
References: <20160826152546.604384-4-arnd@arndb.de> <20160826152546.604384-1-arnd@arndb.de> <13158.1472373737@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <13158.1472373737@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday, August 28, 2016 9:42:17 AM CEST David Howells wrote:
> This is fixed by:
> 
>         commit 2266ffdef5737fdfa96005204fc5606dbd559956
>         subject: rxrpc: Fix conn-based retransmit
> 
> which is in net-next.

I've merged net-next into the last linux-next release now for
testing (no linux-next this week) and can confirm that your
fix is correct. However, I got a new (valid) warning after
your f5c17aaeb2ae ("rxrpc: Calls should only have one terminal
state"), and another (false-positive) one for another patch
in net-next.

I'll follow up with the fixes, both of which are rather
straightforward.

	Arnd
