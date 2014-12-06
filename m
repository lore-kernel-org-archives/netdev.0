From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [net-next 04/14] ixgbe: remove CIAA/D register reads from bad
 VF check
Date: Sat, 06 Dec 2014 12:42:16 -0700
Message-ID: <1417894936.1095.4.camel@bling.home>
References: <1417801973-28793-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1417801973-28793-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20141205.204956.1468623374943582606.davem@davemloft.net>
	 <1417841892.2399.2.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, emil.s.tantilov@intel.com,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59580 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751639AbaLFTmT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Dec 2014 14:42:19 -0500
In-Reply-To: <1417841892.2399.2.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-12-05 at 20:58 -0800, Jeff Kirsher wrote:
> On Fri, 2014-12-05 at 20:49 -0800, David Miller wrote:
> > From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date: Fri,  5 Dec 2014 09:52:43 -0800
> > 
> > > From: Emil Tantilov <emil.s.tantilov@intel.com>
> > > 
> > > Accessing the CIAA/D register can block access to the PCI config space.
> > > 
> > > This patch removes the read/write operations to the CIAA/D registers
> > > and makes use of standard kernel functions for accessing the PCI config
> > > space.
> > > 
> > > In addition it moves ixgbevf_check_for_bad_vf() into the watchdog subtask
> > > which reduces the frequency of the checks.
> > > 
> > > CC: Alex Williamson <alex.williamson@redhat.com>
> > > Reported-by: Alex Williamson <alex.williamson@redhat.com>
> > > Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> > > Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> > > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > 
> > Alex Willaimson stated that he'd like to see this for -stable, but I'm warning
> > right now that a change not appropriate for 'net' is not approperiate for
> > '-stable' either.
> 
> Agreed, only reason I did not send this to net (along with the other
> fixes by Emil) was that we are at -rc7 and do not consider these
> "critical" to try and squeeze in before the release.

I'm not trying to subvert any process, just trying to note that the
commit log is rather subtle for the severity of the bug this fixes and
this should be considered for stable once accepted.  Stable obviously
doesn't take anything that's not already upstream.  Thanks,

Alex
