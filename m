From: Kalle Valo <kalle.valo@iki.fi>
Subject: Re: mac80211: NOHZ: local_softirq_pending 08
Date: Fri, 11 Sep 2009 17:57:54 +0300
Message-ID: <877hw534wd.fsf@litku.valot.fi>
References: <200909111648.50902.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:35404 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751627AbZIKO5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 10:57:55 -0400
In-Reply-To: <200909111648.50902.mb@bu3sch.de> (Michael Buesch's message of "Fri\, 11 Sep 2009 16\:48\:49 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Buesch <mb@bu3sch.de> writes:

> Hi,

Hallo,

> mac80211 (or some other part of the networking stack) triggers this
> warning in the NOHZ code: NOHZ: local_softirq_pending 08
>
> 08 seems to be NET_RX_SOFTIRQ.
>
> It happens, because my test driver b43 handles all RX and TX-status
> callbacks in process context. I guess some part of the networking
> stack expects RX to be in tasklet and/or softirq context.
>
> We also have a report of this warning in wl1251, so it's probably not
> a b43 problem.

Yes, I see this with wl1251. It uses workqueues everywhere.

-- 
Kalle Valo
