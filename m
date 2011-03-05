From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH] ixgbe: fix for 82599 erratum on Header Splitting
Date: Fri, 4 Mar 2011 23:59:26 -0800
Message-ID: <20110305075926.GA19706@suse.de>
References: <1299308767-28735-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <20110305074419.GA19596@suse.de>
 <1299311467.26413.31.camel@jtkirshe-MOBL1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"stable@kernel.org" <stable@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52034 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751093Ab1CEH6f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 02:58:35 -0500
Content-Disposition: inline
In-Reply-To: <1299311467.26413.31.camel@jtkirshe-MOBL1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 04, 2011 at 11:51:07PM -0800, Jeff Kirsher wrote:
> On Fri, 2011-03-04 at 23:44 -0800, Greg KH wrote:
> > On Fri, Mar 04, 2011 at 11:06:07PM -0800, Jeff Kirsher wrote:
> > > From: Don Skidmore <donald.c.skidmore@intel.com>
> > > 
> > > We have found a hardware erratum on 82599 hardware that can lead to
> > > unpredictable behavior when Header Splitting mode is enabled.  So
> > > we are no longer enabling this feature on affected hardware.
> > > 
> > > Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> > > Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> > > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > > ---
> > >  drivers/net/ixgbe/ixgbe_main.c |    4 ++++
> > 
> > I'm confused, why did you just send this patch to me?
> > 
> > What am I supposed to do with it?
> > 
> > greg k-h
> 
> This is the fix for ixgbe (that Ben and others pointed out) which has
> been accepted into Linus's tree which did not apply to stable-2.6.32
> tree.  This is the updated patch that apply's to the stable-2.6.32 tree.

How nice, but why didn't you say so in the first place?  Am I really
supposed to remember the hundreds of stable patches I handle every week?

Oh, I need the git commit id of it as well, care to resend this with
that and the proper "please apply this for the .32 longterm tree"
message so I can?

If so, I'll queue it up for the after-next .32-longterm release.

thanks,

greg k-h
