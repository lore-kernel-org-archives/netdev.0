From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Fix atl1c event race (was Re: 2.6.38 dev_watchdog WARNING)
Date: Wed, 20 Apr 2011 19:13:27 +0100
Message-ID: <1303323207.2823.22.camel@bwh-desktop>
References: <4DADC8F2.9050700@canonical.com>
	 <1303238959.2988.30.camel@bwh-desktop>  <4DAF1F1D.1020108@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: tim.gardner@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:32738 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750836Ab1DTSNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 14:13:30 -0400
In-Reply-To: <4DAF1F1D.1020108@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-20 at 11:59 -0600, Tim Gardner wrote:
[...]
> I've been focusing on atl1c while trying to understand why link status 
> flapping could cause these watchdog timeouts. I've a couple of log files 
> with link state change information:
> 
> http://bugs.launchpad.net/bugs/766273
> https://launchpadlibrarian.net/69926580/BootDmesg.txt
> https://launchpadlibrarian.net/69926583/CurrentDmesg.txt
> 
> One thing of note is that there are 2 link UP messages in a row, 
> something that should only be able to happen if there has been an 
> intervening device reset (which is not evident in the logs). I've 
> noticed that the work event scheduling is kind of racy, so perhaps this 
> will help. See attached.

I'm not going to spend any significant time looking at atl1c, as that's
really not my job!  The atlx maintainers may be covering atl1c as well,
so try cc'ing them.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

