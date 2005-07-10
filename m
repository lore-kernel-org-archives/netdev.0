From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] forcedeth: Additional ethtool support
Date: Mon, 11 Jul 2005 01:26:03 +0200
Message-ID: <20050710232603.GA4335@electric-eye.fr.zoreil.com>
References: <42D101EC.6000608@colorfullife.com> <20050710172833.GA1951@electric-eye.fr.zoreil.com> <42D16656.6000207@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>,
        renaud.lienhart@free.fr
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
Content-Disposition: inline
In-Reply-To: <42D16656.6000207@colorfullife.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Manfred Spraul <manfred@colorfullife.com> :
[memcpy_fromio]
> Not for a nic without complete documentation: What if an arch uses 
> 64-bit reads to read two registers at the same time?

So far, no citizen of arch/ does. Afaik it would probably be a bad
idea on pci-x.

> that, for example IIRC natsemi explicitely mandates 32-bit reads.
> x86-64 doesn't, it uses 32-bit reads, but I don't like the idea of using 
> memcpy to read registers.

Ok.

--
Ueimor
