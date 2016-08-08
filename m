From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] [net] rxrpc: fix uninitialized pointer dereference in debug code
Date: Mon, 08 Aug 2016 13:48:24 +0100
Message-ID: <1525.1470660504@warthog.procyon.org.uk>
References: <20160808101357.1583011-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160808101357.1583011-1-arnd@arndb.de>
Content-ID: <1524.1470660504.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> wrote:

> A newly added bugfix caused an uninitialized variable to be
> used for printing debug output. This is harmless as long
> as the debug setting is disabled, but otherwise leads to an
> immediate crash.
> 
> gcc warns about this when -Wmaybe-uninitialized is enabled:
> 
> net/rxrpc/call_object.c: In function 'rxrpc_release_call':
> net/rxrpc/call_object.c:496:163: error: 'sp' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> The initialization was removed but one of the users remains.
> This adds back the initialization.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 372ee16386bb ("rxrpc: Fix races between skb free, ACK generation and replying")

Applied, thanks.

David
