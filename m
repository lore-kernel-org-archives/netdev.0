From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] [RXRPC]: do not unlock unheld spinlock in rxrpc_connect_exclusive()
Date: Wed, 18 Dec 2013 16:08:35 +0000
Message-ID: <29753.1387382915@warthog.procyon.org.uk>
References: <1386975369-30837-1-git-send-email-khoroshilov@ispras.ru>
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386975369-30837-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Khoroshilov <khoroshilov@ispras.ru> wrote:

> If rx->conn is not NULL, rxrpc_connect_exclusive() does not
> acquire the transport's client lock, but it still releases it.
> 
> The patch adds locking of the spinlock to this path.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Looks good, thanks!  I've added it to my AFS branch.

David
