From: Jouni Malinen <jkm@devicescape.com>
Subject: Re: [PATCH 5/7] d80211: indicate if unassociate/radio off status
Date: Thu, 21 Sep 2006 17:42:35 -0700
Message-ID: <20060922004235.GA7322@instant802.com>
References: <44F356DF.9000000@linux.intel.com> <20060921190126.4d884c44@logostar.upir.cz> <1158865436.27546.23.camel@localhost.localdomain> <4512EC5C.1030807@linux.intel.com> <1158870634.5769.21.camel@localhost.localdomain> <4512F876.7000203@linux.intel.com> <20060922003844.6817f22b@logostar.upir.cz> <20060921225514.GA26850@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>, mabbas <mabbas@linux.intel.com>,
	Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-45.dex002.intermedia.net ([64.78.21.137]:33169 "EHLO
	dhost002-45.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S932136AbWIVAri (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 20:47:38 -0400
To: Jean Tourrilhes <jt@hpl.hp.com>
Content-Disposition: inline
In-Reply-To: <20060921225514.GA26850@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 21, 2006 at 03:55:14PM -0700, Jean Tourrilhes wrote:

> > Jean, are there any other possibilities?
> 
> 	Yes, dropping SIOCSIWAP (set) entirely, and keep only
> SIOCGIWAP (get).

I don't think that this would be acceptable.

> 	We need to be pragmatic. Very few people need to set a fixed
> BSSID. I would even venture to say that in the case of most people
> setting a fixed BSSID, it's an error and they should not do it (it
> kills roaming, which is a desirable feature). I've yet to find a card
> which scanning is broken to the point that you need to fudge the
> BSSID.

Maybe very few _people_ use it directly, but please keep in mind that
programs like wpa_supplicant may control roaming and do it by using this
SIOCSIWAP. In addition, being able to limit AP selection to one specific
BSSID can be quite useful for number of uses.

> 	There are some drivers that don't support SIOCSIWAP (set), and
> it's usually not a problem, users are not complaining about it. That's
> why I claim we could drop the (set) support. Of course, we can't do it
> because one PhD student at Berkeley need the feature ;-)

There's more than one PhD student needing this and I would be very much
against removing it.

-- 
Jouni Malinen                                            PGP id EFC895FA
