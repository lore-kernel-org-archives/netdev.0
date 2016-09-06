From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] rxrpc: remove duplicate 'error' variable
Date: Tue, 06 Sep 2016 15:39:59 +0200
Message-ID: <8706362.vunRxcsNaf@wuerfel>
References: <20160906132614.2117695-1-arnd@arndb.de> <32472.1473168842@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <32472.1473168842@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, September 6, 2016 2:34:02 PM CEST David Howells wrote:
> Arnd Bergmann <arnd@arndb.de> wrote:
> 
> > The rxrpc_process_call function has debug code to print a failure code,
> > but instead of printing the code from the rxrpc_call structure, it
> > prints an uninitialized variable:
> > 
> > net/rxrpc/call_event.c: In function 'rxrpc_process_call':
> > net/rxrpc/call_event.c:879:58: error: 'error' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> > 
> > This removes the extraneous variable and prints the correct
> > code instead.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > Fixes: f5c17aaeb2ae ("rxrpc: Calls should only have one terminal state")
> 
> I've already posted a fix and it's waiting on DaveM.
> 
> https://patchwork.ozlabs.org/patch/665550/
> 
> http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/commit/?h=rxrpc-rewrite&id=00b5407e427ac2588a2496b92035a94602b3cd1b

Ok, good. At least I'm glad my patch is correct this time (being identical
to yours).

	Arnd
