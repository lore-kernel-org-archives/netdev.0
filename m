From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rxrpc: Call state should be read with READ_ONCE()
 under some circumstances
Date: Tue, 07 Mar 2017 13:59:28 -0800 (PST)
Message-ID: <20170307.135928.594434139062899205.davem@davemloft.net>
References: <148858570121.7759.13967054786116725339.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148858570121.7759.13967054786116725339.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Sat, 04 Mar 2017 00:01:41 +0000

> The call state may be changed at any time by the data-ready routine in
> response to received packets, so if the call state is to be read and acted
> upon several times in a function, READ_ONCE() must be used unless the call
> state lock is held.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied.
