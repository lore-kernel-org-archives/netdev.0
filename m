From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] afs: Refcount afs_call struct
Date: Mon, 09 Jan 2017 15:48:09 -0500 (EST)
Message-ID: <20170109.154809.833546470488398315.davem@davemloft.net>
References: <148397356909.20445.15077871371099721338.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148397356909.20445.15077871371099721338.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Mon, 09 Jan 2017 14:52:49 +0000

> 
> These patches provide some tracepoints for AFS and fix a potential leak by
> adding refcounting to the afs_call struct.
> 
> The patches are:
> 
>  (1) Add some tracepoints for logging incoming calls and monitoring
>      notifications from AF_RXRPC and data reception.
> 
>  (2) Get rid of afs_wait_mode as it didn't turn out to be as useful as
>      initially expected.  It can be brought back later if needed.  This
>      clears some stuff out that I don't then need to fix up in (4).
> 
>  (3) Allow listen(..., 0) to be used to disable listening.  This makes
>      shutting down the AFS cache manager server in the kernel much easier
>      and the accounting simpler as we can then be sure that (a) all
>      preallocated afs_call structs are relesed and (b) no new incoming
>      calls are going to be started.
> 
>      For the moment, listening cannot be reenabled.
> 
>  (4) Add refcounting to the afs_call struct to fix a potential multiple
>      release detected by static checking and add a tracepoint to follow the
>      lifecycle of afs_call objects.
> 
> The patches can be found here also:
> 
> 	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite
> 
> Tagged thusly:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
> 	rxrpc-rewrite-20170109

Pulled, thanks David.
