From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.24-rc4-mm1
Date: Wed, 05 Dec 2007 23:09:25 -0800 (PST)
Message-ID: <20071205.230925.99250129.davem@davemloft.net>
References: <20071204211701.994dfce6.akpm@linux-foundation.org>
	<47579DD9.9030909@reub.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	ilpo.jarvinen@helsinki.fi
To: reuben-linuxkernel@reub.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45554
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752831AbXLFHJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 02:09:27 -0500
In-Reply-To: <47579DD9.9030909@reub.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Reuben Farrelly <reuben-linuxkernel@reub.net>
Date: Thu, 06 Dec 2007 17:59:37 +1100

> On 5/12/2007 4:17 PM, Andrew Morton wrote:
> > - Lots of device IDs have been removed from the e1000 driver and moved over
> >   to e1000e.  So if your e1000 stops working, you forgot to set CONFIG_E1000E.
> 
> This non fatal oops which I have just noticed may be related to this change then 
> - certainly looks networking related.
> 
> WARNING: at net/ipv4/tcp_input.c:2518 tcp_fastretrans_alert()
> Pid: 0, comm: swapper Not tainted 2.6.24-rc4-mm1 #1
> 
> Call Trace:
>   <IRQ>  [<ffffffff8046e038>] tcp_fastretrans_alert+0x229/0xe63
>   [<ffffffff80470975>] tcp_ack+0xa3f/0x127d
>   [<ffffffff804747b7>] tcp_rcv_established+0x55f/0x7f8
>   [<ffffffff8047b1aa>] tcp_v4_do_rcv+0xdb/0x3a7
>   [<ffffffff881148a8>] :nf_conntrack:nf_ct_deliver_cached_events+0x75/0x99

No, it's from TCP assertions and changes added by Ilpo to the
net-2.6.25 tree recently.
