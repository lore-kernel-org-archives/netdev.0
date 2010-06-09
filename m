From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH][RFC] Infrastructure for compact call location
 representation
Date: Wed, 9 Jun 2010 18:44:17 +1000
Message-ID: <20100609084417.GW26335@laptop>
References: <20100608003052.GA29377@dvomlehn-lnx2.corp.sa.net>
 <20100608084456.4da00349@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David VomLehn <dvomlehn@cisco.com>, to@dvomlehn-lnx2.corp.sa.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:58282 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756952Ab0FIIoV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jun 2010 04:44:21 -0400
Content-Disposition: inline
In-Reply-To: <20100608084456.4da00349@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 08, 2010 at 08:44:56AM -0700, Stephen Hemminger wrote:
> On Mon, 7 Jun 2010 17:30:52 -0700
> David VomLehn <dvomlehn@cisco.com> wrote:
> > History
> > v2	Support small callsite IDs and split out out-of-band parameter
> > 	parsing.
> > V1	Initial release
> > 
> > Signed-off-by: David VomLehn <dvomlehn@cisco.com>
> 
> This is really Linux Kernel Mailing List material (not just netdev). And it will
> be a hard sell to get it accepted, because it is basically an alternative call
> tracing mechanism, and there are already several of these in use or under development
> (see perf and ftrace).

What about a generic extension or layer on top of stacktrace that
does caching and unique IDs for stack traces. This way you can get
callsites or _full_ stack traces if required, and it shouldn't require
any extra magic in the net functions.

You would need a hash for stack traces to check for an existing trace,
and an idr to assign ids to traces.

