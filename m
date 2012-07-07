From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 01/10] net: Split core bits of dev_pick_tx into
 __dev_pick_tx
Date: Sat, 7 Jul 2012 01:03:23 +0100
Message-ID: <1341619403.2923.42.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>
	 <20120630001618.29939.26996.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <edumazet@google.com>,
	<therbert@google.com>, <alexander.duyck@gmail.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8304 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750903Ab2GGAD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 20:03:27 -0400
In-Reply-To: <20120630001618.29939.26996.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-29 at 17:16 -0700, Alexander Duyck wrote:
> This change splits the core bits of dev_pick_tx into a separate function.
> The main idea behind this is to make this code accessible to select queue
> functions when they decide to process the standard path instead of their
> own custom path in their select queue routine.
[...]

I like this.  Uninlining that code is going to cost some cycles, but
hopefully not enough to worry about.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
