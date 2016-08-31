From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 2/2] rxrpc: fix undefined behavior in rxrpc_mark_call_released
Date: Wed, 31 Aug 2016 21:26:21 +0100
Message-ID: <32632.1472675181@warthog.procyon.org.uk>
References: <20160831123911.3467676-2-arnd@arndb.de> <20160831123911.3467676-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, "David S. Miller" <davem@davemloft.net>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160831123911.3467676-2-arnd@arndb.de>
Content-ID: <32631.1472675181.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> wrote:

> +	} else {
> +		sched = 0;

That should be false, not 0, btw.

David
