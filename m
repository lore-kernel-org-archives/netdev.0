From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [patch 1/5] d80211: remove bitfields from ieee80211_tx_control
Date: Mon, 16 Oct 2006 12:34:07 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F01851A93@dhost002-46.dex002.intermedia.net>
References: <200610161807.25261.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jiri Benc" <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:12070 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1422855AbWJPTd5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 15:33:57 -0400
Content-class: urn:content-classes:message
In-Reply-To: <200610161807.25261.mb@bu3sch.de>
To: "Michael Buesch" <mb@bu3sch.de>,
	"David Kimdon" <dwhedon@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing the bitfields makes the code much harder to read and maintain.
Here we are working around a problem with the compiler by making the
code ugly - rather than fixing the compiler. The compilers are getting
better and better (GCC 4 has much better handling of this type of
optimization) but the code will remain ugly for ever.

Simon

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Michael Buesch
Sent: Monday, October 16, 2006 9:07 AM
To: David Kimdon
Cc: netdev@vger.kernel.org; John W. Linville; Jiri Benc
Subject: Re: [patch 1/5] d80211: remove bitfields from
ieee80211_tx_control

On Friday 13 October 2006 21:20, David Kimdon wrote:
> All one-bit bitfields have been subsumed into the new 'flags'
> structure member and the new IEEE80211_TXCTL_* definitions.  The 
> multiple bit members were converted to u8, s8 or u16 as appropriate.

And, eh, did this increase or decrease the struct size?
Does this generate better or worse code?

--
Greetings Michael.
-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
