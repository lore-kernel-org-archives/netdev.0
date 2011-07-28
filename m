From: David Lamparter <equinox@diac24.net>
Subject: Re: 802.1ad on linux
Date: Thu, 28 Jul 2011 14:48:30 +0200
Message-ID: <20110728124830.GA2144046@jupiter.n2.diac24.net>
References: <CAChS5kM+xmWRrF-Ez7W9+=7Se9o3bXrk4sSs6X-z7gU21SaWrA@mail.gmail.com>
 <201107281321.46294.jens@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Osterkamp <jens@linux.vnet.ibm.com>, netdev@vger.kernel.org
To: "Satendra..." <satendra.pratap@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:47963 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755281Ab1G1Msk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jul 2011 08:48:40 -0400
Content-Disposition: inline
In-Reply-To: <201107281321.46294.jens@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 28, 2011 at 01:21:46PM +0200, Jens Osterkamp wrote:
> On Thursday 28 July 2011, Satendra... wrote:
> > Hi,
> > 
> > Does linux kernel has support for 802.1ad ? if yes could u plz mention
> > the version?
> 
> No, but David Lamparter has just recently posted patches which implement this.
> 
> http://marc.info/?l=linux-netdev&m=131093613717022&w=2
> 
> They work fine for me on top of net-next. I had to add EXPORT_SYMBOL for
> vlan_untag and vlan_do_receive to be able to build as a module.
> You will need his patch for iproute2 as well to be able to create 802.1ad
> VLAN devices.

I will be rebasing them onto current net-next HEAD this weekend. With
the VLAN cleanup in, some bits changed; I'll also do some reordering to
fix those symbols.


-David

