From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH 2/4] USB: XHCI: mark no_sg_limit
Date: Thu, 01 Aug 2013 10:15:51 +0200
Message-ID: <1375344951.1518.0.camel@linux-fkkt.site>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
	 <1375267909-30373-3-git-send-email-ming.lei@canonical.com>
	 <20130731164026.GB5714@xanatos> <20130801073049.GB5026@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	Ming Lei <ming.lei@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	Freddy Xin <freddy@asix.com.tw>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Grant Grundler <grundler@google.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42991 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750742Ab3HAIPy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 04:15:54 -0400
In-Reply-To: <20130801073049.GB5026@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-01 at 15:30 +0800, Greg Kroah-Hartman wrote:
> On Wed, Jul 31, 2013 at 09:40:26AM -0700, Sarah Sharp wrote:
> > On Wed, Jul 31, 2013 at 06:51:47PM +0800, Ming Lei wrote:
> > > This patch marks all xHCI controllers as no_sg_limit since
> > > xHCI supports building packet from discontinuous buffers.
> > > 
> > > Cc: Sarah Sharp <sarah.a.sharp@linux.intel.com>
> > > Signed-off-by: Ming Lei <ming.lei@canonical.com>
> > 
> > Acked-by: Sarah Sharp <sarah.a.sharp@linux.intel.com>
> 
> Is it a requirement that all xhci controllers support sg?  I know we are
> starting to see other controllers (the platform code?) so would they
> need to support this as well?

The way XHCI describes transfers allows them to be arbitrary.

	Regards
		Oliver
