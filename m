From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: cfg80211 take 7
Date: Mon, 09 Oct 2006 09:16:42 -0500
Message-ID: <452A59CA.7060708@lwfinger.net>
References: <1160146790.2715.82.camel@ux156> <200610091322.10495.stefan@loplof.de> <1160394555.3258.3.camel@ux156> <200610091452.07098.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:7372 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932874AbWJIOQy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 10:16:54 -0400
To: Stefan Rompf <stefan@loplof.de>
In-Reply-To: <200610091452.07098.stefan@loplof.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stefan Rompf wrote:
> Am Montag, 9. Oktober 2006 13:49 schrieb Johannes Berg:
> 
>> Yeah, probably makes sense. Though, maybe not just the band but a set of
>> channels instead?
> 
> Yes, this would allow us to keep the definition of a band out of kernel. But 
> to distinguish between 802.11 b and g, we'd need a set of channels and 
> allowed modulations. I haven't looked at Larry's regulatory domain stuff yet, 
> but maybe band selection could use the same data structure. cfg80211 would 
> then just calculate the intersection of user supplied set and set permitted 
> by regulations.
> 
> Hopefully there is no country that forbids the user *NOT* to scan a specific 
> channel ;)
> 

Passive scanning is always allowed, AFAIK. Active scanning is a different matter. In the US, no one 
is allowed to active scan channels 12-14. In addition, there are a number of countries where the 
regulations prohibit active scanning in some or all of the 5 GHz bands.

Larry
