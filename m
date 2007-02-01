From: olof@lixom.net (Olof Johansson)
Subject: Re: [PATCH] [v3] PA Semi PWRficient Ethernet driver
Date: Wed, 31 Jan 2007 21:20:40 -0600
Message-ID: <20070201032040.GA11564@lixom.net>
References: <20070129060852.GA7814@lixom.net> <20070130014434.GC18935@lixom.net> <20070131054457.GA32043@lixom.net> <20070131103806.29fc8d2e@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	Christoph Hellwig <hch@infradead.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:46296 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161295AbXBADNt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 22:13:49 -0500
Content-Disposition: inline
In-Reply-To: <20070131103806.29fc8d2e@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 31, 2007 at 10:38:06AM -0800, Stephen Hemminger wrote:
> O
> > +static noinline void pasemi_mac_free_tx_resources(struct net_device *dev)
> 
> Why tell compiler how to do it's job.  marking it noinline?

Leftover from debugging. Gone in the next version.

> Mixing definitions and structure values gets confusing.

I find if the definitions are few, having them near the structure
definition is easier to read. This is way past the limit for that
though. I'll move them.


Thanks,

-Olof
