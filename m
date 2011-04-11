From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH] ethtool: time to blink provided in
 seconds not jiffies
Date: Tue, 12 Apr 2011 00:57:14 +0100
Message-ID: <1302566234.5282.581.camel@localhost>
References: <20110411230159.6727.91380.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Bruce Allan <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:18749 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110Ab1DKX5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 19:57:18 -0400
In-Reply-To: <20110411230159.6727.91380.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-04-11 at 16:01 -0700, Bruce Allan wrote:
> When blinking for a duration set by the user, the value specified is in
> seconds but it is used as the number of jiffies in the timeout after which
> the Physical ID indicator is deactivated.  Fix by converting the timeout
> to seconds.

D'oh.

> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

