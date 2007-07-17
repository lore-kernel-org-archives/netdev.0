From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [patch 37/44] xen: add virtual network device driver
Date: Wed, 18 Jul 2007 09:45:09 +1000
Message-ID: <1184715909.10380.39.camel@localhost.localdomain>
References: <20070716231536.937393000@xensource.com>
	 <20070716232916.472694000@xensource.com> <20070717094511.795beb69@oldman>
	 <469CD222.1030202@goop.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeremy Fitzhardinge <jeremy@xensource.com>,
	Linus Torvalds <torvalds@linux-foundation.com>,
	Andi Kleen <ak@suse.de>,
	Andrew Morton <akpm@linux-foundation.com>,
	lkml <linux-kernel@vger.kernel.org>,
	Xen-devel <xen-devel@lists.xensource.com>,
	Chris Wright <chrisw@sous-sol.org>,
	Ian Pratt <ian.pratt@xensource.com>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>,
	Jeff Garzik <jeff@garzik.org>,
	Christoph Hellwig <hch@infradead.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Keir Fraser <Keir.Fraser@cl.cam.ac.uk>, netdev@vger.kernel.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:53883 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757824AbXGQXpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2007 19:45:42 -0400
In-Reply-To: <469CD222.1030202@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-07-17 at 07:28 -0700, Jeremy Fitzhardinge wrote:
> Stephen Hemminger wrote:
> >> +struct netfront_info {
> >> +	struct list_head list;
> >> +	struct net_device *netdev;
> >> +
> >> +	struct net_device_stats stats;
> >>     
> >
> > There is now a net_device_stats element inside net_device on
> > 2.6.21 or later.
> >   
> 
> Ah, OK.  Should I just do a s/stats/netdev->stats/?  Is there a generic
> get_stats routine as well?

The default function points to the internal stats...

Cheers,
Rusty.


