From: Greg KH <gregkh@suse.de>
Subject: Re: Request for review on Hyper-V virtual network driver
Date: Thu, 9 Jun 2011 16:00:25 -0700
Message-ID: <20110609230025.GA22856@suse.de>
References: <1307654865-30326-1-git-send-email-haiyangz@microsoft.com>
 <1307655530.13329.49.camel@Joe-Laptop>
 <A1F3067C9B68744AA19F6802BAB8FFDC09603E8F@TK5EX14MBXC227.redmond.corp.microsoft.com>
 <20110609220701.GA24006@suse.de>
 <1307658497.18357.6.camel@Joe-Laptop>
 <1307659748.3127.42.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Hank Janssen <hjanssen@microsoft.com>,
	KY Srinivasan <kys@microsoft.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:59858 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756698Ab1FIXAk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 19:00:40 -0400
Content-Disposition: inline
In-Reply-To: <1307659748.3127.42.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 09, 2011 at 11:49:08PM +0100, Ben Hutchings wrote:
> On Thu, 2011-06-09 at 15:28 -0700, Joe Perches wrote:
> [...]
> > It's odd and a bit ugly to use #include "../../staging/hyperv.h"
> > 
> > Maybe add another include path to the Makefile and just use
> > #include "hyperv.h"
> > until all of the hyperv files are moved out of staging?
> 
> It seems strange for files outside staging to have dependencies inside
> staging.  I think that header file should be moved out first (or at the
> same time).

The hyperv core hasn't moved out yet, as there is other work happening
there first.  I think Haiyang wanted to find out what was left to do on
the network driver side first while others work on the core issues.

So you can safely ignore that include for now, it's not a big deal, this
isn't ready to be merged yet, that's what the review is for :)

thanks,

greg k-h
