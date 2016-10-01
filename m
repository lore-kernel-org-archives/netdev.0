From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] rxrpc: split up rxrpc_send_call_packet()
Date: Sat, 01 Oct 2016 10:15:15 +0100
Message-ID: <8568.1475313315@warthog.procyon.org.uk>
References: <201610010540.58123.arnd@arndb.de> <12692.1475278509@warthog.procyon.org.uk> <20160930161218.4178124-1-arnd@arndb.de> <16139.1475279560@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, "David S. Miller" <davem@davemloft.net>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55182 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750934AbcJAJPS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 1 Oct 2016 05:15:18 -0400
In-Reply-To: <201610010540.58123.arnd@arndb.de>
Content-ID: <8567.1475313315.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> wrote:

> Yes, good idea. We could probably share the part of the two functions that
> sets the contents of the msg and pkt variables by moving it into a third
> function, but I'm not sure if that actually improves readability or just
> reduces the number of lines.

And the ACK-sending function is about to get a bit more complex :-(

David
