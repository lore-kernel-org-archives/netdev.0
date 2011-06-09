From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Request for review on Hyper-V virtual network driver
Date: Thu, 09 Jun 2011 23:49:08 +0100
Message-ID: <1307659748.3127.42.camel@bwh-desktop>
References: <1307654865-30326-1-git-send-email-haiyangz@microsoft.com>
	 <1307655530.13329.49.camel@Joe-Laptop>
	 <A1F3067C9B68744AA19F6802BAB8FFDC09603E8F@TK5EX14MBXC227.redmond.corp.microsoft.com>
	 <20110609220701.GA24006@suse.de>  <1307658497.18357.6.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@suse.de>, Haiyang Zhang <haiyangz@microsoft.com>,
	Hank Janssen <hjanssen@microsoft.com>,
	KY Srinivasan <kys@microsoft.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:18606 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757070Ab1FIWtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 18:49:12 -0400
In-Reply-To: <1307658497.18357.6.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-09 at 15:28 -0700, Joe Perches wrote:
[...]
> It's odd and a bit ugly to use #include "../../staging/hyperv.h"
> 
> Maybe add another include path to the Makefile and just use
> #include "hyperv.h"
> until all of the hyperv files are moved out of staging?

It seems strange for files outside staging to have dependencies inside
staging.  I think that header file should be moved out first (or at the
same time).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

