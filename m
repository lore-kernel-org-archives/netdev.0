From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] wireless: check against default_ethtool_ops
Date: Fri, 7 Dec 2012 16:27:43 +0000
Message-ID: <1354897663.2707.14.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354729192-22945-1-git-send-email-greearb@candelatech.com>
	 <87a9ts4c1q.fsf@nemi.mork.no> <50BF8C18.9060504@candelatech.com>
	 <20121206122528.GG2502@redhat.com> <50C0FCE0.2090507@candelatech.com>
	 <20121207095012.GB11933@redhat.com> <87zk1q3xrv.fsf@nemi.mork.no>
	 <20121207121617.GA4356@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, <netdev@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	<linux-wireless@vger.kernel.org>,
	=?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8831 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422660Ab2LGQ1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 11:27:47 -0500
In-Reply-To: <20121207121617.GA4356@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-07 at 13:16 +0100, Stanislaw Gruszka wrote:
> Since:
> 
> commit 2c60db037034d27f8c636403355d52872da92f81
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Sun Sep 16 09:17:26 2012 +0000
> 
>     net: provide a default dev->ethtool_ops
> 
> wireless core does not correctly assign ethtool_ops. In order to fix
> the problem, and avoid assigning ethtool_ops on each individual cfg80211
> driver, we check against default_ethool_ops pointer instead of NULL in
> wireless core.
> 
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
[...]
Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Ideally you could do this assignment unconditionally in the setup
function for the device, but it doesn't seem like there's a common
allocation path that you could do that in.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
