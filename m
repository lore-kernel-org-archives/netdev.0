From: "Simon Barber" <simon@devicescape.com>
Subject: RE: proposal for new wireless configuration API
Date: Thu, 17 Aug 2006 09:42:44 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F0165B02D@dhost002-46.dex002.intermedia.net>
References: <1155799178.3653.4.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Dan Williams" <dcbw@redhat.com>, <netdev@vger.kernel.org>,
	"Jean Tourrilhes" <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:27481 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S965126AbWHQQmq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2006 12:42:46 -0400
Content-class: urn:content-classes:message
in-reply-to: <1155799178.3653.4.camel@ux156>
To: "Johannes Berg" <johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The spec for RSSI is very loose - RSSI is just a 8 bit unsigned number,
guaranteed to be a monotonically increasing function of signal strength.
You don't get to know anything about the scale, or linearity of the
function. In essence RSSI is a vendor specific value, of no known units.
Not very useful unless you know some card specific details to help
interpret it.

Now some cards return a signal strength in dBm as the RSSI - note that
this fits the requirements of a RSSI measure just fine. RCPI is simply a
more tightly specified signal strength measure.

Just saying that a RSSI value is not very useful.

Simon
 

-----Original Message-----
From: Johannes Berg [mailto:johannes@sipsolutions.net] 
Sent: Thursday, August 17, 2006 12:20 AM
To: Simon Barber
Cc: Dan Williams; netdev@vger.kernel.org; Jean Tourrilhes
Subject: RE: proposal for new wireless configuration API

On Wed, 2006-08-16 at 11:02 -0700, Simon Barber wrote:
> I'd suggest that the new signal strength measure should be defined as 
> 'RCPI' - the 'Received Channel Power Indicator' - which is defined in 
> IEEE 802.11k (the Radio Measurements amendment to 802.11).

Except that we unfortunately have no way of getting this with all the
reverse engineered devices :) Hence, I guess we should then have
multiple different possibilities. A device reporting RCPI would be
better than just reporting RSSI, but that's still better than nothing...

johannes
