From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 26/26] Xen-paravirt_ops: Add the Xen virtual network device driver.
Date: Fri, 2 Mar 2007 01:21:02 +0000
Message-ID: <20070302012102.GA15252@infradead.org>
References: <20070301232443.195603797@goop.org> <20070301232529.648076372@goop.org> <20070301164214.4a40bc59@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Andi Kleen <ak@muc.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	xen-devel@lists.xensource.com, Chris Wright <chrisw@sous-sol.org>,
	Zachary Amsden <zach@vmware.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Ian Pratt <ian.pratt@xensource.com>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>,
	netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:44872 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422678AbXCBBV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 20:21:56 -0500
Content-Disposition: inline
In-Reply-To: <20070301164214.4a40bc59@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 01, 2007 at 04:42:14PM -0800, Stephen Hemminger wrote:
> > +
> > +/** Send a packet on a net device to encourage switches to learn the
> > + * MAC. We send a fake ARP request.
> > + *
> > + * @param dev device
> > + * @return 0 on success, error code otherwise
> > + */
> Why the sudden urge to use docbook format on one internal function.

And it's not even proper kerneldoc but looks more like javadoc.
If you want to write kerneldoc comments please also verify them by
running the tools over it.

> This should probably be done in generic (non driver code).
> It creates lots of dependencies here.

Actually the right way to do it is in userspace, as all clustering
solutions do.  That's whay everyone told the Xen folks by the just
refuse to rip this junk out.

