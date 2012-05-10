From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [NET_NEXT RFC PATCH 3/3] ixgbe: added reg_ops file to debugfs
Date: Wed, 9 May 2012 20:54:59 -0700
Message-ID: <20120509205459.4939c98d@s6510.linuxnetplumber.net>
References: <20120509230814.31910.80709.stgit@localhost6.localdomain6>
	<20120509230950.31910.6032.stgit@localhost6.localdomain6>
	<20120509161449.43704ea7@nehalam.linuxnetplumber.net>
	<1336609090.2499.18.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	<netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:32972 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755628Ab2EJDzH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 23:55:07 -0400
In-Reply-To: <1336609090.2499.18.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 May 2012 01:18:10 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Wed, 2012-05-09 at 16:14 -0700, Stephen Hemminger wrote:
> > On Wed, 09 May 2012 16:09:50 -0700
> > Catherine Sullivan <catherine.sullivan@intel.com> wrote:
> > 
> > > Added the reg_ops file to debugfs with commands to read and write
> > > a register to give users the ability to read and write individual
> > > registers on the fly.
> > > 
> > > Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
> > > ---
> > > 
> > >  drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c |  112 ++++++++++++++++++++++
> > >  1 files changed, 112 insertions(+), 0 deletions(-)
> > > 
> > 
> > Aren't these registers already in ethtool?
> 
> ethtool register access is read-only and would be very heavy-weight for
> interactive debugging.  Not sure this is the best interface to
> read/write registers, but it's certainly not redundant.

For debugging couldn't you could mmap the PCI  space? That would allow writing
a user level debugger for the hardware.
