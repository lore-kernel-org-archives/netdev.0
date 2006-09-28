From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] softmac: Fix WX and association related races
Date: Thu, 28 Sep 2006 16:43:11 +0200
Message-ID: <1159454591.2648.23.camel@ux156>
References: <200609271726.34305.mb@bu3sch.de>
	 <200609271950.47430.mb@bu3sch.de> <451B4AF6.3090203@lwfinger.net>
	 <200609281455.53763.mb@bu3sch.de>
	 <1159453174.2642.8.camel@localhost.localdomain>
	 <1159453641.2648.20.camel@ux156>
	 <1159454237.2642.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:63458 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1161157AbWI1Omf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 10:42:35 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1159454237.2642.17.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-09-28 at 10:37 -0400, Dan Williams wrote:

> Yes, I think I did.  My point here wasn't that the driver is _not_
> sending those messages (it almost certainly is), but what's _implied_ by
> those messages.  Namely that, if you're using a tool like wpa_supplicant
> and/or NM, when you get a deauth from the AP and send the IWAP event,
> all bets are off because the tool will likely override whatever the
> driver thinks its doing.

Ah ok. But I suppose the actual problem is that different drivers do it
differently and hence wpa_supplicant or similar simply cannot react
properly.

That said, I do believe softmac tries reauth or did at some point, I
remember implementing that because the net at uni kept kicking me out.

johannes
