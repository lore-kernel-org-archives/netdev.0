From: "Simon Barber" <simon@devicescape.com>
Subject: RE: d80211-drivers pull request (week-48)
Date: Thu, 14 Dec 2006 21:54:09 -0800
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F01A1A8BA@dhost002-46.dex002.intermedia.net>
References: <200612121035.07382.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Michael Wu" <flamingice@sourmilk.net>,
	"John Linville" <linville@tuxdriver.com>, <netdev@vger.kernel.org>,
	"Ulrich Kunitz" <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:21917 "EHLO
	dhost002-46.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750841AbWLOFxj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 00:53:39 -0500
Content-class: urn:content-classes:message
In-Reply-To: <200612121035.07382.mb@bu3sch.de>
To: "Michael Buesch" <mb@bu3sch.de>, "Daniel Drake" <dsd@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Devicescape does understant that the hardware can do retries - but it
adds software retries on top. This allows higher reliability, as well as
correct handling of the powersave state machine. (PS bit from a STA is
supposed to stop APs transmission immediately).

Simon

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Michael Buesch
Sent: Tuesday, December 12, 2006 1:35 AM
To: Daniel Drake
Cc: Michael Wu; John Linville; netdev@vger.kernel.org; Ulrich Kunitz
Subject: Re: d80211-drivers pull request (week-48)

On Tuesday 12 December 2006 02:07, Daniel Drake wrote:
> Michael Wu wrote:
> >       zd1211rw-d80211: Use ieee80211_tx_status
> 
> I've thought some more about this and I'm not so sure that this is the

> right approach.
> 
> Can't devicescape be taught that the ZD1211 handles retries in 
> hardware and the stack doesn't need to worry about it?
> 
> What does devicescape do in response to not getting an ack?

It does ratecontrol based on that.
Basically: No ACK == failed packet. If too many failures, lower the
rate.

--
Greetings Michael.
-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
