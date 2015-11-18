From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] net: dns_resolver: convert time_t to time64_t
Date: Wed, 18 Nov 2015 22:27:50 +0000
Message-ID: <9583.1447885670@warthog.procyon.org.uk>
References: <20151118.152025.1846834961092956563.davem@davemloft.net> <20151118063643.GA16239@waves>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, mahfouz.saif.elyazal@gmail.com, arnd@arndb.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151118.152025.1846834961092956563.davem@davemloft.net>
Content-ID: <7751.1447879727.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

> From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
> Date: Wed, 18 Nov 2015 08:36:44 +0200
> 
> > Changes the definition of the pointer _expiry from time_t to
> > time64_t. This is to handle the Y2038 problem where time_t
> > will overflow in the year 2038. The change is safe because
> > the kernel subsystems that call dns_query pass NULL.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
> > ---
> > Changelog:
> > v1: The changes were originally made by Arnd Bergmann in
> > relation to time_t. I've broken down a patch sent to me
> > into two independent patches.
> 
> Want me to apply this to 'net'?

Fine by me.

Acked-by: David Howells <dhowells@redhat.com>
