From: Johannes Berg <johannes@sipsolutions.net>
Subject: RE: proposal for new wireless configuration API
Date: Fri, 18 Aug 2006 09:01:47 +0200
Message-ID: <1155884507.3425.5.camel@ux156>
References: <C86180A8C204554D8A3323D8F6B0A29F0165B02D@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:54212 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750776AbWHRHCB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 03:02:01 -0400
To: Simon Barber <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F0165B02D@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-08-17 at 09:42 -0700, Simon Barber wrote:
> The spec for RSSI is very loose - RSSI is just a 8 bit unsigned number,
> guaranteed to be a monotonically increasing function of signal strength.
> You don't get to know anything about the scale, or linearity of the
> function. In essence RSSI is a vendor specific value, of no known units.
> Not very useful unless you know some card specific details to help
> interpret it.

Yeah, if you knew at least linearity it'd be more useful.

> Now some cards return a signal strength in dBm as the RSSI - note that
> this fits the requirements of a RSSI measure just fine. RCPI is simply a
                                  ^^^^
did you mean to write RCPI there?

> more tightly specified signal strength measure.

Ah, ok. Yes, I think we almost know how to make the bcm card report dBm
instead.

johannes
