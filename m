From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v4] net: Introduce realloc_netdev_mq()
Date: Fri, 4 Dec 2009 11:41:47 +0000
Message-ID: <20091204114147.GA8488@ff.dom.local>
References: <4B17EFE3.4080301@gmail.com> <20091203202937.GA11436@ami.dom.local> <4B182DC6.5030800@gmail.com> <20091203.133108.254093305.davem@davemloft.net> <4B1832DD.1070805@gmail.com> <20091203224742.GA16646@ami.dom.local> <4B18440A.2080507@gmail.com> <20091204074833.GA6478@ff.dom.local> <1259923898.23199.23.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:58173 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753049AbZLDLlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 06:41:46 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1079696fga.1
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2009 03:41:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1259923898.23199.23.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 04, 2009 at 02:51:38AM -0800, Peter P Waskiewicz Jr wrote:
> Honestly, there's no reason we can't know how many Tx queues we'll have
> prior to registering the netdev.  All of this should be figured out
> after ixgbe_alloc_queues() and ixgbe_init_interrupt_scheme() are called.
> 
> Once we know what features are enabled, and how many MSI-X vectors the
> platform gives us, we can make the call for how many queues to allocate.

Yes. It seems, it's more about cleaning/reordering a few things
sometimes.

> 
> I like this realloc_netdev_mq() mechanism.  I'm going to pull that into
> my tree for testing, since I unfortunately was unaware it existed (lack
> of my poking around).  This is good stuff.

Actually, it's only a simple separation of functionality, no big deal,
but thanks. Since it's still a part of RFC feel free to make it better
or even different way.

Cheers,
Jarek P.
