From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 2/4] e1000: add module option to set transmit descriptor size
Date: Fri, 27 Jun 2008 11:26:42 -0400
Message-ID: <20080627152642.GG32408@gospo.rdu.redhat.com>
References: <20080619211850.GD22981@gospo.rdu.redhat.com> <4864764D.6070802@garzik.org> <20080627142122.GA8991@ajones-laptop.nbttech.com> <20080627145522.GB8991@ajones-laptop.nbttech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"jesse.brandeburg@intel.com" <jesse.brandeburg@intel.com>
To: Arthur Jones <ajones@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55426 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750930AbYF0P0x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 11:26:53 -0400
Content-Disposition: inline
In-Reply-To: <20080627145522.GB8991@ajones-laptop.nbttech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 27, 2008 at 07:55:22AM -0700, Arthur Jones wrote:
> Hi Jeff, ...
> 
> On Fri, Jun 27, 2008 at 07:21:22AM -0700, Arthur Jones wrote:
> > On Thu, Jun 26, 2008 at 10:10:37PM -0700, Jeff Garzik wrote:
> > > Andy Gospodarek wrote:
> > > > This patch added the TxDescPower parameter to the e1000 module.  This
> > > > parameter represents the size-order of each transmit descriptor.  The
> > > > valid size for descriptors would be 2^7 (128) - 2^12 (4096) bytes each.
> > > > As this value decreases one may want to consider increasing the
> > > > TxDescriptors value to maintain the same amount of frame memory.  This
> > > > patch does not change the defaults for any particular hardware model, so
> > > > this will not have an effect on existing users.
> > > [...]
> > > I don't see why a module parameter is needed.  In practice, nobody will
> > > ever think about this option, much less use it.
> 
> One thing that may not be immediately obvious is
> that setting the descriptor payload size low to avoid
> the chip bug has a very negative effect on performance.
> I don't want to lower the descriptor payload size
> unless I absolutely have to -- e.g. environments where
> link flap on chip reset causes major distruptions to the
> network...
> 

Arthur,

That is absolutely correct.  For those that want to tune, the
performance hit can be significant and I would never recommend that
someone tweaks these settings unless they have problems first.

-andy

