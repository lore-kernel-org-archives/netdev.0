From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (8/8) loopback device simplification
Date: Wed, 3 Sep 2003 20:41:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030903204105.0f01f131.davem@redhat.com>
References: <20030903164921.7d923008.shemminger@osdl.org>
	<3F568AC0.5090601@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F568AC0.5090601@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 03 Sep 2003 20:43:44 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Would be nice to move dev_base and dev_base_lock somewhere, maybe 
> drivers/net/net_init.c (which really should be renamed libnet.c) or 
> perhaps somewhere in net/*

Once all of the conversions are done, we can happily move
this someone.  My personal preference would be net/core/dev.c,
as I believe we can limit all of the modifications to there
eventually and thus not have to export those two symbols to
the entire kernel any more.

The fact that we export the list and it's locking makes it
really hard to change things.
