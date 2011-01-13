From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: Re: [PATCH] tlan: Use pr_fmt, pr_<level> and netdev_<level>,
	remove changelog
Date: Thu, 13 Jan 2011 08:19:26 +0200
Message-ID: <20110113061926.GA1900@valkosipuli.localdomain>
References: <4D260ED0.5040301@iki.fi> <1294339817-31434-1-git-send-email-sakari.ailus@iki.fi> <1294354088.12561.295.camel@Joe-Laptop> <20110109.233950.71582613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joe@perches.com, netdev@vger.kernel.org, chessman@tux.org,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-68.nebula.fi ([83.145.220.68]:34098 "EHLO
	smtp-68.nebula.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754079Ab1APAsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jan 2011 19:48:55 -0500
Content-Disposition: inline
In-Reply-To: <20110109.233950.71582613.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Sun, Jan 09, 2011 at 11:39:50PM -0800, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Thu, 06 Jan 2011 14:48:08 -0800
> 
> > Neatening and standardization to the standard logging mechanisms.
> > The changelog isn't useful anymore.
> > Miscellaneous speen/speed typo correction.
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> 
> This patch didn't apply cleanly to the current sources.
> 
> And anyways, please resubmit this once 2.6.38-rc1 is out and I
> start taking net-next-2.6 patches again.

Joe's patch applies on top of my patchset "tlan improvements" which contains
a largish code cleanup for the tlan driver. I got comments on that from Ben
Hutchings and haven't sent a new patchset yet.

Instead of fixing partner capability printout I'm removing it since the same
information is available under the mii-tool interface. Ben notified, quite
rightly, that the tlan should be using ethtool interface. That looks like a
topic for another patchset, though.

Regards,

-- 
Sakari Ailus
sakari dot ailus at iki dot fi
