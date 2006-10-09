From: Stefan Rompf <stefan@loplof.de>
Subject: Re: cfg80211 take 7
Date: Mon, 9 Oct 2006 14:52:06 +0200
Message-ID: <200610091452.07098.stefan@loplof.de>
References: <1160146790.2715.82.camel@ux156> <200610091322.10495.stefan@loplof.de> <1160394555.3258.3.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lvps80-237-161-167.dedicated.hosteurope.de ([80.237.161.167]:58018
	"EHLO lvps80-237-161-167.dedicated.hosteurope.de") by vger.kernel.org
	with ESMTP id S932705AbWJIMve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2006 08:51:34 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1160394555.3258.3.camel@ux156>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, 9. Oktober 2006 13:49 schrieb Johannes Berg:

> Yeah, probably makes sense. Though, maybe not just the band but a set of
> channels instead?

Yes, this would allow us to keep the definition of a band out of kernel. But 
to distinguish between 802.11 b and g, we'd need a set of channels and 
allowed modulations. I haven't looked at Larry's regulatory domain stuff yet, 
but maybe band selection could use the same data structure. cfg80211 would 
then just calculate the intersection of user supplied set and set permitted 
by regulations.

Hopefully there is no country that forbids the user *NOT* to scan a specific 
channel ;)

Stefan
