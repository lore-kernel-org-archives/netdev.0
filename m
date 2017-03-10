From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rxrpc: rxrpc_kernel_send_data() needs to handle
 failed call better
Date: Thu, 09 Mar 2017 18:30:35 -0800 (PST)
Message-ID: <20170309.183035.1322866098839970347.davem@davemloft.net>
References: <148904703242.5036.16866085054034840990.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148904703242.5036.16866085054034840990.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 09 Mar 2017 08:10:32 +0000

> If rxrpc_kernel_send_data() is asked to send data through a call that has
> already failed (due to a remote abort, received protocol error or network
> error), then return the associated error code saved in the call rather than
> ESHUTDOWN.
> 
> This allows the caller to work out whether to ask for the abort code or not
> based on this.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied, thanks David.
