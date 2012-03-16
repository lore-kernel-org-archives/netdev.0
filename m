From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 4/4] ath9k:  Support ethtool getstats api.
Date: Fri, 16 Mar 2012 20:57:07 +0000
Message-ID: <1331931427.2504.12.camel@bwh-desktop.uk.solarflarecom.com>
References: <1331927952-8706-1-git-send-email-greearb@candelatech.com>
	 <1331927952-8706-4-git-send-email-greearb@candelatech.com>
	 <1331931232.2504.9.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
To: <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:52179 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1030326Ab2CPU5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 16:57:10 -0400
In-Reply-To: <1331931232.2504.9.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-03-16 at 20:53 +0000, Ben Hutchings wrote:
> On Fri, 2012-03-16 at 12:59 -0700, greearb@candelatech.com wrote:
> > From: Ben Greear <greearb@candelatech.com>
> > 
> > This returns many of the values that formerly could
> > only be obtained from debugfs.  This should be an
> > improvement when trying to access these counters
> > programatically.  Currently this support is only
> > enabled when DEBUGFS is enabled because otherwise
> > these stats are not accumulated.
> [...]
> 
> Given that ethtool (unlike debugfs) is itself an unconditional feature,
> why not make this unconditional?  Is it expensive to accumulate the
> stats?
> 
> Please at least fix the name.
                         ^ config option

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
