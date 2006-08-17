From: Johannes Berg <johannes@sipsolutions.net>
Subject: RE: proposal for new wireless configuration API
Date: Thu, 17 Aug 2006 09:19:38 +0200
Message-ID: <1155799178.3653.4.camel@ux156>
References: <C86180A8C204554D8A3323D8F6B0A29F0165AF0E@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:25542 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932099AbWHQHTS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 03:19:18 -0400
To: Simon Barber <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F0165AF0E@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-16 at 11:02 -0700, Simon Barber wrote:
> I'd suggest that the new signal strength measure should be defined as
> 'RCPI' - the 'Received Channel Power Indicator' - which is defined in
> IEEE 802.11k (the Radio Measurements amendment to 802.11).

Except that we unfortunately have no way of getting this with all the
reverse engineered devices :) Hence, I guess we should then have
multiple different possibilities. A device reporting RCPI would be
better than just reporting RSSI, but that's still better than nothing...

johannes
