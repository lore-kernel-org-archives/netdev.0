From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [NET_NEXT RFC PATCH 3/3] ixgbe: added reg_ops file to debugfs
Date: Thu, 10 May 2012 01:18:10 +0100
Message-ID: <1336609090.2499.18.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120509230814.31910.80709.stgit@localhost6.localdomain6>
	 <20120509230950.31910.6032.stgit@localhost6.localdomain6>
	 <20120509161449.43704ea7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	<netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30224 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755654Ab2EJASP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 20:18:15 -0400
In-Reply-To: <20120509161449.43704ea7@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-09 at 16:14 -0700, Stephen Hemminger wrote:
> On Wed, 09 May 2012 16:09:50 -0700
> Catherine Sullivan <catherine.sullivan@intel.com> wrote:
> 
> > Added the reg_ops file to debugfs with commands to read and write
> > a register to give users the ability to read and write individual
> > registers on the fly.
> > 
> > Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
> > ---
> > 
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c |  112 ++++++++++++++++++++++
> >  1 files changed, 112 insertions(+), 0 deletions(-)
> > 
> 
> Aren't these registers already in ethtool?

ethtool register access is read-only and would be very heavy-weight for
interactive debugging.  Not sure this is the best interface to
read/write registers, but it's certainly not redundant.

> You are also allowing write without any security checking.

The file permissions are set to 0600 so it's root-only.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
