From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] rxrpc: Small fixes
Date: Tue, 06 Sep 2016 13:53:54 -0700 (PDT)
Message-ID: <20160906.135354.1464691430444892293.davem@davemloft.net>
References: <147302294435.28597.15007422228950187972.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147302294435.28597.15007422228950187972.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Sun, 04 Sep 2016 22:02:24 +0100

> 
> Here's a set of small fix patches:
> 
>  (1) Fix some uninitialised variables.
> 
>  (2) Set the client call state before making it live by attaching it to the
>      conn struct.
> 
>  (3) Randomise the epoch and starting client conn ID values, and don't
>      change the epoch when the client conn ID rolls round.
> 
>  (4) Replace deprecated create_singlethread_workqueue() calls.
> 
> The patches can be found here also (non-terminally on the branch):
> 
> 	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite
> 
> Tagged thusly:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
> 	rxrpc-rewrite-20160904-1

Both rxrpc-rewrite-20160904-1 and rxrpc-rewrite-20160904-2 pulled, thanks.
