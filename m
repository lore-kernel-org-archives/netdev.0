From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH] net/wireless: CFG80211_WEXT_EXPORT requires wireless
 extensions
Date: Sat, 11 Apr 2015 14:47:16 +0200
Message-ID: <1428756436.17822.105.camel@x220>
References: <2303996.H1mYPouv05@wuerfel>
	 <1428733011.2139.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb3-smtp-cloud6.xs4all.net ([194.109.24.31]:34676 "EHLO
	lb3-smtp-cloud6.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752534AbbDKMrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 08:47:20 -0400
In-Reply-To: <1428733011.2139.1.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-04-11 at 08:16 +0200, Johannes Berg wrote:
> On Sat, 2015-04-11 at 00:29 +0200, Arnd Bergmann wrote:
> >  config CFG80211_WEXT_EXPORT
> >  	bool
> >  	depends on CFG80211
> > +	select CFG80211_WEXT
> 
> This doesn't work afaict because select won't go through if this is
> selected.

It does work: a select of a Kconfig symbol will trigger the select
statements of that Kconfig symbol.


Paul Bolle
