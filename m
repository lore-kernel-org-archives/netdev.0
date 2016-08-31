From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] rxrpc: fix undefined behavior in rxrpc_mark_call_released
Date: Wed, 31 Aug 2016 22:37:39 +0200
Message-ID: <6209332.zC1KBURZ66@wuerfel>
References: <20160831123911.3467676-2-arnd@arndb.de> <20160831123911.3467676-1-arnd@arndb.de> <32632.1472675181@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.135]:63188 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754052AbcHaUhk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 16:37:40 -0400
In-Reply-To: <32632.1472675181@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, August 31, 2016 9:26:21 PM CEST David Howells wrote:
> Arnd Bergmann <arnd@arndb.de> wrote:
> 
> > +     } else {
> > +             sched = 0;
> 
> That should be false, not 0, btw.
> 

Right, sorry about that. Do you want me to resend the fixed version,
or do you apply and fix it yourself?

As patch 1/2 isn't actually meant for net-next anyway, the series
doesn't need to stay together.

	Arnd
