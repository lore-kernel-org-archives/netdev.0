From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: 2.6.27-rc1-git4 BUG: sched while atomic
Date: Mon, 4 Aug 2008 17:46:39 -0700
Message-ID: <20080805004639.GB16130@HP-xw6200.broadcom.net>
References: <20080804094835.da083484.randy.dunlap@oracle.com>
 <20080804101712.659780ef@extreme> <1217859640.6746.2.camel@HP1>
 <20080804.144020.106451038.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, shemminger@vyatta.com, randy.dunlap@oracle.com,
	netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2944 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753377AbYHEAAK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2008 20:00:10 -0400
In-Reply-To: <20080804.144020.106451038.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm looking into it right now.  Stay tuned.

On Mon, Aug 04, 2008 at 02:40:20PM -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Mon, 04 Aug 2008 07:20:40 -0700
> 
> > This was introduced by:
> > 
> > tg3: adapt tg3 to use reworked PCI PM code
> > 
> > Adapt the tg3 driver to use the reworked PCI PM and make it use the
> > exported PCI PM core functions instead of accessing the PCI PM registers
> > directly by itself.
> > 
> > Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> > 
> > In the original tg3 code, we used udelay() when switching to D0 state
> > since we were inside tg3_full_lock().
> 
> Right, this change was obviously not tested properly.
> 
> I'm likely going to revert unless a really good fix shows up fast.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


