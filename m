From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] rxrpc: Update tracing and proc interfaces
Date: Thu, 05 Jan 2017 12:45:51 -0500 (EST)
Message-ID: <20170105.124551.1914532850791182795.davem@davemloft.net>
References: <148362671062.31085.13249164388796003311.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148362671062.31085.13249164388796003311.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 05 Jan 2017 14:31:50 +0000

> This set of patches fixes and extends tracing:
> 
>  (1) Fix the handling of enum-to-string translations so that external
>      tracing tools can make use of it by using TRACE_DEFINE_ENUM.
> 
>  (2) Extend a couple of tracepoints to export some extra available
>      information and add three new tracepoints to allow monitoring of
>      received DATA packets, call disconnection and improper/implicit call
>      termination.
> 
> and adds a bit more procfs-exported information:
> 
>  (3) Show a call's hard-ACK cursors in /proc/net/rxrpc_calls.
> 
> The patches can be found here also:
> 
> 	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite
> 
> Tagged thusly:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
> 	rxrpc-rewrite-20170105

Pulled, thanks.
