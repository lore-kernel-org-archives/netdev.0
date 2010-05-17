From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: iproute2 issue with adding rules.
Date: Mon, 17 May 2010 13:30:04 -0700
Message-ID: <20100517203004.GD8301@sequoia.sous-sol.org>
References: <4BF192F9.8000008@candelatech.com>
 <4BF1A352.5020500@candelatech.com>
 <4BF1A6D1.70507@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:36038 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752656Ab0EQUbR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 16:31:17 -0400
Content-Disposition: inline
In-Reply-To: <4BF1A6D1.70507@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Ben Greear (greearb@candelatech.com) wrote:
> On 05/17/2010 01:13 PM, Ben Greear wrote:
> >On 05/17/2010 12:03 PM, Ben Greear wrote:
> >>On older releases, you can do this with iproute:
> >>
> >># ip ru add from 9.9.9.2/32 table 226 pref 400
> >>#
> >>
> >>But, in latest git, it returns an error:
> >># ip ru add from 9.9.9.2/32 table 226 pref 400
> >>Error: an inet prefix is expected rather than "9.9.9.2/32".
> >>
> >>Is that on purpose?
> >
> >I was thinking maybe this was a library issue, since I compiled
> >on one machine and ran the 'ip' exe on another. So, I tried compiling
> >on the test system.
> 
> I'm not thinking too well today, but this patch fixes the compile.
> No idea if it's actually correct code.

Needs more changes than that patch.

thanks,
-chris
