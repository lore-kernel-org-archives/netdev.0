From: Jouni Malinen <j@w1.fi>
Subject: Re: [GIT]: Networking
Date: Mon, 8 Sep 2008 20:06:33 -0700
Message-ID: <20080909030633.GA25492@hostap.isc.org>
References: <20080827.164649.87042354.davem@davemloft.net> <1220627292.7260.3.camel@2710p.home> <48C5E2FC.4090304@atheros.com> <1220929688.7265.4.camel@2710p.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jouni Malinen <jouni.malinen@atheros.com>,
	David Miller <davem@davemloft.net>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	j@w1.fi
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hostap.isc.org ([149.20.54.63]:36481 "EHLO hostap.isc.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752064AbYIIDPM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2008 23:15:12 -0400
Content-Disposition: inline
In-Reply-To: <1220929688.7265.4.camel@2710p.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 08, 2008 at 09:08:08PM -0600, Alex Williamson wrote:
> NetworkManager can see access points, but doesn't get much further than
> that.  From an end user perspective, similar to how it behaved in
> 2.6.26, before Dave's wext compat fixes.

Are you using 802.11n? Dave's patches fixed scan result processing, but
it looks like they may not have fixed wireless_send_event() processing.
It would be interesting to see what wpa_supplicant debug log shows
here. I would assume the device was able to associate with the AP, but
something went wrong when the association information (the data that
was changed to use binary format instead of text-based custom iw event).

-- 
Jouni Malinen                                            PGP id EFC895FA
