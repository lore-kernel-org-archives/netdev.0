From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Add prefetches in net/ipv4/route.c
Date: Mon, 01 Aug 2005 11:39:16 -0400 (EDT)
Message-ID: <20050801.113916.74736771.davem@redhat.com>
References: <42EA7491.1010207@hp.com>
	<20050730.205209.112313042.davem@davemloft.net>
	<42EDDA50.4010405@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, rick.jones2@hp.com, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: dada1@cosmosbay.com
In-Reply-To: <42EDDA50.4010405@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 01 Aug 2005 10:16:16 +0200

> Last time I checked, read_mostly had a meaning only if CONFIG_X86 ||
> CONFIG_SPARC64

Meaning that other platforms need to implement this,
big deal :)

I do agree that the implementor of __read_mostly should
have just let the build break instead so folks could
simply be forced to fix things up.

It's actually a trivial change, and the author therefore
could also have updated all the platform's vmlinux.lds.S files
instead of ifdef'ing this stuff.
