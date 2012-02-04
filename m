From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netprio_cgroup: Fix obo in get_prioidx
Date: Sat, 4 Feb 2012 16:42:03 -0500
Message-ID: <20120204214203.GA4260@neilslaptop.think-freely.org>
References: <1328282323-15902-1-git-send-email-nhorman@tuxdriver.com>
 <20120204.163100.1902018364644947001.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sgruszka@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38432 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405Ab2BDVmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 16:42:23 -0500
Content-Disposition: inline
In-Reply-To: <20120204.163100.1902018364644947001.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 04, 2012 at 04:31:00PM -0500, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Fri,  3 Feb 2012 10:18:43 -0500
> 
> > It was recently pointed out to me that the get_prioidx function sets a bit in
> > the prioidx map prior to checking to see if the index being set is out of
> > bounds.  This patch corrects that, avoiding the possiblity of us writing beyond
> > the end of the array
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > Reported-by: Stanislaw Gruszka <sgruszka@redhat.com>
> 
> Applied and queued up for -stable, thanks Neil.
> 
> 
Thanks Dave!
