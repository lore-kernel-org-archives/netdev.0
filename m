From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH 1/2] ethtool: fix manpage so that it will
 display tables again
Date: Fri, 08 Apr 2011 23:45:38 +0100
Message-ID: <1302302738.2871.36.camel@bwh-desktop>
References: <20110408221135.26893.50092.stgit@gitlad.jf.intel.com>
	 <20110408221234.26893.58812.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:2336 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757858Ab1DHWpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 18:45:41 -0400
In-Reply-To: <20110408221234.26893.58812.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-04-08 at 15:12 -0700, Alexander Duyck wrote:
> The current ethtool manpage is not displaying tables.  After trying to pass
> the manpage through tbl I repeatedly saw the error:
> tbl:ethtool.8.in:707: unrecognised format `x'
> tbl:ethtool.8.in:707: giving up on this table
> 
> By dropping the 'x' the errors went away and when I built the manpage the
> tables reappeared so I am assuming this is the correct approach.
[...]

I think this must depend somewhat on the version of tbl.  I must admit I
haven't yet tested with a range of versions.

In groff 1.20.1, the 'x' column flag requested an 'expanded' column
which will be as wide as possible (after allowing for the other column
contents) with its contents word-wrapped if necessary.  Without this
flag, tbl wraps some columns poorly and complains about some tables
being too wide (though I don't think they are).  Clearly that is less
bad than having it discard the tables altogether, so I will apply this.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

