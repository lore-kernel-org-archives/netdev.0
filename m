From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] ieee80211_i.h: Align struct ps_data.tim to unsigned long
Date: Thu, 19 Dec 2013 09:19:12 +0100
Message-ID: <1387441152.4298.5.camel@jlt4.sipsolutions.net>
References: <1387354564.13593.26.camel@joe-AO722>
	 (sfid-20131218_091612_149215_EA847147) <1387358347.4694.2.camel@jlt4.sipsolutions.net>
	 <1387414337.13593.48.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@redhat.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:52835 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744Ab3LSITR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 03:19:17 -0500
In-Reply-To: <1387414337.13593.48.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-18 at 16:52 -0800, Joe Perches wrote:
> Its address is used as an unsigned long *, so make sure
> that the tim u8 array is properly aligned.
> 
> Signed-off-by: Joe Perches <joe@perches.com
> ---
> > Care to send a proper patch? Otherwise I'll just re-do it and pick it up
> > that way ...
> 
> I had a passing thought about this when out today.
> It should really be set to __aligned(__alignof(unsigned long))
> so here's a proper patch.

Hmm, yeah, I guess that's true, though sizeof() is probably >= on
anything where Linux runs (and otherwise arrays get problematic anyway?)

Anyway, I've dropped my patch in favour of yours.

johannes
