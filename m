From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] rxrpc: initialize sched to false to ensure it is not a garbage value
Date: Mon, 05 Sep 2016 19:50:54 +0100
Message-ID: <4978.1473101454@warthog.procyon.org.uk>
References: <20160905170002.18792-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, "David S . Miller" <davem@davemloft.net>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160905170002.18792-1-colin.king@canonical.com>
Content-ID: <4977.1473101454.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Colin King <colin.king@canonical.com> wrote:

> From: Colin Ian King <colin.king@canonical.com>
> 
> sched will be uninitialized (and contain a garbage value) in the case
> where call->state >= RXRPC_CALL_DEAD;  fix this by initializing sched
> to false to avoid an inadvertent call to rxrpc_queue_call.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

I already have a patch queued for this, thanks.

David
