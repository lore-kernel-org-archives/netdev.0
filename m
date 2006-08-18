From: "Simon Barber" <simon@devicescape.com>
Subject: RE: proposal for new wireless configuration API
Date: Fri, 18 Aug 2006 09:45:08 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F0165B1AC@dhost002-46.dex002.intermedia.net>
References: <1155884507.3425.5.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Dan Williams" <dcbw@redhat.com>, <netdev@vger.kernel.org>,
	"Jean Tourrilhes" <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:26914 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751420AbWHRQpH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 12:45:07 -0400
Content-class: urn:content-classes:message
in-reply-to: <1155884507.3425.5.camel@ux156>
To: "Johannes Berg" <johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I did mean RSSI - just about anything that when interpreted as an 8 bit
unsigned int and goes up with increasing signal fits the bill as an RSSI
measure. RCPI requires a certain minimum accuracy and linearity (the
accuracy required is not very high).

Simon


-----Original Message-----
From: Johannes Berg [mailto:johannes@sipsolutions.net] 
Sent: Friday, August 18, 2006 12:02 AM
To: Simon Barber
Cc: Dan Williams; netdev@vger.kernel.org; Jean Tourrilhes
Subject: RE: proposal for new wireless configuration API

On Thu, 2006-08-17 at 09:42 -0700, Simon Barber wrote:
> The spec for RSSI is very loose - RSSI is just a 8 bit unsigned 
> number, guaranteed to be a monotonically increasing function of signal
strength.
> You don't get to know anything about the scale, or linearity of the 
> function. In essence RSSI is a vendor specific value, of no known
units.
> Not very useful unless you know some card specific details to help 
> interpret it.

Yeah, if you knew at least linearity it'd be more useful.

> Now some cards return a signal strength in dBm as the RSSI - note that

> this fits the requirements of a RSSI measure just fine. RCPI is simply

> a
                                  ^^^^
did you mean to write RCPI there?

> more tightly specified signal strength measure.

Ah, ok. Yes, I think we almost know how to make the bcm card report dBm
instead.

johannes
