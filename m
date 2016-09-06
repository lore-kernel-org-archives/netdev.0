From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] rxrpc: remove duplicate 'error' variable
Date: Tue, 06 Sep 2016 14:34:02 +0100
Message-ID: <32472.1473168842@warthog.procyon.org.uk>
References: <20160906132614.2117695-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, "David S. Miller" <davem@davemloft.net>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49348 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932893AbcIFNeE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Sep 2016 09:34:04 -0400
In-Reply-To: <20160906132614.2117695-1-arnd@arndb.de>
Content-ID: <32471.1473168842.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> wrote:

> The rxrpc_process_call function has debug code to print a failure code,
> but instead of printing the code from the rxrpc_call structure, it
> prints an uninitialized variable:
> 
> net/rxrpc/call_event.c: In function 'rxrpc_process_call':
> net/rxrpc/call_event.c:879:58: error: 'error' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> This removes the extraneous variable and prints the correct
> code instead.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: f5c17aaeb2ae ("rxrpc: Calls should only have one terminal state")

I've already posted a fix and it's waiting on DaveM.

https://patchwork.ozlabs.org/patch/665550/

http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/commit/?h=rxrpc-rewrite&id=00b5407e427ac2588a2496b92035a94602b3cd1b

David
