From: Arthur Jones <ajones@riverbed.com>
Subject: Re: [PATCH] igb: allow tx of pre-formatted vlan tagged packets
Date: Thu, 12 Mar 2009 14:00:57 -0700
Message-ID: <20090312210057.GA14957@ajones-laptop.nbttech.com>
References: <20090312202724.GA9876@ajones-laptop.nbttech.com> <20090312135119.3a715480@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.riverbed.com ([206.169.144.12]:55440 "EHLO
	smtp1.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700AbZCLVBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 17:01:00 -0400
Content-Disposition: inline
In-Reply-To: <20090312135119.3a715480@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen, ...

On Thu, Mar 12, 2009 at 01:51:19PM -0700, Stephen Hemminger wrote:
> On Thu, 12 Mar 2009 13:27:24 -0700
> Arthur Jones <ajones@riverbed.com> wrote:
> 
> > When the 82575 is fed 802.1q packets, it chokes with
> > an error of the form:
> > 
> > igb 0000:08:00.1: partial checksum but proto=81
> > 
> > As the logic there was not smart enough to look into
> > the vlan header to pick out the encapsulated protocol.
> > 
> > There are times when we'd like to send these packets
> > out without having to configure a vlan on the interface.
> > Here we check for the vlan tag and allow the packet to
> > go out with the correct hardware checksum.
> > 
> > Thanks to Kand Ly <kand@riverbed.com> for discovering the
> > issue and the coming up with a solution.  This patch is
> > based upon his work.
> > 
> > Signed-off-by: Arthur Jones <ajones@riverbed.com>
> > ---
> >  drivers/net/igb/igb_main.c |   12 +++++++++++-
> >  1 files changed, 11 insertions(+), 1 deletions(-)
> 
> That code in current igb driver (net-next-2.6) tree no longer has
> the whole switch you are changing.

Ok, thanks, I'll test that one...

Arthur
