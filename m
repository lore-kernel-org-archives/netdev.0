From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: Can someone please try...
Date: Mon, 22 Jan 2007 16:04:41 -0600
Message-ID: <45B534F9.5090608@lwfinger.net>
References: <200701161806.02780.mb@bu3sch.de>	<200701222106.24329.mb@bu3sch.de> <1169498676.4453.14.camel@dv> <200701222200.19784.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Pavel Roskin <proski@gnu.org>, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:56561 "EHLO
	mtiwmhc13.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751834AbXAVWGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 17:06:38 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200701222200.19784.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Monday 22 January 2007 21:44, Pavel Roskin wrote:
>> The problems with a MadWifi based AP turn out to be related to 802.11g.
>> If the AP is configured for 802.11b only, everything is working.  If
>> 802.11g is enabled, strange things are happening.  Judging by what's on
>> the air, it looks like the driver loses the data frames is receives.
>> wpa_supplicant connects instantly, but ARP and ping packets from AP to
>> STA are lost.  The frames are even acknowledged, but not seen on the
>> station side.  It takes from one to ten minutes util ping suddenly
>> starts working.
> 
> Hm, is this 4318? It is known to loose lots of packets.

On my 4311 with softmac, the throughput is increased by a factor of 6 by reducing the rate from the
default 11M to 1M. Obviously the success rate is greatly improved. Perhaps the same effect will
happen for 4318's. Does the d80211 version let you change the rate?

Larry
