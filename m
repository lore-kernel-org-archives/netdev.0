From: Jason Lunz <lunz@reflexsecurity.com>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Fri, 29 Jun 2007 13:22:31 -0700
Message-ID: <20070629202230.GC3917@falooley.org>
References: <1183138159.17243.16.camel@blaa> <20070629175006.GB3917@falooley.org> <468562A6.8060901@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>
To: "Kok\, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crown.reflexsecurity.com ([72.54.139.163]:42970 "EHLO
	crown.reflexsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753316AbXF2UWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 16:22:23 -0400
Content-Disposition: inline
In-Reply-To: <468562A6.8060901@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 29, 2007 at 12:51:02PM -0700, Kok, Auke wrote:
> For distro's not following kernel.org releases we have the perfect 
> solution: A fully tested 7.5.5 driver on sourceforge that was extensively 
> tested against RHEL5 for instance, but also a lot of other older kernels.

I'm sure you and your team have tested the driver thoroughly, but you
cannot hope to match the amount of testing the driver is subjected to by
going into -mm and -rc kernels.

There have been several instances over the years in the e1000 driver
where new releases caused regressions on old or esoteric hardware, and
these were only later discovered by the community. This is why I prefer
kernel.org versions of the e1000 driver, even if they're a little older.

Ordinarily this is a pretty good strategy, because the mainline driver
hasn't usually lagged too far behind new hardware becoming available.
That's no longer true of the newer pcie e1000 parts and the 7.5.5.1
driver.

Is there any specific objection remaining to the merge of e1000 7.5.5.1
into 2.6.23? Is there anything I can do to expedite the process other
than cheer from the sidelines?

Jason
