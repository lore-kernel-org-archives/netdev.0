From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: [PATCH 2/4] USB: XHCI: mark no_sg_limit
Date: Thu, 1 Aug 2013 13:47:57 -0700
Message-ID: <20130801204757.GB6961@xanatos>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
 <1375267909-30373-3-git-send-email-ming.lei@canonical.com>
 <20130731164026.GB5714@xanatos>
 <20130801073049.GB5026@kroah.com>
 <1375344951.1518.0.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Ming Lei <ming.lei@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	Freddy Xin <freddy@asix.com.tw>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Grant Grundler <grundler@google.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14031 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756697Ab3HAUr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 16:47:57 -0400
Content-Disposition: inline
In-Reply-To: <1375344951.1518.0.camel@linux-fkkt.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 01, 2013 at 10:15:51AM +0200, Oliver Neukum wrote:
> On Thu, 2013-08-01 at 15:30 +0800, Greg Kroah-Hartman wrote:
> > On Wed, Jul 31, 2013 at 09:40:26AM -0700, Sarah Sharp wrote:
> > > On Wed, Jul 31, 2013 at 06:51:47PM +0800, Ming Lei wrote:
> > > > This patch marks all xHCI controllers as no_sg_limit since
> > > > xHCI supports building packet from discontinuous buffers.
> > > > 
> > > > Cc: Sarah Sharp <sarah.a.sharp@linux.intel.com>
> > > > Signed-off-by: Ming Lei <ming.lei@canonical.com>
> > > 
> > > Acked-by: Sarah Sharp <sarah.a.sharp@linux.intel.com>
> > 
> > Is it a requirement that all xhci controllers support sg?  I know we are
> > starting to see other controllers (the platform code?) so would they
> > need to support this as well?
> 
> The way XHCI describes transfers allows them to be arbitrary.

Yes, Oliver is right.  The xHCI host can handle arbitrary length buffers
chained together into one transfer, and now that we have the xHCI driver
ring expansion code in place, we should be able to make them as long as
the USB core will allow.

Sarah Sharp
